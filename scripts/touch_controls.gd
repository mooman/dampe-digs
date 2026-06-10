extends Node

# Swipe left/right to move; hold keeps the direction latched until finger lifts.
# single_tap_dig = false (default): double-tap fires dig.
# single_tap_dig = true: tap-and-release without dragging fires dig.

const DRAG_THRESHOLD: float = 4.0
const DOUBLE_TAP_MS: int = 300

var single_tap_dig: bool = true

var _active_finger: int = -1
var _direction: int = 0
var _last_tap_ms: int = -1
var _did_drag: bool = false
var _pending_dig_release: bool = false


func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        _handle_touch(event)
    elif event is InputEventScreenDrag and event.index == _active_finger:
        _handle_drag(event)


func _handle_touch(event: InputEventScreenTouch) -> void:
    if event.pressed:
        if _active_finger == -1:
            _active_finger = event.index
            _did_drag = false

        if single_tap_dig:
            pass  # dig fires on release below
        else:
            var now := Time.get_ticks_msec()
            if _last_tap_ms >= 0 and now - _last_tap_ms < DOUBLE_TAP_MS:
                _fire_dig()
                _last_tap_ms = -1
            else:
                _last_tap_ms = now
    elif event.index == _active_finger:
        _active_finger = -1
        if single_tap_dig and not _did_drag:
            _fire_dig()
        _set_direction(0)


func _handle_drag(event: InputEventScreenDrag) -> void:
    var dx := event.relative.x
    if abs(dx) > DRAG_THRESHOLD:
        _did_drag = true
    if dx > DRAG_THRESHOLD:
        _set_direction(1)
    elif dx < -DRAG_THRESHOLD:
        _set_direction(-1)
    # Below threshold: hold still keeps the last latched direction


func _set_direction(dir: int) -> void:
    if _direction == dir:
        return
    _direction = dir
    _fire("left", dir == -1)
    _fire("right", dir == 1)


func _fire_dig() -> void:
    _fire("dig", true)
    _pending_dig_release = true


func _process(_delta: float) -> void:
    if _pending_dig_release:
        _pending_dig_release = false
        _fire("dig", false)


func _fire(action: String, pressed: bool) -> void:
    var ev := InputEventAction.new()
    ev.action = action
    ev.pressed = pressed
    Input.parse_input_event(ev)
