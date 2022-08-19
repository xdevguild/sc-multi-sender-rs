#![no_std]

elrond_wasm::imports!();

#[elrond_wasm::contract]
pub trait MultiSenderContract {
    #[init]
    fn init(&self) {}

    #[payable("EGLD")]
    #[endpoint(multiSendEgld)]
    fn multi_send_egld(&self, args: MultiValueEncoded<MultiValue2<ManagedAddress, BigUint>>) {
        let amount_sent = self.call_value().egld_value();
        let mut amount_to_send = BigUint::zero();

        for arg in args.into_iter() {
            let (receiver, amount) = arg.into_tuple();
            amount_to_send += &amount;

            self.send().direct_egld(&receiver, &amount);
        }
        require!(amount_sent == amount_to_send, "Invalid amount");
    }
}
