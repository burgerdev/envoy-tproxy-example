#!/bin/bash

set -euo pipefail

echo "### EGRESS TEST ###"

echo "> real client address"
expected=$(ip -j a | jq -r '.[].addr_info[] | select(.scope == "global") | .local')
echo $expected

echo "> address seen by httpbin"
actual=$(curl -sS -m 10 http://bserver/ip | jq -r '.origin')
echo $actual

test "$expected" = "$actual"
