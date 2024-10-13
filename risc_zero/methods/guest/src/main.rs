use risc0_zkvm::guest::env;

use serde::{Deserialize, Serialize};
// use serde_derive::{Deserialize, Serialize};
// use serde_json::to_string;

use std::cell::RefCell;
use std::rc::Rc;

#[derive(Serialize, Deserialize, Debug)]
enum BlockedTile {
    TopLeft,
    TopRight,
    Left,
    Right,
    BottomLeft,
    BottomRight,
}


#[derive(Serialize, Deserialize, PartialEq, Debug)]
struct Position {
    horizontal: usize,
    vertical: usize,
}


struct Map {
    line_length: usize,
    lines: Vec<Vec<bool>>,
}

impl Map {

    // Occupied tiles store true
    fn build_tiles_line(line_length: usize, blocked_indexes: Vec<usize>) -> Vec<bool> {
        let mut built_line = vec![false; line_length];
        for blocked_tile in 0..blocked_indexes.len() {
            built_line[blocked_indexes[blocked_tile]] = true;
        }
        built_line
    }

    pub fn new() -> Map {
        let mut lines: Vec<Vec<bool>> = vec![];
        let line_length = 11;

        lines.push(Map::build_tiles_line(line_length, vec![0]));
        lines.push(Map::build_tiles_line(line_length, vec![4]));
        lines.push(Map::build_tiles_line(line_length, vec![3]));
        lines.push(Map::build_tiles_line(line_length, vec![4]));
        lines.push(Map::build_tiles_line(line_length, vec![1]));
        lines.push(Map::build_tiles_line(line_length, vec![8]));
        lines.push(Map::build_tiles_line(line_length, vec![8]));
        lines.push(Map::build_tiles_line(line_length, vec![8]));
        lines.push(Map::build_tiles_line(line_length, vec![3, 8, 9]));
        lines.push(Map::build_tiles_line(line_length, vec![1, 9]));

        Map { line_length, lines }
    }

    pub fn block_tile(&mut self, position: &Position) {
        assert!((position.horizontal < self.line_length) && (position.vertical < self.lines.len()), "Out of bounds position");
        assert!((!self.lines[position.vertical][position.horizontal]), "Position already blocked");
        self.lines[position.vertical][position.horizontal] = true;
    }
}


// struct Bug<'a> {
struct Bug {
    // map_ref: &'a mut Map,
    map_ref: Rc<RefCell<Map>>,
    current_position: Position,
}

// impl<'a> Bug<'a> {
impl Bug {

    // pub fn new(map_ref: &'a mut Map, initial_position: Position) -> Bug<'a> {
    pub fn new(map_ref: Rc<RefCell<Map>>, initial_position: Position) -> Bug {
        Bug { map_ref, current_position: initial_position }
    }

    pub fn move_tile() {

    }

    pub fn is_at_position(&self, position: &Position) -> bool {
        // horizontal == self.horizontal && vertical == self.vertical
        self.current_position == *position
    }

}


fn main() {
    // TODO: Implement your guest code here

    // read the input
    // let input: Vec<BlockedTile> = env::read();
    let input: Vec<Position> = env::read();
    
    let mut map = Rc::new(RefCell::new(Map::new()));

    let mut bug = Bug::new(map.clone(), Position { horizontal: 5,  vertical: 5 });

    for blocked_tile in &input {
        assert!(!bug.is_at_position(blocked_tile), "Cannot block the bug's tile");
        map.borrow_mut().block_tile(blocked_tile);
    }

    // write public output to the journal
    env::commit(&input);
}
