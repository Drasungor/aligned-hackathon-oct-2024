use std::cell::{Ref, RefCell};
use std::rc::Rc;

use crate::bug::Bug;
use crate::map::Map;
use crate::position::Position;

pub enum MovementResult {
    GameEnded(bool), // Returned if the game ends, stores true if the bug was trapped and false if he escaped
    NewPosition(Position), // NewPosition
}

pub struct Game {
    map: Rc<RefCell<Map>>,
    bug: Bug,
}

#[derive(Debug)]
pub enum GameError {
    BlockedBugTile,
    PositionOutOfBounds,
    TileAlreadyBlocked,
}

// Game session orchestrator, controls the map and the bug
impl Game {
    pub fn new() -> Game {
        let map = Rc::new(RefCell::new(Map::new()));
        let bug = Bug::new(map.clone(), Position { horizontal: 5,  vertical: 5 });
    
        Game { map, bug }
    }

    pub fn get_map(&self) -> Ref<Map> {
        self.map.borrow()
    }

    pub fn get_bug_position(&self) -> &Position {
        self.bug.get_position()
    }

    // Executes a game loop, returns whether the game has ended (win or lose) or the bug has moved,
    // and his new position in the map
    pub fn change_state(&mut self, blocked_tile: Position) -> Result<MovementResult, GameError> {
        if self.bug.is_at_position(&blocked_tile) {
            return Err(GameError::BlockedBugTile)
        }
        self.map.borrow_mut().block_tile(&blocked_tile)?;
        if self.bug.is_encased() {
            return Ok(MovementResult::GameEnded(true));
        } else if self.bug.is_at_limit() {
            return Ok(MovementResult::GameEnded(false));
        } else {
            return Ok(MovementResult::NewPosition(self.bug.move_tile()));
        }
    }
}
