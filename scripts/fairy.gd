class_name FairyPowerup
extends Powerup

func apply() -> void:
    GameManager.fairy = true

func remove() -> void:
    GameManager.fairy = false
