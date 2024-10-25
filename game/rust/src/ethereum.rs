use std::sync::Arc;
use std::vec;

use ethers::prelude::*;
use ethers::providers::{Http, Provider};
abigen!(BugVerificationContract, "../../risc_zero/host/bug_verification.json",);

const RPC_URL: &str = "https://ethereum-holesky-rpc.publicnode.com";

#[derive(Debug)]
pub struct RecordHolder {
    stepsAmount: u32,
    recordHolder: String,
    updatesCounter: u32,
}

pub fn get_record_holders() -> Vec::<RecordHolder> {

    let rt = tokio::runtime::Runtime::new().expect("Error in tokio runtime generation");
    let provider = Provider::<Http>::try_from(RPC_URL).expect("Failed to connect to provider");

    // Block on the async call inside the runtime
    rt.block_on(async {
        // Initialize an HTTP provider (e.g., using Infura)
        let provider_arc = Arc::new(provider);

        // The address of the deployed contract on the Ethereum network
        // let contract_address: Address = "0xe7220a7C016935F410F6Cda260125b87fc7cD908".parse().expect("Error in address parsing");
        let contract_address: Address = "0x15758C745B349E581fa8f167819ff16eCaF60fcA".parse().expect("Error in address parsing");
        
        // Instantiate the contract instance with the provider (no wallet needed)
        let contract = BugVerificationContract::new(contract_address, provider_arc);

        let record_holders_amount: u32 = contract.get_record_holders_length().call().await.expect("Error getting array length").as_u32();

        let mut record_holders = Vec::<RecordHolder>::new();
        for i in 0..record_holders_amount {
            let current_record_holder: (u32, H160, u32) = contract.record_holders(i.into()).call().await.expect("Error getting indexed value");
            record_holders.push(RecordHolder {
                stepsAmount: current_record_holder.0,
                recordHolder: current_record_holder.1.to_string(),
                updatesCounter: current_record_holder.2,
            })
        }

        // println!("Array length: {}", record_holders_amount);

        // let index: u64 = 0;

        // println!("Value at index {}: {:?}", index, result);
        println!("record_holders: {:?}", record_holders);

        record_holders
    })
}