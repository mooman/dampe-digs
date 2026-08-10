extends "res://scripts/menu_item.gd"

enum ItemType { NEXT_LEVEL, LEVEL_1, LEVEL_2, LEVEL_3, LEVEL_4 }
@export var item_type: ItemType

var data

const ITEMS = {
    ItemType.NEXT_LEVEL: {
        'icon': 'none',
        'label': 'Start',
        'description': 'Start or continue\nnext level',
        'level': 0
    },
    ItemType.LEVEL_1: {
        'icon': 'none',
        'label': 'Level 1',
        'description': 'Go to Level 1',
        'level': 1
    },
    ItemType.LEVEL_2: {
        'icon': 'none',
        'label': 'Level 2',
        'description': 'Go to Level 2',
        'level': 2
    },
    ItemType.LEVEL_3: {
        'icon': 'none',
        'label': 'Level 3',
        'description': 'Go to Level 3',
        'level': 3
    },
    ItemType.LEVEL_4: {
        'icon': 'none',
        'label': 'Level 4',
        'description': 'Go to Level 4',
        'level': 4
    }
}

func _ready() -> void:
    data = ITEMS[item_type]
    set_display(data.label, data.icon, data.description)

func on_dig() -> void:
    if data.level == 0:
        GameManager.continue_from_menu()
    else:
        GameManager.goto_level(data.level)
