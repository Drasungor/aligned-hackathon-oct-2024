// #![feature(slice_flatten)]
use std::io;

// These constants represent the RISC-V ELF and the image ID generated by risc0-build.
// The ELF is used for proving and the ID is used for verification.
use methods::{
    GAME_REPLAY_ELF, GAME_REPLAY_ID
};
use risc0_zkvm::{default_prover, ExecutorEnv};


// use aligned_sdk::core::types::{
//     AlignedVerificationData, Network, PriceEstimate, ProvingSystemId, VerificationData,
// };
// use aligned_sdk::sdk::{deposit_to_aligned, estimate_fee};
// use aligned_sdk::sdk::{get_next_nonce, submit_and_wait_verification};

use aligned_sdk::core::types::{
    AlignedVerificationData, Network, PriceEstimate, ProvingSystemId, VerificationData,
};
use aligned_sdk::sdk::{estimate_fee, deposit_to_aligned, get_payment_service_address};
use aligned_sdk::sdk::{get_next_nonce, submit_and_wait_verification};

use clap::Parser;
use dialoguer::Confirm;
use ethers::prelude::*;
use ethers::providers::{Http, Provider};
use ethers::signers::{LocalWallet, Signer};
use ethers::types::{Address, Bytes, H160, U256};


use shared::position::Position;

const RPC_URL: &str = "https://ethereum-holesky-rpc.publicnode.com";
const BATCHER_URL: &str = "wss://batcher.alignedlayer.com";
// const NETWORK: Network = "holesky" as Network;
const NETWORK: Network = Network::Holesky;
const CONTRACT_ADDRESS: &str = "0xBD2388F7b7c99D3947e8e7e2EC89B96731E2b3a0";

abigen!(BugVerificationContract, "bug_verification.json",);

#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
struct Args {
    #[arg(short, long)]
    keystore_path: String,
    // #[arg(
    //     short,
    //     long,
    //     default_value = "https://ethereum-holesky-rpc.publicnode.com"
    // )]
    // rpc_url: String,
    // #[arg(short, long, default_value = "wss://batcher.alignedlayer.com")]
    // batcher_url: String,
    // #[arg(short, long, default_value = "holesky")]
    // network: Network,
    // #[arg(short, long)]
    // verifier_contract_address: H160,
}

#[tokio::main]
async fn main() {

    let args = Args::parse();


    let keystore_password = rpassword::prompt_password("Enter keystore password: ")
    .expect("Failed to read keystore password");

    let provider = Provider::<Http>::try_from(RPC_URL).expect("Failed to connect to provider");

    let chain_id = provider
        .get_chainid()
        .await
        .expect("Failed to get chain_id");

    let wallet = LocalWallet::decrypt_keystore(args.keystore_path, &keystore_password)
        .expect("Failed to decrypt keystore")
        .with_chain_id(chain_id.as_u64());


    let signer = SignerMiddleware::new(provider.clone(), wallet.clone());

    if Confirm::with_theme(&dialoguer::theme::ColorfulTheme::default())
        .with_prompt("Do you want to deposit 0.004eth in Aligned ?\nIf you already deposited Ethereum to Aligned before, this is not needed")
        .interact()
        .expect("Failed to read user input") {   

        deposit_to_aligned(U256::from(4000000000000000u128), signer.clone(), NETWORK).await
        .expect("Failed to pay for proof submission");
    }

    // Initialize tracing. In order to view logs, run `RUST_LOG=info cargo run`
    tracing_subscriber::fmt()
        .with_env_filter(tracing_subscriber::filter::EnvFilter::from_default_env())
        .init();

    let program_id_le: Vec<u8> = GAME_REPLAY_ID
    .clone()
    .into_iter()
    .map(|n| n.to_le_bytes())
    .flatten()
    .collect();

    println!("Program ID: 0x{}", hex::encode(program_id_le));

    // An executor environment describes the configurations for the zkVM
    // including program inputs.
    // An default ExecutorEnv can be created like so:
    // `let env = ExecutorEnv::builder().build().unwrap();`
    // However, this `env` does not have any inputs.
    //
    // To add guest input to the executor environment, use
    // ExecutorEnvBuilder::write().
    // To access this method, you'll need to use ExecutorEnv::builder(), which
    // creates an ExecutorEnvBuilder. When you're done adding input, call
    // ExecutorEnvBuilder::build().

    // For example:
    // let input: u32 = 15 * u32::pow(2, 27) + 1;
    let mut input: Vec<Position> = Vec::new();
    input.push(Position{ horizontal: 0, vertical: 10 });
    input.push(Position{ horizontal: 2, vertical: 10 });
    input.push(Position{ horizontal: 3, vertical: 10 });
    input.push(Position{ horizontal: 4, vertical: 10 });
    input.push(Position{ horizontal: 5, vertical: 10 });
    input.push(Position{ horizontal: 6, vertical: 10 });
    let env = ExecutorEnv::builder()
        .write(&input)
        .expect("Error while writing program input")
        .build()
        .expect("Error while building executor environment");

    // Obtain the default prover.
    let prover = default_prover();

    // Proof information by proving the specified ELF binary.
    // This struct contains the receipt along with statistics about execution of the guest
    let prove_info = prover
        .prove(env, GAME_REPLAY_ELF)
        .expect("Error while generating proof");

    // extract the receipt.
    let receipt = prove_info.receipt;

    // For example:
    let _output: u32 = receipt.journal.decode().expect("Error while decoding program execution output");

    println!("Program output: {}", _output);


    // The receipt was verified at the end of proving, but the below code is an
    // example of how someone else could verify this receipt.
    receipt
        .verify(GAME_REPLAY_ID)
        .expect("Error while verifying proof");


    // Serialize proof into bincode (format used by sp1)
    // let proof = bincode::serialize(&proof).expect("Failed to serialize proof");

    let verification_data = VerificationData {
        proving_system: ProvingSystemId::Risc0,
        proof: bincode::serialize(&receipt.inner).expect("Error in inner proof serialization"),
        proof_generator_addr: wallet.address(),
        vm_program_code: Some(convert(&GAME_REPLAY_ID).to_vec()),
        verification_key: None,
        pub_input: Some(receipt.journal.bytes.clone()),
    };

    let max_fee = estimate_fee(RPC_URL, PriceEstimate::Instant)
        .await
        .expect("failed to fetch gas price from the blockchain");

    let max_fee_string = ethers::utils::format_units(max_fee, 18).unwrap();

    if !Confirm::with_theme(&dialoguer::theme::ColorfulTheme::default())
        .with_prompt(format!("Aligned will use at most {max_fee_string} eth to verify your proof. Do you want to continue?"))
        .interact()
        .expect("Failed to read user input")
    {   return; }

    let nonce = get_next_nonce(RPC_URL, wallet.address(), NETWORK)
        .await
        .expect("Failed to get next nonce");

    println!("Submitting your proof...");

    println!("Wallet address: {}", wallet.address());

    // let aligned_verification_data = submit_and_wait_verification(
    //     BATCHER_URL,
    //     RPC_URL,
    //     NETWORK,
    //     &verification_data,
    //     max_fee,
    //     wallet.clone(),
    //     nonce,
    // )
    // .await
    // .unwrap();

    // println!(
    //     "Proof submitted and verified successfully on batch {}",
    //     hex::encode(aligned_verification_data.batch_merkle_root)
    // );

    let aligned_verification_data_result = submit_and_wait_verification(
        BATCHER_URL,
        RPC_URL,
        NETWORK,
        &verification_data,
        max_fee,
        wallet.clone(),
        nonce,
    )
    .await;

    match aligned_verification_data_result {
        Ok(aligned_verification_data) => {
            println!(
                "Proof submitted and verified successfully on batch {}",
                hex::encode(aligned_verification_data.batch_merkle_root)
            );
        },
        Err(error) => {
            println!("submit_and_wait_verification error: {}", error);
        }
    }

}

// Convert u32 array to u8 array for storage
pub fn convert(data: &[u32; 8]) -> [u8; 32] {
    let mut res = [0; 32];
    for i in 0..8 {
        res[4 * i..4 * (i + 1)].copy_from_slice(&data[i].to_le_bytes());
    }
    res
}

async fn upload_steps_amount_with_verified_proof(
    aligned_verification_data: &AlignedVerificationData,
    signer: SignerMiddleware<Provider<Http>, LocalWallet>,
    verifier_contract_addr: &Address,
    program_id_le: Vec<u8>,
    public_input_bytes: Vec<u8>
) -> anyhow::Result<()> {
    let verifier_contract = BugVerificationContract::new(*verifier_contract_addr, signer.into());

    let index_in_batch = U256::from(aligned_verification_data.index_in_batch);
    let merkle_path = Bytes::from(
        aligned_verification_data
            .batch_inclusion_proof
            .merkle_path
            .as_slice()
            .into_iter().flatten()
            // .flatten()
            // .to_vec(),
            .collect(),
    );

    let receipt = verifier_contract

        // bytes32 proofCommitment,
        // bytes32 pubInputCommitment,
        // bytes32 programIdCommitment,
        // bytes20 proofGeneratorAddr,
        // bytes32 batchMerkleRoot,
        // bytes memory merkleProof,
        // uint256 verificationDataBatchIndex,
        // bytes memory pubInputBytes

        .verify_batch_inclusion(
            aligned_verification_data
                .verification_data_commitment
                .proof_commitment,
            aligned_verification_data
                .verification_data_commitment
                .pub_input_commitment,
            program_id_le.into(),
            aligned_verification_data
                .verification_data_commitment
                .proof_generator_addr,
            aligned_verification_data.batch_merkle_root,
            merkle_path,
            index_in_batch,
            public_input_bytes
        )

        // .verify_batch_inclusion(
        //     aligned_verification_data
        //         .verification_data_commitment
        //         .proof_commitment,
        //     aligned_verification_data
        //         .verification_data_commitment
        //         .pub_input_commitment,
        //     aligned_verification_data
        //         .verification_data_commitment
        //         .proving_system_aux_data_commitment,
        //     aligned_verification_data
        //         .verification_data_commitment
        //         .proof_generator_addr,
        //     aligned_verification_data.batch_merkle_root,
        //     merkle_path,
        //     index_in_batch
        // )
        .send()
        .await
        .map_err(|e| anyhow::anyhow!("Failed to send tx {}", e))?
        .await
        .map_err(|e| anyhow::anyhow!("Failed to submit tx {}", e))?;

    match receipt {
        Some(receipt) => {
            println!(
                "Steps amount uploaded successfully. Transaction hash: {:x}",
                receipt.transaction_hash
            );
            Ok(())
        }
        None => {
            anyhow::bail!("Failed to upload steps amount: no receipt");
        }
    }
}