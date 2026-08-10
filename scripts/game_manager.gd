extends Node

@onready var _hud_rupees_label: Label = $HUD/Rupees

var camera: Camera2D
var player: CharacterBody2D
var current_level: int = 1

# Persistent currency. Sole source of truth for spend(). Survives across
# levels/scenes; only mutated by spend() and finish_level().
var bank: int = 0

# Rupees collected during the current level attempt. Reset to 0 whenever a
# level (re)starts. Only folded into `bank` by finish_level() (reaching the
# chamber stone) -- dying forfeits any rupees collected that run.
var level_rupees: int = 0

var active_powerups: Array = []

func _ready() -> void:
    _update_hud(bank)

# --- Rupee / bank ----------------------------------------------------------

func add_rupee(how_much: int) -> void:
    level_rupees += how_much
    _update_hud(level_rupees)

func spend(amount: int) -> bool:
    if bank < amount:
        return false
    bank -= amount
    _update_hud(bank)
    return true

func _update_hud(value: int) -> void:
    _hud_rupees_label.text = str(value)

# --- Powerups ----------------------------------------------------------

func grant_powerup(p: Powerup) -> void:
    active_powerups.append(p)
    p.apply()

func reapply_powerups() -> void:
    for p in active_powerups:
        p.apply()

func clear_powerups() -> void:
    for p in active_powerups:
        p.remove()
    active_powerups.clear()

# --- Flow / scene transitions --------------------------------------------

# Called when a level's exit chamber is reached. Despite the name, this does
# NOT load the next level directly -- it banks this run's rupees, advances
# the level counter, and routes back to the menu, where the next level is
# actually picked/started.
func finish_level() -> void:
    bank += level_rupees
    level_rupees = 0
    current_level += 1
    return_to_menu()

# Called when the player dies. Rupees collected this run are forfeited (not
# banked) -- only reaching the chamber stone via finish_level() banks rupees.
func game_over() -> void:
    level_rupees = 0
    _update_hud(bank)
    if camera:
        camera.stop()
    if player:
        player.die()
    $Timers/DeathTimer.start()

# Returns to the menu: clears active powerups and stops the camera if set.
func return_to_menu(immediate: bool = false) -> void:
    clear_powerups()
    if camera:
        camera.stop()

    if immediate:
        _on_menu_timer_timeout()
    else:
        $Timers/MenuTimer.start()

# Loads a level immediately. Resets the in-level rupee counter to 0.
func goto_level(level: int = current_level) -> void:
    level_rupees = 0
    _update_hud(level_rupees)
    _change_scene("res://scenes/level_%d.tscn" % level)

# Only real caller is the menu's "Start/Continue" item -- resumes gameplay
# at whatever level was left off on.
func continue_from_menu() -> void:
    goto_level()

# Shared scene-change helper: clears stale camera/player refs at the exact
# moment a transition starts, so nothing can act on a freed scene's nodes.
# Whatever scene loads next reassigns player/camera itself (level.gd and
# player.gd for levels, player.gd for the menu's own Dampe instance).
func _change_scene(path: String) -> void:
    camera = null
    player = null
    get_tree().change_scene_to_file(path)

func _on_death_timer_timeout() -> void:
    _change_scene("res://scenes/game_over.tscn")

func _on_menu_timer_timeout() -> void:
    _update_hud(bank)
    _change_scene("res://scenes/menu_screen.tscn")
