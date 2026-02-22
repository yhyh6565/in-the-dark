extends Node
## FlashlightSystem - Player flashlight component
## Manages flashlight brightness levels, battery, and cone visual

class_name FlashlightSystem

# ============================================================================
# SIGNALS
# ============================================================================

signal brightness_changed(new_level: BrightnessLevel)
signal battery_changed(current: float, max_battery: float)
signal battery_depleted()
signal flashlight_toggled(is_on: bool)

# ============================================================================
# BRIGHTNESS LEVELS
# ============================================================================

enum BrightnessLevel {
	OFF,      # No light
	WEAK,     # 45° cone, 10 tiles range, 1.0x drain
	MEDIUM,   # 60° cone, 15 tiles range, 1.5x drain
	STRONG    # 75° cone, 20 tiles range, 2.0x drain
}

var current_brightness: BrightnessLevel = BrightnessLevel.OFF

# Brightness configuration (from SYSTEM_BALANCING.md)
const BRIGHTNESS_CONFIG = {
	BrightnessLevel.WEAK: {
		"cone_angle": 45.0,
		"range_tiles": 10.0,
		"drain_multiplier": 1.0
	},
	BrightnessLevel.MEDIUM: {
		"cone_angle": 60.0,
		"range_tiles": 15.0,
		"drain_multiplier": 1.5
	},
	BrightnessLevel.STRONG: {
		"cone_angle": 75.0,
		"range_tiles": 20.0,
		"drain_multiplier": 2.0
	}
}

# ============================================================================
# BATTERY SYSTEM
# ============================================================================

var current_battery: float = Constants.FLASHLIGHT_EMERGENCY_BATTERY  # 600 seconds (10 min)
var max_battery: float = Constants.FLASHLIGHT_EMERGENCY_BATTERY
var battery_drain_per_second: float = 1.0  # Base drain rate

# ============================================================================
# COMPONENTS
# ============================================================================

var player: CharacterBody2D = null
var light_node: PointLight2D = null  # Visual representation

# ============================================================================
# INITIALIZATION
# ============================================================================

func _init(player_node: CharacterBody2D) -> void:
	player = player_node
	name = "FlashlightSystem"

func _ready() -> void:
	# Create Light2D node for visual representation
	_create_light_node()

	print("FlashlightSystem initialized")
	print("Battery: %.1fs (%.1f min)" % [current_battery, current_battery / 60.0])

func _create_light_node() -> void:
	light_node = PointLight2D.new()
	light_node.name = "FlashlightLight"
	light_node.enabled = false
	light_node.energy = 1.0
	light_node.shadow_enabled = true
	light_node.texture_scale = 1.0

	# Use a simple gradient for cone effect
	# TODO: Create proper flashlight texture in Phase 2

	player.add_child(light_node)

# ============================================================================
# FLASHLIGHT CONTROL
# ============================================================================

func process_flashlight(delta: float) -> void:
	# Handle input (F key to cycle brightness)
	if Input.is_action_just_pressed("flashlight"):
		cycle_brightness()

	# Process battery drain
	if is_flashlight_on():
		_drain_battery(delta)

	# Update light visual
	_update_light_visual()

func cycle_brightness() -> void:
	"""Cycle through brightness levels: Off → Weak → Medium → Strong → Off"""
	match current_brightness:
		BrightnessLevel.OFF:
			set_brightness(BrightnessLevel.WEAK)
		BrightnessLevel.WEAK:
			set_brightness(BrightnessLevel.MEDIUM)
		BrightnessLevel.MEDIUM:
			set_brightness(BrightnessLevel.STRONG)
		BrightnessLevel.STRONG:
			set_brightness(BrightnessLevel.OFF)

	print("Flashlight: %s" % BrightnessLevel.keys()[current_brightness])

func set_brightness(level: BrightnessLevel) -> void:
	"""Set specific brightness level"""
	if level != BrightnessLevel.OFF and current_battery <= 0:
		print("Flashlight: Battery depleted, cannot turn on")
		return

	var old_level = current_brightness
	current_brightness = level

	brightness_changed.emit(current_brightness)

	if is_flashlight_on():
		flashlight_toggled.emit(true)
		EventBus.flashlight_turned_on.emit(current_brightness)
	elif old_level != BrightnessLevel.OFF:
		flashlight_toggled.emit(false)
		EventBus.flashlight_turned_off.emit()

func is_flashlight_on() -> bool:
	return current_brightness != BrightnessLevel.OFF and current_battery > 0

# ============================================================================
# BATTERY MANAGEMENT
# ============================================================================

func _drain_battery(delta: float) -> void:
	if current_battery <= 0:
		# Battery depleted
		if current_brightness != BrightnessLevel.OFF:
			set_brightness(BrightnessLevel.OFF)
			battery_depleted.emit()
			EventBus.flashlight_battery_depleted.emit()
			print("Flashlight: Battery depleted!")
		return

	# Calculate drain based on brightness level
	var config = BRIGHTNESS_CONFIG.get(current_brightness, {})
	var drain_multiplier = config.get("drain_multiplier", 1.0)
	var drain_amount = battery_drain_per_second * drain_multiplier * delta

	current_battery -= drain_amount
	current_battery = maxf(current_battery, 0.0)

	battery_changed.emit(current_battery, max_battery)

func recharge_battery(amount: float) -> void:
	"""Add battery charge (from battery items)"""
	var old_battery = current_battery
	current_battery += amount
	current_battery = minf(current_battery, max_battery)

	print("Flashlight: Recharged %.1fs (%.1fs → %.1fs)" % [amount, old_battery, current_battery])
	battery_changed.emit(current_battery, max_battery)

func get_battery_percentage() -> float:
	return (current_battery / max_battery) * 100.0

# ============================================================================
# LIGHT CONE CALCULATIONS
# ============================================================================

func get_cone_angle() -> float:
	"""Get current cone angle in degrees"""
	if not is_flashlight_on():
		return 0.0

	var config = BRIGHTNESS_CONFIG.get(current_brightness, {})
	return config.get("cone_angle", 0.0)

func get_range_pixels() -> float:
	"""Get current range in pixels"""
	if not is_flashlight_on():
		return 0.0

	var config = BRIGHTNESS_CONFIG.get(current_brightness, {})
	var range_tiles = config.get("range_tiles", 0.0)
	return range_tiles * Constants.TILE_SIZE

func get_flashlight_direction() -> Vector2:
	"""Get direction flashlight is pointing (towards mouse)"""
	if not player:
		return Vector2.RIGHT

	var mouse_pos = player.get_global_mouse_position()
	return (mouse_pos - player.global_position).normalized()

func is_position_in_cone(position: Vector2) -> bool:
	"""Check if a position is inside the flashlight cone"""
	if not is_flashlight_on():
		return false

	if not player:
		return false

	var to_position = position - player.global_position
	var distance = to_position.length()

	# Check range
	if distance > get_range_pixels():
		return false

	# Check angle
	var flashlight_dir = get_flashlight_direction()
	var to_pos_dir = to_position.normalized()
	var angle_deg = rad_to_deg(acos(flashlight_dir.dot(to_pos_dir)))

	var half_cone_angle = get_cone_angle() / 2.0

	return angle_deg <= half_cone_angle

# ============================================================================
# VISUAL UPDATE
# ============================================================================

func _update_light_visual() -> void:
	if not light_node:
		return

	if is_flashlight_on():
		light_node.enabled = true

		# Update energy based on brightness
		match current_brightness:
			BrightnessLevel.WEAK:
				light_node.energy = 0.6
			BrightnessLevel.MEDIUM:
				light_node.energy = 0.9
			BrightnessLevel.STRONG:
				light_node.energy = 1.2

		# Update range
		var range_px = get_range_pixels()
		light_node.texture_scale = range_px / 64.0  # Assuming 64px base texture

		# Rotate to face mouse
		var flashlight_dir = get_flashlight_direction()
		light_node.rotation = flashlight_dir.angle()
	else:
		light_node.enabled = false

# ============================================================================
# STUDENT DETECTION (for Frozen state)
# ============================================================================

func get_students_in_cone() -> Array[StudentEntity]:
	"""Get all students currently in flashlight cone"""
	var students_in_cone: Array[StudentEntity] = []

	if not is_flashlight_on():
		return students_in_cone

	# Get all student entities
	var students = get_tree().get_nodes_in_group("student_entity")

	for student in students:
		if student is StudentEntity:
			if is_position_in_cone(student.global_position):
				# Additional raycast to check for walls
				if _has_line_of_sight_to(student.global_position):
					students_in_cone.append(student)

	return students_in_cone

func _has_line_of_sight_to(target_position: Vector2) -> bool:
	"""Check if there's unobstructed line of sight to target"""
	if not player:
		return false

	var space_state = player.get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		player.global_position,
		target_position
	)
	query.collision_mask = Constants.PHYSICS_LAYER_WALLS
	query.collide_with_areas = false
	query.collide_with_bodies = true

	var result = space_state.intersect_ray(query)
	return result.is_empty()  # No wall in the way

# ============================================================================
# DEBUG
# ============================================================================

func get_debug_info() -> Dictionary:
	return {
		"brightness": BrightnessLevel.keys()[current_brightness],
		"battery": "%.1fs (%.1f%%)" % [current_battery, get_battery_percentage()],
		"cone_angle": "%.1f°" % get_cone_angle(),
		"range": "%.1f tiles" % (get_range_pixels() / Constants.TILE_SIZE),
		"is_on": is_flashlight_on()
	}
