# Multi Sender smart contract

The multi sender smart contract is a smart contract that allows you to send EGLD, ESDTs and NFTs to multiple addresses in one transaction.

### The smart contract 

## multiSendEgld
```rust
    #[payable("EGLD")]
    #[endpoint(multiSendEgld)]
    fn multi_send_egld(
        &self,
        args: MultiValueEncoded<MultiValue2<ManagedAddress, BigUint>>
    );
 ```

 The Multi Send Egld function only accepts EGLD as payment. It receives the following arguments: 

* One address you want to send to
* The amount you want to send to the address

You can add as many addresses and amounts as you want in the arguments but it must remain in order : Address A, Amount A.

Example of data for a transaction where there are 2 addresses:

```
 multiSendEgld +
@ + Address A in hexadecimal +
@ + Amount to send to Address A in hexadecimal +
@ + Address B in hexadecimal +
@ + Amount to send to Address B in hexadecimal 
```

Note that the amount you send to the endpoint must equal the total amount you want to send between all addresses.

## multiSendEsdt
```rust
    #[payable("*")]
    #[endpoint(multiSendEsdt)]
    fn multi_send_esdt(
        &self,
        token_id: TokenIdentifier,
        args: MultiValueEncoded<MultiValue2<ManagedAddress, BigUint>>
    );
 ```

The Multi Send Esdt function only accepts ESDT as payment. It receives the following arguments:

* The token identifier of the ESDT you want to send
* One address you want to send to 
* The amount you want to send to the address

You can add as many addresses and amounts as you want in the arguments but it must remain in order : Address A, Amount A.

Example of data for a transaction where there are 2 addresses:

```
 ESDTTransfer +
@ + Token Identifier in hexadecimal +
@ + Total amount in hexadecimal +
@ + multiSendEsdt in hexadecimal +
@ + Token Identifier in hexadecimal +
@ + Address A in hexadecimal +
@ + Amount to send to Address A in hexadecimal +
@ + Address B in hexadecimal +
@ + Amount to send to Address B in hexadecimal 
```

The token you send to the endpoint must be the same as the token identifier you pass in the arguments and the total amount send must egal to the total amount you want to send between all addresses you pass in the arguments.

## multiSendNft
```rust
    #[payable("*")]
    #[endpoint(multiSendNft)]
    fn multi_send_nft(
        &self,
        collection_id: TokenIdentifier,
        args: MultiValueEncoded<MultiValue2<ManagedAddress, u64>>
    );
 ```

 The Multi Send Nft function only accepts NFT. It receives the following arguments:

* The NFT Collection Identifier you want to send 
* One address you want to send to 
* The nonce OF the NFT you want to send to the address

You can add as many addresses and nonce as you want in the arguments but it must remain in order : Address A, Nonce A.

Example of data for a transaction where there are 2 addresses:

```
 MultiESDTNFTTransfer +
@ + Smart Contract address in hexadecimal +
@ + Number of NFT you want to send in hexadecimal +
@ + NFT Collection Identifier in hexadecimal +
@ + Nonce of one NFT you want to send in hexadecimal +
@ + 01 +
@ + NFT Collection Identifier in hexadecimal +
@ + Nonce of one NFT you want to send in hexadecimal +
@ + 01 +
@ + multiSendNft in hexadecimal +
@ + NFT Collection Identifier in hexadecimal +
@ + Address A in hexadecimal +
@ + Nonce to send to Address A in hexadecimal +
@ + Address B in hexadecimal +
@ + Nonce to send to Address B in hexadecimal 
```

The NFT collection identifier you want to send must be the same as the collection identifier you pass in the arguments.

## Deployment

1. You have to build the contract `erdpy contract build`
2. You have to deploy the contract

There is a set of snippets you can use in [interaction](https://github.com/SkyzoxRobin/sc-multi-sender-rs/blob/main/interaction/devnet.snippets.sh)

## deploy
```shell
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
```

## multiSendEgld interaction
```shell
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
```

## multiSendEsdt interaction
```shell
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
```

## multiSendNft interaction
```shell
multiSendNft() {
    user_address=$(erdpy wallet pem-address ${OWNER}) # Your address
    number_of_token_to_send=02 # Number of NFTs you want to transfer
    collection_id=str:XGUARDIAN-abfbee # The NFT collection ID you want to send
    nonce_1=0x0a70 # The nonce of the first NFT you want to send
    nonce_2=0x0a71 # The nonce of the second NFT you want to send
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
                    $ADDRESS_1 \
                    $nonce_1 \
                    $ADDRESS_2 \
                    $nonce_2 \
        --send || return
}
```
