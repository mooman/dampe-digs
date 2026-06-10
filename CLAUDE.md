# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**Dampe Digs** is a Godot 4.6 2D platformer/digging game. It uses the Mobile rendering method and targets both keyboard and gamepad input.

## Running the Game

Open and run through the Godot editor (version 4.6+):

```bash
godot project.godot               # open in editor
godot --path . scenes/level_1.tscn  # run a level from CLI
```

There are no automated tests or linters — all iteration happens in the Godot editor.

## Architecture

### Level System

Levels use an inheritance pattern: `scenes/level_template.tscn` is the base scene that every level inherits from. `scenes/level_1.tscn` and `scenes/level_2.tscn` each instance it and override the `World` TileMapLayer tile data and place rupees under the `Rupees` Node2D.

`level_template.tscn` composes:
- `World` — `TileMapLayer` (the diggable tilemap), tile_set assigned per-level
- `Camera` — `Camera2D` scripted by `scripts/camera.gd`; auto-scrolls downward at a constant speed and snaps to the player if the player falls faster
- `KILLZONE` — instance of `scenes/killzone.tscn`; a `WorldBoundaryShape2D` Area2D that tracks the top of the camera's visible area and kills the player on contact, then transitions to `scenes/game_over.tscn`
- `GameManager` — instance of `scenes/game_manager.tscn` (also registered as an autoload — see below)
- `Player` — instance of `scenes/player.tscn`
- `Rupees` — `Node2D` container; levels place rupee instances here
- `ZeeWalls` — invisible `StaticBody2D` side walls to keep the player in bounds

### GameManager (Autoload Singleton)

`GameManager` is registered as an autoload in `project.godot`, pointing to `scenes/game_manager.tscn` / `scripts/game_manager.gd`. Access it from any script with just `GameManager` — no `get_node` needed:

```gdscript
GameManager.add_rupee(coin_value)
```

It owns the HUD (`CanvasLayer` → `Label` for rupee count) and tracks `number_of_rupees`.

### Player (`CharacterBody2D`, `scripts/player.gd`)

- Gravity + `left`/`right` movement; no jump
- `dig` action triggers `start_dig()`: plays `"digs"` animation, then checks tile hardness via `tile_data.get_custom_data("hardness")`. Each dig increments a hit counter (`hit_count_per_tile`); the tile is removed (`set_cell(map_coords, -1)`) only when hits reach the hardness value
- `dig_generation` counter cancels in-flight dig coroutines if the player re-presses dig mid-animation
- Tilemap accessed via hardcoded path: `get_node("/root/Game/World")`
- `die()` sets `is_dead = true`, plays `"rip"` animation; called by the killzone

### Rupees

`scenes/rupee.tscn` is the base (scripted by `scripts/rupee.gd`). Green and blue rupees are separate scenes that set `@export var coin_value`. On `_on_body_entered`, they call `GameManager.add_rupee(coin_value)` and play the `"pickup"` animation (which hides the sprite, plays audio, then `queue_free`s).

### ChamberStone (`scripts/chamber_stone.gd`)

An `Area2D` trigger that fires `get_tree().change_scene_to_file(...)` on contact — used to transition between levels. The destination path in `scripts/chamber_stone.gd` is currently a placeholder (`"res://scenes/.tscn"`).

### Game Over (`scenes/game_over.tscn`, `scripts/start_game_over.gd`)

A `Node2D` that listens for the `dig` action to restart: `get_tree().change_scene_to_file("res://scenes/level_1.tscn")`.

## Input Actions (defined in `project.godot`)

- `dig` — Space or gamepad button 2
- `left` / `right` — Arrow keys or left analog stick

## Tile System

- Tile size: 32×32 px
- Atlas: `assets/sprites/tilemap.png`; TileSet resource at `tilesets/world.tres`
- Custom data layer `"hardness"` (int): 1 = soft, 2 = medium, 3 = hard; `-1` marks background/non-solid

## Hardcoded Node Paths

Several scripts use absolute paths that assume the scene root is named `Game`:
- `scripts/player.gd` — `/root/Game/World`
- `scripts/camera.gd` — `/root/Game/Player`
- `scripts/killzone.gd` — `/root/Game/Camera`, `/root/Game/Player`

If the root node is ever renamed these will break. `GameManager` itself should be accessed via the autoload global, not via a node path.
