#!/usr/bin/env bash

iv=$(openssl rand -hex 12)
slate=$(cat $3)
payload=$(echo "{\"id\":\"$iv\",\"method\":\"post_tx\",\"params\":{\"token\":\"$2\",\"slate\":$slate, \"fluff\":true}}")
payload=$(.venv/bin/python ./scripts/python/encrypt.py "$1" "$iv" "$payload")
unset label
read body_enc nonce < <(echo $(curl -s --user grin:$(cat ~/.grin/test/.owner_api_secret) -d '{"jsonrpc":"2.0", "id":"'"$iv"'","method":"encrypted_request_v3","params":{"nonce":"'"$iv"'","body_enc":"'"$payload"'"}}' -o - http://127.0.0.1:3420/v3/owner | jq -r '.result.Ok.body_enc, .result.Ok.nonce'))
unset payload
result=$(.venv/bin/python ./scripts/python/decrypt.py $1 $nonce $body_enc)
if $(echo $result | jq 'has("error")')
then
    echo $result | jq .error.message
    exit 1
else
    echo "Transaction posted."
fi
exit 0
