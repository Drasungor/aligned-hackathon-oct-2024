use std::cell::{Ref, RefCell};
use std::rc::Rc;

use crate::game::GameError;
use crate::position::Position;

pub struct Map {
    line_length: usize,
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

        // We define a default leve, this should be replaced in a future version
        lines.push(Map::build_tiles_line(line_length, vec![0]));
        lines.push(Map::build_tiles_line(line_length, vec![4]));
        lines.push(Map::build_tiles_line(line_length, vec![3]));
        lines.push(Map::build_tiles_line(line_length, vec![4]));
        lines.push(Map::build_tiles_line(line_length, vec![1]));
        lines.push(Map::build_tiles_line(line_length, vec![8]));
        lines.push(Map::build_tiles_line(line_length, vec![8]));
        lines.push(Map::build_tiles_line(line_length, vec![8]));
        lines.push(Map::build_tiles_line(line_length, vec![3, 8, 9]));
        lines.push(Map::build_tiles_line(line_length, vec![9]));
        lines.push(Map::build_tiles_line(line_length, vec![1, 9]));

        Map { line_length, lines: Rc::new(RefCell::new(lines)) }
    }

    // Marks a tile as blocked, fails if the position is invalid or the tile is already blocked
    pub fn block_tile(&mut self, position: &Position)  -> Result<(), GameError>{
        let mut lines_ref = self.lines.borrow_mut();
        if !((position.horizontal < self.line_length) && (position.vertical < lines_ref.len())) {
            return Err(GameError::PositionOutOfBounds);
        }
        if !((!lines_ref[position.vertical][position.horizontal])) {
            return Err(GameError::TileAlreadyBlocked);
        }
        lines_ref[position.vertical][position.horizontal] = true;
        Ok(())
    }

    pub fn get_current_map_state(&self) -> Ref<'_, Vec<Vec<bool>>> {
        self.lines.borrow()
    }

    // Indicates if the tile is placed in the border of the map
    pub fn is_limit(&self, position: &Position) -> bool {
        (position.vertical == 0) || (position.vertical == (self.lines.borrow().len() - 1)) ||
        (position.horizontal == 0) || (position.horizontal == (self.line_length - 1))
    }

    // Returns a vector of the tiles adjacent to the received position that are not marked as blocked
    pub fn get_neighbors(&self, position: &Position) -> Vec<Position> {
        let vertical_min: usize;
        let vertical_max: usize;
        let lines_ref = self.lines.borrow();

        let mut neighbors: Vec<Position> = vec![];

        if position.vertical == 0 {
            vertical_min = 0;
        } else {
            vertical_min = position.vertical - 1;
        }

        if position.vertical == (lines_ref.len() - 1) {
            vertical_max = lines_ref.len() - 1;
        } else {
            vertical_max = position.vertical + 1;
        }

        let line_offset = ((position.vertical % 2) as isize) - 1;

        // Due to the hexagonal shape of the tiles, the indexes of neighbors varies with the even-ness
        // of the vertical index
        for i in vertical_min..(vertical_max + 1) {
            for j in 0..2 {
                let current_horizontal: isize;
                if i == position.vertical {
                    current_horizontal = if j == 0 {position.horizontal as isize - 1} else {position.horizontal as isize + 1};
                } else {
                    current_horizontal = position.horizontal as isize + line_offset as isize + j;
                }

                if (current_horizontal >= 0) && (current_horizontal < self.line_length.try_into().unwrap()) {
                    let cast_current_horizontal: usize = current_horizontal.try_into().unwrap();
                    if !lines_ref[i][cast_current_horizontal] {
                        neighbors.push(Position { horizontal: cast_current_horizontal, vertical: i });
                    }
                }
            }
        }
        neighbors
    }

}