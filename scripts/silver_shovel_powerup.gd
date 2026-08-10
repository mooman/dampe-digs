class_name SilverShovelPowerup
extends Powerup

# Update this path once the SpriteFrames asset is created in the editor
const SILVER_FRAMES_PATH = "res://assets/silver_shovel_frames.tres"

var _original_frames: SpriteFrames

func apply() -> void:
    var sprite = GameManager.player.get_node("AnimatedSprite2D")
    _original_frames = sprite.sprite_frames
    var silver = load(SILVER_FRAMES_PATH) if ResourceLoader.exists(SILVER_FRAMES_PATH) else null
    if silver:
        sprite.sprite_frames = silver
    GameManager.player.dig_bonus = 1

func remove() -> void:
    var sprite = GameManager.player.get_node("AnimatedSprite2D")
    sprite.sprite_frames = _original_frames
    _original_frames = null
    GameManager.player.dig_bonus = 0
