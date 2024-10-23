use std::sync::Arc;

use ethers::prelude::*;
use ethers::providers::{Http, Provider};
abigen!(BugVerificationContract, "../../risc_zero/host/bug_verification.json",);

const RPC_URL: &str = "https://ethereum-holesky-rpc.publicnode.com";


fn get_record_holders() {

    let rt = tokio::runtime::Runtime::new().expect("Error in tokio runtime generation");
    let provider = Provider::<Http>::try_from(RPC_URL).expect("Failed to connect to provider");

    // Block on the async call inside the runtime
    rt.block_on(async {
        // Initialize an HTTP provider (e.g., using Infura)
        let provider_arc = Arc::new(provider);

        // The address of the deployed contract on the Ethereum network
        let contract_address: Address = "0xe7220a7C016935F410F6Cda260125b87fc7cD908".parse().expect("Error in address parsing");

        // Instantiate the contract instance with the provider (no wallet needed)
        let contract = BugVerificationContract::new(contract_address, provider_arc);

        let index: u64 = 1;
        let result = contract.record_holders(index.into()).call().await.expect("Error getting index");

        println!("Value at index {}: {:?}", index, result);


        // Ok(())
    })

}