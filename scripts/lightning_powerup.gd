class_name LightningPowerup
extends Powerup

func apply() -> void:
    GameManager.player.speed *= 1.5
    GameManager.player.dig_speed_scale = 1.5

func remove() -> void:
    GameManager.player.speed /= 1.5
    GameManager.player.dig_speed_scale = 1.0
