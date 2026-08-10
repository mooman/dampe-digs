extends Node2D

var item_desc: String

var item_text: String:
    set(value):
        item_text = value
        $MenuItemLabel.text = value

@onready var icon_sprite = $ItemTypeSprite

func set_display(label: String, icon: String, description: String) -> void:
    item_text = label
    icon_sprite.play(icon)
    item_desc = description

func on_dig() -> void:
    pass
