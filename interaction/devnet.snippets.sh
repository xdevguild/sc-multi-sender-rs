PROXY="https://devnet-gateway.elrond.com"
CHAIN="D"
OWNER="../../wallet-owner.pem" # Change for your PEM
CONTRACT="output/multi-sender.wasm"

SC_ADDRESS="erd1qqqqqqqqqqqqqpgqllh2w5mjfr5rapw7eptsxmnx36a3fpdqnqjsw3gexy" # Add your SC Address

deploy() {
    erdpy --verbose contract deploy --bytecode="$CONTRACT" --recall-nonce \
        --pem=$OWNER \
        --gas-limit=599000000 \
        --proxy=$PROXY --chain=$CHAIN \
        --outfile="deploy-devnet.interaction.json" --send || return

    TRANSACTION=$(erdpy data parse --file="deploy-devnet.interaction.json" --expression="data['emittedTransactionHash']")
    ADDRESS=$(erdpy data parse --file="deploy-devnet.interaction.json" --expression="data['contractAddress']")

    erdpy data store --key=address-devnet --value=${ADDRESS}
    erdpy data store --key=deployTransaction-devnet --value=${TRANSACTION}

    echo "Smart contract address: ${ADDRESS}"
}

ADDRESS_1="erd17yva92k3twysqdf4xfw3w0q8fun2z3ltpnkqldj59297mqp9nqjs9qvkwn" # First address to send
AMOUNT_1=10000000 # Amount to send to the first address
ADDRESS_2="erd1l96krs972vy4js70qp73456wd6c0n0ekf3kmq0hlazjutalg049qs5m7dd" # Second address to send 
AMOUNT_2=10000000 # Amount to send to the first address

NFT_AMOUNT=1

multiSendEgld() {
    erdpy --verbose contract call ${SC_ADDRESS} --recall-nonce \
        --pem=$OWNER \
        --gas-limit=5000000 \
        --proxy=$PROXY --chain=$CHAIN \
        --value=20000000 \
        --function="multiSendEgld" \
        --arguments $ADDRESS_1 $AMOUNT_1 $ADDRESS_2 $AMOUNT_2  \
        --send || return
}


multiSendEsdt() {
    token_id=str:RIDE-6e4c49 # the token id you want to send 
    amount=20000000 # the total amount to send
    method_name=str:multiSendEsdt

        erdpy --verbose contract call ${SC_ADDRESS} --recall-nonce \
        --pem=$OWNER \
        --gas-limit=5000000 \
        --proxy=$PROXY --chain=$CHAIN \
        --function="ESDTTransfer" \
        --arguments $token_id $amount $method_name $token_id $ADDRESS_1 $AMOUNT_1 $ADDRESS_2 $AMOUNT_2  \
        --send || return
}

multiSendNft() {
    user_address=$(erdpy wallet pem-address ${OWNER}) # Your address
    number_of_token_to_send=02 # Number of NFTs you want to transfer
    collection_id=str:XGUARDIAN-abfbee # The NFT collection ID you want to send
    nonce_1=0x0a6d # The nonce of the first NFT you want to send
    nonce_2=0x0a6e # The nonce of the second NFT you want to send
    method_name=str:multiSendNft

        erdpy --verbose contract call ${user_address} --recall-nonce \
        --pem=$OWNER \
        --gas-limit=5000000 \
        --proxy=$PROXY --chain=$CHAIN \
        --function="MultiESDTNFTTransfer" \
        --arguments $SC_ADDRESS \
                    $number_of_token_to_send \
                    $collection_id \
                    $nonce_1 \
                    $NFT_AMOUNT \
                    $collection_id \
                    $nonce_2 \
                    $NFT_AMOUNT \
                    $method_name \
                    $collection_id \
        --send || return
}
