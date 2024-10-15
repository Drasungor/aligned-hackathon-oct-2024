use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, PartialEq, Eq, Hash, Clone, Debug)]
struct Position {
    horizontal: usize,
    vertical: usize,
}