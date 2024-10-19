use std::cell::RefCell;
use std::collections::HashMap;
use std::rc::Rc;
use std::collections::BinaryHeap;
use std::cmp::Ordering;

use crate::map::Map;
use crate::position::Position;

#[derive(PartialEq, Eq, Clone, Debug)]
pub struct PositionDistance {
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

pub struct Bug {
    map_ref: Rc<RefCell<Map>>,
    current_position: Position,
}

impl Bug {
    pub fn new(map_ref: Rc<RefCell<Map>>, initial_position: Position) -> Bug {
        Bug { map_ref, current_position: initial_position }
    }

    // Moves the bug, returning it's new position
    pub fn move_tile(&mut self) -> Position {
        // Dijkstra's start
        let map_ref = self.map_ref.borrow();
        let mut distance: HashMap<Position, usize> = HashMap::new();
        let mut previous: HashMap<Position, Position> = HashMap::new();
        let mut min_heap = BinaryHeap::<PositionDistance>::new();
        distance.insert(self.current_position.clone(), 0);
        min_heap.push(PositionDistance {
            position: self.current_position.clone(),
            distance: 0,
        });

        let mut popped_value_option = min_heap.pop();
        let mut reached_limit: Option<Position> = None;
        while !popped_value_option.is_none() && reached_limit.is_none() {
            let popped_value = popped_value_option.unwrap();
            let current_position = popped_value.position;

            if map_ref.is_limit(&current_position) {
                reached_limit = Some(current_position);
            } else {
                let current_position_neighbors = map_ref.get_neighbors(&current_position);
                for neighbor in current_position_neighbors {
                    let current_position_distance = distance.get(&current_position).expect("The popped value should have a distance");
                    let neighbor_new_distance = *current_position_distance + 1;
                    let should_update_distance;
                    if let Some(neighbor_old_distance) = distance.get(&neighbor) {
                        should_update_distance = *neighbor_old_distance > neighbor_new_distance;
                    } else {
                        should_update_distance = true;
                    }
                    if should_update_distance {
                        distance.insert(neighbor.clone(), neighbor_new_distance);
                        previous.insert(neighbor.clone(), current_position.clone());
                        min_heap.push(PositionDistance {
                            position: neighbor,
                            distance: neighbor_new_distance,
                        });
                    }
                }
            }
            popped_value_option = min_heap.pop();
        }
        // Dijkstra's end

        if let Some(limit) = reached_limit {
            let mut current_tile = limit;
            let mut predecesor = previous.get(&current_tile).expect("The bug's path to exit was broken");
            // Iterates from the limit backwards until it finds the tile that comes after the current bug's position
            while *predecesor != self.current_position {
                current_tile = predecesor.clone();
                predecesor = previous.get(&current_tile).expect("The bug's path to exit was broken");
            }
            self.current_position = current_tile;
        } else {
            // If there is no path to the map's limit, then it goes to the first neighbor returned by the map
            // If the tile has no neighbors then the game should have ended and the move_tile function should never
            // have been called
            self.current_position = map_ref.get_neighbors(&self.current_position)[0].clone();
        }
        self.current_position.clone()
    }

    pub fn get_position(&self) -> &Position {
        &self.current_position
    }

    pub fn is_at_position(&self, position: &Position) -> bool {
        self.current_position == *position
    }

    // Returns true if all it's neighbor tiles are occupied and it's current position is not a limit
    pub fn is_encased(&self) -> bool {
        let map_ref = self.map_ref.borrow();
        !map_ref.is_limit(&self.current_position) && map_ref.get_neighbors(&self.current_position).is_empty()
    }

    pub fn is_at_limit(&self) -> bool {
        let map_ref = self.map_ref.borrow();
        map_ref.is_limit(&self.current_position)
    }
}
