#!/bin/bash

set -euo pipefail

echo "### INGRESS TEST ###"

echo "> httpbin server address"
expected=$(dig +short aserver)
echo $expected

echo "> real client address"
ip -j a | jq -r '.[].addr_info[] | select(.scope == "global") | .local'

echo "> address seen by httpbin"
actual=$(curl -sS -m 10 http://aserver/ip | jq -r '.origin')
echo $actual

test "$expected" = "$actual"
