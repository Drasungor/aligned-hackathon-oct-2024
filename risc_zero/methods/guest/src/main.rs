use risc0_zkvm::guest::env;
use shared::{game::{Game, GameError, MovementResult}, position::Position};



fn main() {
    // read the input
    let input: Vec<Position> = env::read();
    let mut game_manager = Game::new();
    let mut bug_was_encased: Option<bool> = None; // True if was encased, false if he escaped

    for blocked_tile in &input {
        assert!(bug_was_encased.is_none(), "More movements than necessary to resolve the game were provided");
        let state_change_result = game_manager.change_state(blocked_tile.clone());
        if let Err(reported_error) = state_change_result {
            match reported_error {
                GameError::BlockedBugTile => panic!("Tried to block bug's position"),
                GameError::TileAlreadyBlocked => panic!("Tried to block a blocked tile"),
                GameError::PositionOutOfBounds => panic!("Tried to block a tile with invalid coordinates"),
            }
        }
        match state_change_result.unwrap() {
            MovementResult::GameEnded(player_won) => {
                bug_was_encased = Some(player_won);
            },
            _ => {},
        }
    }
    if let Some(game_result) = bug_was_encased {
        assert!(game_result, "The bug was not encased after completing all movements");
    } else {
        panic!("The game did not come to a resolution after all movements were applied");
    }

    let steps_amount: u32 = input.len().try_into().expect("Error in conversion for steps array length from usize to u32");

    // Commit of the amount of steps until win as the verifier's public input
    env::commit(&steps_amount);
}
