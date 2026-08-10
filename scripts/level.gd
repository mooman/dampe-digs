extends Node2D

@export var level: int
@export var camera: Camera2D
@export var player: CharacterBody2D

func _ready() -> void:
    GameManager.current_level = level
    GameManager.camera = camera
    GameManager.player = player
    print("Bank amount: ", GameManager.bank)
