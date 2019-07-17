#!/usr/bin/env bash

# Before using this script, you should have use the cloudflare as your DNS server
# API_KEY and Email of CloudFlare, can get the key from here: https://dash.cloudflare.com/profile
Domain=$1
CF_Key=$2
CF_Email=$3

if [ -z "$Domain" -o -z "$CF_Key" -o -z "$CF_Email" ]; then
   echo -e "Error: Invalid parameter(s). Expect:1. Domain 2. CloudFlare Key 3. CloudFlare Email"
   exit 42
fi

echo "Domain: $Domain"
echo "CloudFlare Email: $CF_Email"

sudo apt update
sudo apt install socat

export CF_Key=$CF_Key
export CF_Email=$CF_Email

curl  https://get.acme.sh | sh
# It will install acme.sh to ~/.acme.sh

~/.acme.sh/acme.sh --issue --dns dns_cf -d $Domain