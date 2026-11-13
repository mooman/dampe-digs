extends Area2D

@onready var dampe: CharacterBody2D = $"../../Dampe"


func _on_body_entered(body: Node2D) -> void:
    return
    var viewport_size := get_viewport_rect().size
    
    print(GameManager.player.x, viewport_size)
    GameManager.player.x = viewport_size.x
