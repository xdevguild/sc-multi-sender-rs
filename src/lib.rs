#![no_std]

elrond_wasm::imports!();

#[elrond_wasm::contract]
pub trait MultiSenderContract {
    #[init]
    fn init(&self) {}

    #[payable("EGLD")]
    #[endpoint(multiSendEgld)]
    fn multi_send_egld(&self, args: MultiValueEncoded<MultiValue2<ManagedAddress, BigUint>>) {
        let payment_amount = self.call_value().egld_value();
        let mut amount_to_send = BigUint::zero();

        for arg in args.into_iter() {
            let (receiver, amount) = arg.into_tuple();
            amount_to_send += &amount;

            self.send().direct_egld(&receiver, &amount);
        }
        require!(payment_amount == amount_to_send, "Invalid amount");
    }

    #[payable("*")]
    #[endpoint(multiSendEsdt)]
    fn multi_send_esdt(
        &self,
        token_id: TokenIdentifier,
        args: MultiValueEncoded<MultiValue2<ManagedAddress, BigUint>>
    ) {
        let payment = self.call_value().single_esdt();
        require!(payment.token_identifier == token_id, "Invalid token id");
        
        let mut amount_to_send = BigUint::zero();

        for arg in args.into_iter() {
            let (receiver, amount) = arg.into_tuple();
            amount_to_send += &amount;

            self.send().direct_esdt(&receiver, &token_id, 0, &amount)
        }
        require!(payment.amount == amount_to_send, "Invalid amount");
    }

    // It only supports NFT.
    #[payable("*")]
    #[endpoint(multiSendNft)]
    fn multi_send_nft(
        &self,
        collection_id: TokenIdentifier,
        args: MultiValueEncoded<MultiValue2<ManagedAddress, u64>>
    ) {
        let payments = self.call_value().all_esdt_transfers();
        require!(!payments.is_empty(), "No payments");

        for payment in &payments {
            require!(payment.token_identifier == collection_id, "Invalid token id");
            require!(payment.amount == 1, "Invalid amount");
        }

        for arg in args.into_iter() {
            let (receiver, nonce) = arg.into_tuple();

            self.send().direct_esdt(&receiver, &collection_id, nonce, &BigUint::from(1u64));
        }
    }
}
