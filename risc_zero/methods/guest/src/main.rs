use risc0_zkvm::guest::env;

use serde::{Deserialize, Serialize};
// use serde_derive::{Deserialize, Serialize};
// use serde_json::to_string;


#[derive(Serialize, Deserialize, Debug)]
enum BlockedTile {
    TopLeft,
    TopRight,
    Left,
    Right,
    BottomLeft,
    BottomRight,
}

struct Map {
    // line_length: usize,
    lines: Vec<Vec<bool>>,
}

impl Map {

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

        Map { lines }
    }
}


struct Bug<'a> {
    map_ref: &'a Map,
    horizontal: usize,
    vertical: usize,
}

impl<'a> Bug<'a> {

    pub fn new(map_ref: &'a Map, horizontal: usize, vertical: usize) -> Bug<'a> {
        Bug { map_ref, horizontal, vertical }
    }

    pub fn move_tile() {

    }

    pub fn is_position(&self, horizontal: usize, vertical: usize) -> bool {
        horizontal == self.horizontal && vertical == self.vertical
    }

}


fn main() {
    // TODO: Implement your guest code here

    // read the input
    let input: Vec<BlockedTile> = env::read();

    let map = Map::new();

    let mut bug = Bug::new(&map, 5, 5);

    for blocked_tile in &input {

    }

    // write public output to the journal
    env::commit(&input);
}
