use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, PartialEq, Eq, Hash, Clone, Debug)]
pub struct Position {
    pub horizontal: usize,
    pub vertical: usize,
}
