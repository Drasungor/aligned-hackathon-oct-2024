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
    line_length: usize,
    lines: Vec<Vec<bool>>,
}

struct Bug {
    map_ref: &Map,
    horizontal: usize,
    vertical: usize,
}

impl Bug {

    fn new(map_ref: &Map, horizontal: usize, vertical: usize) -> Bug {
        Bug { map_ref, horizontal: 4, vertical: 4 }
    }

    fn move() {

    }

}


fn main() {
    // TODO: Implement your guest code here

    // read the input
    let input: Vec<BlockedTile> = env::read();

    let mut cat_position = CatPosition { horizontal: 4, vertical: 4 };



    for blocked_tile in &input {

    }

    // write public output to the journal
    env::commit(&input);
}
