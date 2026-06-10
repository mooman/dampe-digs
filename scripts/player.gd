extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -300

@onready var animated_sprite = $AnimatedSprite2D
@export var tilemap: TileMapLayer

var is_dead = false
var hit_count_per_tile = {}
var dig_generation = 0

func handle_input():
    if Input.is_action_just_pressed("dig"):
        start_dig()

# Plays dig animation and removes the tile below on completion.
# Silently ignores input when no tile is below (e.g. mid-air).
# Re-pressing dig mid-animation cancels the current dig and restarts it
# dig_generation detects this: if it changed while awaiting, the old coroutine bails.
func start_dig():
    var tile_below = global_position + Vector2(0, 32)
    var map_coords = tilemap.local_to_map(tilemap.to_local(tile_below))
    var tile_data = tilemap.get_cell_tile_data(map_coords)

    if not tile_data:
        return

    dig_generation += 1
    var my_generation = dig_generation
    
    animated_sprite.play("digs")
    await animated_sprite.animation_finished

    if my_generation != dig_generation or is_dead:
        return
        
    $DigSFX/Dirt.play()
    
    var hardness = tile_data.get_custom_data("hardness")
    hit_count_per_tile[map_coords] = hit_count_per_tile.get(map_coords, 0) + 1

    if hit_count_per_tile[map_coords] == hardness:
        tilemap.set_cell(map_coords, -1)
        hit_count_per_tile.erase(map_coords)

    animated_sprite.play("idle")
    
# Kills player
func die():
    is_dead = true
    animated_sprite.play("rip")

func _physics_process(delta: float):
    if is_dead:
        return
        
    # Add the gravity.
    if not is_on_floor():
        velocity += get_gravity() * delta

    handle_input()

    # Get the input direction and handle the movement/deceleration.
    # As good practice, you should replace UI actions with custom gameplay actions.
    var direction := Input.get_axis("left", "right")
    if direction:
        velocity.x = direction * SPEED
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)

    move_and_slide()     
