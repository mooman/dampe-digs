class_name HeadstartPowerup
extends Powerup

func apply() -> void:
    GameManager.camera_start_timer.wait_time = 7.0

func remove() -> void:
    GameManager.camera_start_timer.wait_time = 0.001
