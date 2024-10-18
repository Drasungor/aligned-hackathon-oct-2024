// These constants represent the RISC-V ELF and the image ID generated by risc0-build.
// The ELF is used for proving and the ID is used for verification.
use methods::{
    GAME_REPLAY_ELF, GAME_REPLAY_ID
};
use risc0_zkvm::{default_prover, ExecutorEnv};

use shared::position::Position;

fn main() {
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

    // TODO: Implement code for retrieving receipt journal here.

    // For example:
    let _output: u32 = receipt.journal.decode().expect("Error while decoding program execution output");

    // The receipt was verified at the end of proving, but the below code is an
    // example of how someone else could verify this receipt.
    receipt
        .verify(GAME_REPLAY_ID)
        .expect("Error while verifying proof");
}
