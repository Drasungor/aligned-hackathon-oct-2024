extends Node2D

@onready var bug: Node2D = $Bug;
@onready var bug_movement: BugMovement = $Bug/BugMovement;
@onready var map: TileMapLayer = $Map;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bug_movement.set_map(map);
	set_bug_initial_pos(Vector2(1, 0));

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func set_bug_initial_pos(pos: Vector2) -> void:
	var world_position: Vector2 = map.map_to_local(pos)
	bug.position = world_position;
