use std::cell::{Ref, RefCell};
use std::rc::Rc;

enum MovementResult {
    GameEnded(bool), // Returned if the game ends, stores true if the bug was trapped and false if he escaped
    NewPosition(Position), // NewPosition
}

struct Game {
    map: Rc<RefCell<Map>>,
    bug: Bug,
}

impl Game {
    pub fn new() -> Game {

        let map = Rc::new(RefCell::new(Map::new()));
        let mut bug = Bug::new(map.clone(), Position { horizontal: 5,  vertical: 5 });
    
        Game { map, bug }
    }

    pub fn change_state(blocked_tile: Position) -> Result<MovementResult, ElErrorQueTeGusteMark> {
        assert!(!bug.is_at_position(blocked_tile), "Cannot block the bug's tile");
        map.borrow_mut().block_tile(blocked_tile);
        if bug.is_encased() {
            return MovementResult::GameEnded(true);
        } else if bug.is_at_limit() {
            return MovementResult::GameEnded(false);
        } else {
            return NewPosition(bug.move_tile());
        }
    }

}