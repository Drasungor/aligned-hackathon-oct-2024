use godot::prelude::*;
use std::{collections::HashMap, env};
use shared::{
    game::{Game, MovementResult},
    position::Position,
};
use crate::ethereum;

#[derive(GodotClass)]
#[class(base=Object)]
pub struct GameContainer {
    game: Game,
    base: Base<Object>,
    blocked_tiles: Vec<Position>,
}

#[godot_api]
impl IObject for GameContainer {
    fn init(base: Base<Object>) -> Self {
        Self {
            game: Game::new(),
            base,
            blocked_tiles: Vec::new(),
        }
    }
}

#[godot_api]
impl GameContainer {
    #[func]
    fn reset(&mut self) {
        self.game = Game::new();
    }

    #[func]
    fn serialize_blocked_tiles(&self, storage_path: GString) {
        // self.blocked_tiles
        let path = env::current_dir().expect("Get current directory failed");
        godot_print!("The current directory is {}", path.display());
    }

    #[func]
    fn get_bug_position(&self) -> Vector2i {
        let bug_position = self.game.get_bug_position();
        Vector2i::new(bug_position.horizontal as i32, bug_position.vertical as i32)
    }

    #[func]
    fn get_blocked_tiles(&self) -> Array<Vector2i> {
        self.game.get_map().get_current_map_state().iter().enumerate().flat_map(|(vertical, line)| {
            line.iter().enumerate().filter_map(move |(horizontal, blocked)| {
                if *blocked {
                    Some(Vector2i::new(horizontal as i32, vertical as i32))
                } else {
                    None
                }
            })
        }).collect()
    }

    #[func]
    pub fn change_state(&mut self, blocked_tile: Vector2i) -> Vector2i {
        let blocked_tile_position = Position {
            horizontal: blocked_tile.x as usize,
            vertical: blocked_tile.y as usize,
        };
        self.blocked_tiles.push(blocked_tile_position.clone());
        match self.game.change_state(blocked_tile_position) {
            MovementResult::GameEnded(ended) => panic!("Game ended: {}", ended),
            MovementResult::NewPosition(Position { horizontal, vertical }) 
                => Vector2i::new(horizontal as i32, vertical as i32),
        }
    }

    #[func]
    pub fn get_leaderboad(&self) -> Array<Dictionary> {
    // pub fn get_leaderboad() -> Array<Dictionary> {
        let records = ethereum::get_record_holders();

        let mut leaderboard = Array::new();

        for record in records {
            let mut dict = Dictionary::new();
            dict.set("steps_amount", record.stepsAmount);
            dict.set("record_holder", record.recordHolder);
            dict.set("updates_counter", record.updatesCounter);
            leaderboard.push(dict);
        } 

        leaderboard
    }
}
