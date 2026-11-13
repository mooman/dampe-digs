extends Area2D

func _on_body_entered(body: Node2D) -> void:
    GameManager.stop_bgm()
    $AnimationPlayer.play("pickup")
    GameManager.finish_level()
