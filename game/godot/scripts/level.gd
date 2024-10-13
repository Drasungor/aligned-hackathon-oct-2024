extends Node2D

@onready var bug: BugCharacter = $Bug;
@onready var map: TileMapLayer = $Map;

var timer: float = 0;

const MovingDirectionScript = preload("res://scripts/moving_direction.gd")
const MovingDirection = MovingDirectionScript.MovingDirection

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bug.set_map(map);
	set_bug_initial_pos(Vector2(3, 3));


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta;
	if (timer > 1):
		timer = 0;
		bug.move(MovingDirection.TopLeft)


func set_bug_initial_pos(pos: Vector2) -> void:
	var world_position: Vector2 = map.map_to_local(pos)
	bug.position = world_position;
