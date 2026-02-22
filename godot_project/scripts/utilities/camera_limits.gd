extends Node
## Camera Limits Utility
## Sets camera boundaries based on floor dimensions

class_name CameraLimits

## Set camera limits for a given floor
static func set_limits_for_floor(camera: Camera2D, floor: int) -> void:
	match floor:
		Constants.Floor.FLOOR_1:
			_set_limits(camera, 0, 0, 60 * 16, 50 * 16)  # 1F: 60x50 tiles
		Constants.Floor.FLOOR_2:
			_set_limits(camera, 0, 0, 60 * 16, 50 * 16)  # 2F: 60x50 tiles
		Constants.Floor.FLOOR_3:
			_set_limits(camera, 0, 0, 60 * 16, 50 * 16)  # 3F: 60x50 tiles
		Constants.Floor.FLOOR_4:
			_set_limits(camera, 0, 0, 60 * 16, 50 * 16)  # 4F: 60x50 tiles
		Constants.Floor.FLOOR_5:
			_set_limits(camera, 0, 0, 50 * 16, 40 * 16)  # 5F: Auditorium (smaller)
		Constants.Floor.BACKYARD:
			_set_limits(camera, 0, 0, 20 * 16, 15 * 16)  # Backyard: 20x15 tiles
		_:
			_set_limits(camera, 0, 0, 60 * 16, 50 * 16)  # Default

static func _set_limits(camera: Camera2D, left: int, top: int, right: int, bottom: int) -> void:
	camera.limit_left = left
	camera.limit_top = top
	camera.limit_right = right
	camera.limit_bottom = bottom

	print("Camera limits set: [%d, %d] to [%d, %d]" % [left, top, right, bottom])

## Enable camera limits
static func enable_limits(camera: Camera2D) -> void:
	camera.limit_smoothed = true

## Disable camera limits (for cutscenes, etc.)
static func disable_limits(camera: Camera2D) -> void:
	camera.limit_left = -10000000
	camera.limit_top = -10000000
	camera.limit_right = 10000000
	camera.limit_bottom = 10000000
