#!/bin/bash
# fetches or computes data needed for forced contract verification
# using process defined in https://fury-labs.atlassian.net/wiki/spaces/ENG/pages/1290829828/Blockscout+Manual+Contract+Verification+Fixes
# run like ./fetch_compute_contract_verification_data.sh https://evm.fury.io 0xD0b97bd475f53767DBc7aDcD70f499000Edc916C

# log all commands and values used by the script return code
# set -x

# function to decode bytecode to utf-8
# call like decode_hex_to_utf8 HEX_VALUE_GOES_HERE
Decode_hex_to_utf8_Return_Val=   # Global variable to hold return value of function.
decode_hex_to_utf8 () {
    decode_hex_to_utf8_sql="select * from decode('$1', 'hex');"

    utf8=$(AWS_PROFILE=production aws rds-data execute-statement --secret-arn arn:aws:secretsmanager:us-east-1:830681326651:secret:blockscout-fury-10-creds-2-vHdYae --resource-arn arn:aws:rds:us-east-1:830681326651:cluster:blockscout-fury-10 --sql "$decode_hex_to_utf8_sql" --database blockscout_fury_10 | jq -r .records[0][0].blobValue)

    Decode_hex_to_utf8_Return_Val=$utf8

    echo $utf8 > "$1".address_hash
}

# parse command line flags
FURY_EVM_RPC_ENDPOINT=$1
CONTRACT_OX_ADDRESS=$2

################ Step 1 ################
# fetch the byte code for the contract
response=$(curl "$FURY_EVM_RPC_ENDPOINT" -X POST \
  -H "Content-Type: application/json" \
  --data @/dev/stdin<<EOF
    {
        "jsonrpc":"2.0",
        "method":"eth_getCode",
        "params":[
                "$CONTRACT_OX_ADDRESS",
                "latest"
        ],
        "id":1
    }
EOF
)

# parse code from response
code=$(echo $response | jq -r '.result')

# save code to file for use by other scripts
echo $code > "$CONTRACT_OX_ADDRESS".bytecode
printf "contract $CONTRACT_OX_ADDRESS bytecode with 0x prefix removed for inserting into addresses table\n %s\n" "${code:2}"

# get current contract addresses table row
stripped_0x_address=${CONTRACT_OX_ADDRESS:2}
./fetch_current_contract_addresses_table_row.sh  $stripped_0x_address


################ Step 2 ################

# compile smart contract with solidity



# Manually add \r\n for newlines to show up in UI, otherwise it will be all in 1 single line https://github.com/blockscout/blockscout/issues/1106
