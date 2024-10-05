use godot::prelude::*;

mod entities;

struct MyExtension;

#[gdextension]
unsafe impl ExtensionLibrary for MyExtension {}
