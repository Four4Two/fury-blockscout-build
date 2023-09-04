#!/bin/bash

# log all commands to stdout and stop the script on the first error
set -ex

DATA="/root/.fury/"

# exit early if geneis.json already exists
# which will happen if the fury docker container is stopped and later restarted
if test -f "/root/.fury/config/genesis.json" ; then
    echo "genesis.json alredy exists, skipping chain init and validator initilization"
else
    # create default genesis and node config
    fury init test --chain-id=localnet_7777-1

    # use the test backend to avoid prompts when storing and accessing keys
    fury config keyring-backend test

    # create an account for the delegator
    fury keys add fury-localnet-delegator

    # add the delegator account to the default genesis
    fury add-genesis-account $(fury keys show fury-localnet-delegator -a) 1000000000ufury

    # create genesis info for a validator staked by the delegator above
    fury gentx fury-localnet-delegator 500000000ufury \
        --chain-id=localnet_7777-1 \
        --moniker="fury-localnet-validator"

    # merge above transaction with previously generated default genesis
    fury collect-gentxs

    sed -in-place='' 's/stake/ufury/g' $DATA/config/genesis.json
    sed -in-place='' 's/aphoton/afury/g' $DATA/config/genesis.json
    sed -in-place='' 's/"max_gas": "-1"/"max_gas": "20000000"/' $DATA/config/genesis.json
fi

# set config for fury processes to use
cp /docker/fury/config.toml ~/.fury/config/config.toml

# start the fury process
fury start --trace --api.enable=true --rpc.laddr=tcp://0.0.0.0:26657 --json-rpc.address=0.0.0.0:8545

# run forever (fury start is non-blocking)
tail -f /dev/null
