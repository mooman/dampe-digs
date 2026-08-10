extends CharacterBody2D

const BASE_SPEED = 150.0
const JUMP_VELOCITY = -300

enum State { NORMAL, DIGGING, DEAD }

# Ordered crack-stage atlas coords per material, shown as a tile takes
# non-lethal hits. Materials with no entry here (dirt, amber, gold, iron)
# show no crack visual and just break in one hit as before.
const CRACK_STAGES = {
    "stone": [Vector2i(10, 0)],
    "obsidian": [Vector2i(11, 0), Vector2i(12, 0)],
}

@onready var dialog: Label = $AnimatedSprite2D/Dialog
@onready var ray_cast_down: RayCast2D = $RayCastDown
@onready var animated_sprite = $AnimatedSprite2D
@export var tilemap: TileMapLayer

var state: State = State.NORMAL
var hit_count_per_tile = {}
var dig_generation = 0
var speed: float
var dig_speed_scale: float = 1.0
var dig_bonus: int = 0
var _dialog_locked: bool = false

func _ready() -> void:
    GameManager.player = self
    dialog.visible = false
    speed = BASE_SPEED
    dig_bonus = 0
    GameManager.reapply_powerups()

func handle_input():
    if Input.is_action_just_pressed("dig"):
        start_dig()

# Plays dig animation and removes the tile below on completion.
# Silently ignores input when no tile is below (e.g. mid-air).
# Silently ignores input if a dig is already in progress (state guard below).
# dig_generation still guards against the death case: if the player dies
# mid-dig, this coroutine should bail without touching the tilemap/SFX.
func start_dig():
    if state != State.NORMAL:
        return

    if not ray_cast_down.is_colliding():
        return

    var obj_below = ray_cast_down.get_collider()
    var dig_target_position = global_position

    dig_generation += 1
    var my_generation = dig_generation

    state = State.DIGGING
    animated_sprite.play("digs", dig_speed_scale)
    await animated_sprite.animation_finished

    if my_generation != dig_generation or state == State.DEAD:
        return

    if obj_below == null:
        state = State.NORMAL
        return

    $DigSFX/Dirt.play()

    if obj_below.get_meta('is_item', false):
        # Now we know for sure, it's an item below us
        var item_obj = obj_below.get_node('..')
        item_obj.on_dig()
    else:
        var tile_below = dig_target_position + Vector2(0, 32)
        var map_coords = tilemap.local_to_map(tilemap.to_local(tile_below))
        var tile_data = tilemap.get_cell_tile_data(map_coords)

        if not tile_data:
            state = State.NORMAL
            return

        var hardness = tile_data.get_custom_data("hardness")
        hit_count_per_tile[map_coords] = hit_count_per_tile.get(map_coords, 0) + 1 + dig_bonus

        if hit_count_per_tile[map_coords] >= hardness:
            tilemap.set_cell(map_coords, -1)
            hit_count_per_tile.erase(map_coords)
        else:
            var stages = CRACK_STAGES.get(tile_data.get_custom_data("name"))
            if stages:
                var stage_index = mini(hit_count_per_tile[map_coords] - 1, stages.size() - 1)
                tilemap.set_cell(map_coords, tilemap.get_cell_source_id(map_coords), stages[stage_index], 0)

    state = State.NORMAL

# Kills player
func die():
    state = State.DEAD
    animated_sprite.play("rip")

func open_dialog(text):
    dialog.text = text
    dialog.visible = true

func close_dialog():
    dialog.visible = false

func show_feedback(text: String, duration: float = 1.5) -> void:
    open_dialog(text)
    _dialog_locked = true
    await get_tree().create_timer(duration).timeout
    _dialog_locked = false

func _process(delta: float):
    if _dialog_locked:
        return
    if ray_cast_down.is_colliding():
        var obj_below = ray_cast_down.get_collider()
        if obj_below.get_meta('is_item', false):
            # Now we know for sure, it's an item below us
            var item_obj = obj_below.get_node('..')
            open_dialog(item_obj.item_desc)
        else:
            close_dialog()

func _physics_process(delta: float):
    if state == State.DEAD:
        return

    # Add the gravity.
    if not is_on_floor():
        velocity += get_gravity() * delta

    handle_input()

    var direction := Input.get_axis("left", "right")

    if state == State.NORMAL:
        if direction > 0:
            animated_sprite.flip_h = false
        elif direction < 0:
            animated_sprite.flip_h = true

        if direction:
            velocity.x = direction * speed
        else:
            velocity.x = move_toward(velocity.x, 0, speed)

        if direction == 0:
            animated_sprite.play("idle")
        else:
            animated_sprite.play("run")
    else:
        # Digging (or any other non-NORMAL state): decelerate horizontal
        # motion but don't accept new input, and don't touch flip/animation.
        velocity.x = move_toward(velocity.x, 0, speed)

    move_and_slide()
