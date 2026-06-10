extends Area2D

@export var coin_value: int = 0

func _on_body_entered(body: Node2D) -> void:
    GameManager.add_rupee(coin_value)
    $AnimationPlayer.play("pickup")
