#!/bin/bash

# log all commands and values used by the script return code
# set -x

# parse command line flags
stripped_0x_address=$1

################ Step 1 ################

# get the current addresses table values for the contract to force verify
read -r -d '' get_current_addresses_data_sql <<EOF
select *
  from public.addresses
where
  hash = decode('$stripped_0x_address', 'hex');
EOF

current_addresses_data=$(AWS_PROFILE=production aws rds-data execute-statement --secret-arn arn:aws:secretsmanager:us-east-1:830681326651:secret:blockscout-fury-10-creds-2-vHdYae --resource-arn arn:aws:rds:us-east-1:830681326651:cluster:blockscout-fury-10 --sql "$get_current_addresses_data_sql" --database blockscout_fury_10 | jq .records[0] )

current_fetched_coin_balance=$(echo $current_addresses_data | jq .[0]."stringValue")
current_fetched_coin_balance_block_number=$(echo $current_addresses_data | jq .[1]."longValue")
current_hash=$(echo $current_addresses_data | jq .[2]."blobValue")
current_contract_code=$(echo $current_addresses_data | jq .[3]."stringValue")
current_inserted_at=$(echo $current_addresses_data | jq .[4]."stringValue")
current_updated_at=$(echo $current_addresses_data | jq .[5]."stringValue")
current_nonce=$(echo $current_addresses_data | jq .[6]."stringValue")
current_decompiled=$(echo $current_addresses_data | jq .[7]."booleanValue")
current_verified=$(echo $current_addresses_data | jq .[8]."booleanValue")
current_gas_used=$(echo $current_addresses_data | jq .[9]."longValue")
current_transactions_count=$(echo $current_addresses_data | jq .[10]."longValue")
current_token_transfers_count=$(echo $current_addresses_data | jq .[11]."longValue")

echo "current values for rows fetched_coin_balance fetched_coin_balance_block_number hash contract_code inserted_at updated_at nonce decompiled verified gas_used transactions_count token_transfers_count"
echo $current_fetched_coin_balance $current_fetched_coin_balance_block_number $current_hash $current_contract_code $current_inserted_at $current_updated_at $current_nonce $current_decompiled $current_verified $current_gas_used $current_transactions_count $current_token_transfers_count
