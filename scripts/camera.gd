extends Camera2D

@export var camera_speed: float = 30
@export var player: CharacterBody2D

var is_moving = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void: 
    var screen_height := get_viewport_rect().size.y / zoom.y
    var target_y := player.position.y + screen_height / 8
    
    if is_moving:
        position.y = maxf(position.y + camera_speed * delta, target_y)
    else:
        position.y = target_y

func stop():
    is_moving = false

func start():
    is_moving = true

    
