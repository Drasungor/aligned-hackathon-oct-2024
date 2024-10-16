use godot::prelude::*;
use shared::game::Game;

#[derive(GodotClass)]
#[class(base=Object)]
pub struct GameContainer {
    game: Game,
    base: Base<Object>,
}

#[godot_api]
impl IObject for GameContainer {
    fn init(base: Base<Object>) -> Self {
        Self {
            game: Game::new(),
            base
        }
    }
}

#[godot_api]
impl GameContainer {
    #[func]
    fn print_map(&self) {
        for row in self.game.get_map().get_current_map_state().iter() {
            for cell in row.iter() {
                godot_print!("{} ", cell);
            }
            godot_print!("\n");
        }
    }
}
