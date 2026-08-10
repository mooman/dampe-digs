extends "res://scripts/menu_item.gd"

enum ItemType { LIGHTNING, SILVER_SHOVEL }
@export var item_type: ItemType

var ITEMS = {
    ItemType.LIGHTNING: {
        'icon': 'lightning',
        'label': 'Lightning',
        'cost': 200,
        'description': 'Speeds up Dampe\nfor one level',
        'powerup': LightningPowerup
    },
    ItemType.SILVER_SHOVEL: {
        'icon': 'silver_shovel',
        'label': 'Silver Shovel',
        'cost': 500,
        'description': 'Doubles shovel strength',
        'powerup': SilverShovelPowerup
    }
}

func _ready() -> void:
    var data = ITEMS[item_type]
    set_display(data.label, data.icon, "Cost: %d rupees\n%s" % [data.cost, data.description])

func on_dig() -> void:
    var data = ITEMS[item_type]
    var powerup_class = data.get('powerup')
    if powerup_class and GameManager.active_powerups.any(func(p): return p.get_script() == powerup_class):
        GameManager.player.show_feedback("Already active!")
        return
    if GameManager.spend(data.cost):
        if powerup_class:
            GameManager.grant_powerup(powerup_class.new())
    else:
        GameManager.player.show_feedback("Not enough rupees!")
