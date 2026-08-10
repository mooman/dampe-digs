extends Node2D

func _process(delta: float) -> void:
    if Input.is_action_just_pressed("dig"):
        GameManager.return_to_menu(true)
