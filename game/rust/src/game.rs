use godot::prelude::*;
use std::{collections::HashMap, env, fs::File, path::Path};
use shared::{
    game::{Game, MovementResult},
    position::Position,
};
use serde_json::to_writer;
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
        self.blocked_tiles = Vec::new();
    }

    #[func]
    fn serialize_blocked_tiles(&self, storage_path: GString) {
        let directory_path = storage_path.to_string();
        let chosen_directory_path = Path::new(&directory_path);
        let os_string = chosen_directory_path.join("player_inputs.json").as_os_str().to_os_string();
        let file_path_string = os_string.to_str().expect("Error while building inputs file path");
        let file = File::create(file_path_string).expect("Error in player inputs file creation");
        to_writer(file, &self.blocked_tiles).expect("Error while writing player inputs file");
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
    // pub fn change_state(&mut self, blocked_tile: Vector2i) -> Vector2i {
    pub fn change_state(&mut self, blocked_tile: Vector2i) -> Variant {
        let blocked_tile_position = Position {
            horizontal: blocked_tile.x as usize,
            vertical: blocked_tile.y as usize,
        };
        self.blocked_tiles.push(blocked_tile_position.clone());
        let change_state_result = self.game.change_state(blocked_tile_position).expect("Error while changing game state");
        // match self.game.change_state(blocked_tile_position) {
        match change_state_result {
            // MovementResult::GameEnded(ended) => panic!("Game ended: {}", ended),
            MovementResult::GameEnded(ended) => Variant::from(ended),
            MovementResult::NewPosition(Position { horizontal, vertical }) 
                // => Vector2i::new(horizontal as i32, vertical as i32),
                => Variant::from(Vector2i::new(horizontal as i32, vertical as i32)),
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
