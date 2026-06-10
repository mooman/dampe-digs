extends Camera2D

@export var camera_speed: float = 30
@export var player: CharacterBody2D

var is_stop = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if is_stop:
        return

    var screen_height := get_viewport_rect().size.y / zoom.y
    var target_y := player.position.y + screen_height / 8
    position.y = maxf(position.y + camera_speed * delta, target_y)

func start():
    is_stop = false

func stop():
    is_stop = true

    
