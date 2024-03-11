#!/bin/sh

echo "> httpbin server address"
dig +short aserver

echo "> real client address"
ip -j a | jq -r '.[].addr_info[] | select(.scope == "global") | .local'

echo "> address seen by httpbin"
curl -s http://aserver/ip | jq -r '.origin'
