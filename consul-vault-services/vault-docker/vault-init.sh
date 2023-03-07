#!/bin/bash

echo "starting the vault server"
nohup vault server -config=/vault/vault.hcl &>/dev/null &

echo "Giving the appropriate permissions"
chmod 777 -R /vault

echo "Setting the VAULT_ADDR variable"
export VAULT_ADDR=http://127.0.0.1:8200

init=$(vault status -format "json" | jq --raw-output '.initialized')

if [ "$init" = "false" ]; then
  echo "Initializing Vault"
  vault operator init > /vault/config/vault-keys.txt
fi

echo "copying vault-keys.txt"
cp /vault/config/vault-keys.txt ./vault-keys.txt

echo "checking vault status"
vault_status=$(vault status -format "json" | jq --raw-output '.sealed')

declare -A keys
keys+=(["key1"]='' ["key2"]='' ["key3"]='' ["key4"]='')


IFS=':'
i=1
while read line
do
  read -ra arr <<< "$line"
  for val in "${arr[@]}";
  do
      if [ "$i" -lt 4 ]
      then
          keys["key${i}"]=${arr[1]}
      elif [ "$i" -eq 7 ]
      then
          keys["key4"]=${arr[1]}
      fi
  done
  ((i=i+1))
done < /vault/config/vault-keys.txt

if [[ $vault_status == 'true' ]]; then
  echo "Vault sealed. Starting vault unsealing..."
  i=1
  while [[ $vault_status == 'true' ]] && [[ $i -lt 4 ]];
  do
    echo "Unsealing with key: ${keys[key$i]}"
    VAULT_ADDR=http://127.0.0.1:8200 vault operator unseal ${keys[key$i]} &>/dev/null
    vault_status=$(vault status -format "json" | jq --raw-output '.sealed')
    i=$[$i+1]
  done
fi

echo "Logging into vault"
VAULT_ADDR=http://127.0.0.1:8200 vault login ${keys[key4]} &>/dev/null

echo "writing the admin policy"
vault policy write admin /vault/admin-policy.hcl

ADMIN_TOKEN=$(vault token create -format=json -policy="admin" | jq -r ".auth.client_token") 
vault secrets disable secret
vault secrets enable -version=1 -path=secret kv

vault kv put secret/authentication-service jotSecret=6ieV7JMtGXriOWmeZ0j1Y4b/3rnrBZ6cvC4+4ePu2PnO jasyptSecret=/4AqlE+22dw5xVmSOkyX58JuZ4Jgi6CzySAu6mcUQsDP dbUser=albaAdmin dbPass=Alba@123 emailUser=arunima.mishra@albanero.io emailPass=prince@123

while true; do sleep 1; done
