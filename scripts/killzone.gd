extends Area2D

@export var camera: Camera2D

func _process(delta: float) -> void:
    var half_screen = get_viewport_rect().size.y / 2 / camera.zoom.y
    position.y = camera.position.y - half_screen

#HAHAHA
func _on_body_entered(body: Node2D) -> void:
    GameManager.game_over()
