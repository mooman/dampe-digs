extends Node

@onready var hud_rupees = $HUD/Rupees

# Initial level states
var camera: Camera2D
var player: CharacterBody2D
var current_level: int = 0

var number_of_rupees: int = 0:
  set(value):
    number_of_rupees = value
    hud_rupees.text = str(value)

func add_rupee(how_much: int):
    number_of_rupees = how_much + number_of_rupees

func next_level():
    current_level += 1
    camera.stop()
    $Timers/NextLevelTimer.start()

func game_over():
    camera.stop()
    player.die()
    $Timers/DeathTimer.start()

func restart_level():
    number_of_rupees = 0
    get_tree().change_scene_to_file("res://scenes/level_%d.tscn" % current_level)

func _on_death_timer_timeout() -> void:
    get_tree().change_scene_to_file("res://scenes/game_over.tscn")

func _on_next_level_timer_timeout() -> void:
    restart_level()
