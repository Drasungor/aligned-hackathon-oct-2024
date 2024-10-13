use risc0_zkvm::guest::env;

use serde::{Deserialize, Serialize};
// use serde_derive::{Deserialize, Serialize};
// use serde_json::to_string;

use std::cell::{Ref, RefCell};
use std::collections::HashMap;
use std::rc::Rc;
use std::collections::BinaryHeap;
use std::cmp::Ordering;

#[derive(Serialize, Deserialize, Debug)]
enum MovingDirection {
    TopLeft,
    TopRight,
    Left,
    Right,
    BottomLeft,
    BottomRight,
}


#[derive(Serialize, Deserialize, PartialEq, Eq, Hash, Clone, Debug)]
struct Position {
    horizontal: usize,
    vertical: usize,
}


struct Map {
    line_length: usize,
    // lines: Vec<Vec<bool>>,
    lines: Rc<RefCell<Vec<Vec<bool>>>>,
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

        // Map { line_length, lines }
        Map { line_length, lines: Rc::new(RefCell::new(lines)) }
    }

    pub fn block_tile(&mut self, position: &Position) {
        let mut lines_ref = self.lines.borrow_mut();
        // assert!((position.horizontal < self.line_length) && (position.vertical < self.lines.len()), "Out of bounds position");
        // assert!((!self.lines[position.vertical][position.horizontal]), "Position already blocked");
        // self.lines[position.vertical][position.horizontal] = true;

        assert!((position.horizontal < self.line_length) && (position.vertical < lines_ref.len()), "Out of bounds position");
        assert!((!lines_ref[position.vertical][position.horizontal]), "Position already blocked");
        lines_ref[position.vertical][position.horizontal] = true;

    }

    pub fn get_current_map_state(&self) -> Ref<'_, Vec<Vec<bool>>> {
        self.lines.borrow()
    }

    pub fn is_limit(&self, position: &Position) -> bool {
        (position.vertical == 0) || (position.vertical == (self.lines.borrow().len() - 1)) ||
        (position.horizontal == 0) || (position.horizontal == (self.line_length - 1))
    }

    pub fn get_neighbors(&self, position: Position) -> Vec<Position> {
        let vertical_min: usize;
        let vertical_max: usize;

        if position.vertical == 0 {
            vertical_min = 0;
        } else {
            vertical_min = position.vertical - 1;
        }

        if position.vertical == (self.lines.borrow().len() - 1) {
            vertical_max = self.lines.borrow().len() - 1;
        } else {
            vertical_max = position.vertical + 1;
        }

        let line_offset = (position.vertical % 2) - 1;
        
    }

}


#[derive(PartialEq, Eq, Clone, Debug)]
struct PositionDistance {
    position: Position,
    distance: usize,
}


impl Ord for PositionDistance {
    fn cmp(&self, other: &Self) -> Ordering {
        // Reverse the comparison for a min-heap
        other.distance.cmp(&self.distance)
    }
}

impl PartialOrd for PositionDistance {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
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


    pub fn move_tile(&mut self) {
        // self.map_ref.borrow()
        let map_ref = self.map_ref.borrow();
        let current_map_state = map_ref.get_current_map_state();

        let mut distance: HashMap<Position, usize> = HashMap::new();
        let mut previous: HashMap<Position, Position> = HashMap::new();

        distance.insert(self.current_position.clone(), 0);

        let mut min_heap = BinaryHeap::<PositionDistance>::new();

        min_heap.push(PositionDistance {
            position: self.current_position.clone(),
            distance: 0,
        });

        while let Some(poped_value) = min_heap.pop() {
            let current_position = poped_value.position;
        }

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
