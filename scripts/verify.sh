#!/bin/bash
# Reads the live network and prints a pass/fail table.
# Inputs: an Azure command-line interface (CLI) login. The subscription id
# is taken from ARM_SUBSCRIPTION_ID when that variable is set, and from the
# current CLI account when it is not. The names below match variables.tf.
# Output: six lines, each PASS or FAIL. Exit 0 when all pass, exit 1 otherwise.
# Side effects: none. This script does not create or delete Azure resources.

set -u
set -o pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"

resource_group="rg-tf-poc-zeon01"
virtual_network="vnet-tf-poc"
subnet_name="snet-backend"
nsg_name="nsg-web"
address_space="10.2.0.0/16"
subnet_prefix="10.2.1.0/24"
location="eastus"

if [[ -z "${ARM_SUBSCRIPTION_ID:-}" ]]; then
  ARM_SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
  export ARM_SUBSCRIPTION_ID
fi

failed=0
pass() { printf '%s  %s: PASS\n' "$1" "$2"; }
fail() { printf '%s  %s: FAIL\n' "$1" "$2"; failed=1; }

group_location="$(az group show --name "$resource_group" --query location -o tsv 2>/dev/null || true)"
if [[ "$group_location" == "$location" ]]; then
  pass 1 "Resource group ${resource_group} is in ${location}"
else
  fail 1 "Resource group ${resource_group} is in ${location}"
fi

space="$(az network vnet show \
  --resource-group "$resource_group" \
  --name "$virtual_network" \
  --query "addressSpace.addressPrefixes[0]" \
  -o tsv 2>/dev/null || true)"
if [[ "$space" == "$address_space" ]]; then
  pass 2 "Virtual network ${virtual_network} address space is ${address_space}"
else
  fail 2 "Virtual network ${virtual_network} address space is ${address_space}"
fi

prefix="$(az network vnet subnet show \
  --resource-group "$resource_group" \
  --vnet-name "$virtual_network" \
  --name "$subnet_name" \
  --query "addressPrefixes[0]" \
  -o tsv 2>/dev/null || true)"
if [[ -z "$prefix" ]]; then
  prefix="$(az network vnet subnet show \
    --resource-group "$resource_group" \
    --vnet-name "$virtual_network" \
    --name "$subnet_name" \
    --query addressPrefix \
    -o tsv 2>/dev/null || true)"
fi
if [[ "$prefix" == "$subnet_prefix" ]]; then
  pass 3 "Subnet ${subnet_name} prefix is ${subnet_prefix}"
else
  fail 3 "Subnet ${subnet_name} prefix is ${subnet_prefix}"
fi

found_nsg="$(az network nsg show \
  --resource-group "$resource_group" \
  --name "$nsg_name" \
  --query name \
  -o tsv 2>/dev/null || true)"
if [[ "$found_nsg" == "$nsg_name" ]]; then
  pass 4 "Network security group ${nsg_name} exists"
else
  fail 4 "Network security group ${nsg_name} exists"
fi

# The identifier ends with the security group name. Printing the whole
# identifier would include the subscription id, so only the last segment is kept.
nsg_id="$(az network vnet subnet show \
  --resource-group "$resource_group" \
  --vnet-name "$virtual_network" \
  --name "$subnet_name" \
  --query "networkSecurityGroup.id" \
  -o tsv 2>/dev/null || true)"
attached="${nsg_id##*/}"
if [[ "$attached" == "$nsg_name" ]]; then
  pass 5 "Subnet ${subnet_name} uses ${nsg_name}"
else
  fail 5 "Subnet ${subnet_name} uses ${nsg_name}"
fi

plan_log="$(mktemp)"
trap 'rm -f "$plan_log"' EXIT
set +e
terraform plan -input=false -detailed-exitcode -no-color >"$plan_log" 2>&1
plan_status=$?
set -e
if [[ "$plan_status" -eq 0 ]]; then
  pass 6 "terraform plan reports no changes"
elif [[ "$plan_status" -eq 2 ]]; then
  fail 6 "terraform plan reports no changes"
else
  fail 6 "terraform plan reports no changes"
  sed -E 's#/subscriptions/[0-9a-fA-F-]+#/subscriptions/<subscription-id>#g' "$plan_log" | tail -n 20
fi

exit "$failed"
