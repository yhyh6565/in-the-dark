extends Node
## PlayerMovement - Handles player movement and speed states
## Walk: 6.0 tiles/s, Run: 9.0 tiles/s, Crouch: 3.0 tiles/s

class_name PlayerMovement

# ============================================================================
# MOVEMENT STATE
# ============================================================================

enum MovementState {
	IDLE,
	WALKING,
	RUNNING,
	CROUCHING
}

var current_state: MovementState = MovementState.IDLE
var velocity: Vector2 = Vector2.ZERO
var movement_direction: Vector2 = Vector2.ZERO
var is_moving: bool = false

# ============================================================================
# REFERENCES
# ============================================================================

var player: CharacterBody2D
var animation_state: String = "idle"

# ============================================================================
# INITIALIZATION
# ============================================================================

func _init(player_node: CharacterBody2D) -> void:
	player = player_node

# ============================================================================
# MOVEMENT PROCESSING
# ============================================================================

func process_movement(delta: float) -> void:
	# Get input direction
	movement_direction = _get_input_direction()

	# Determine movement state based on input
	_update_movement_state()

	# Calculate velocity based on state
	var target_speed = _get_current_speed()

	if movement_direction != Vector2.ZERO:
		# Normalize diagonal movement to prevent faster diagonal speed
		var normalized_direction = movement_direction.normalized()
		velocity = normalized_direction * Constants.tiles_per_sec_to_pixels(target_speed)
		is_moving = true
	else:
		# Stop smoothly
		velocity = Vector2.ZERO
		is_moving = false

	# Apply velocity to CharacterBody2D
	player.velocity = velocity
	player.move_and_slide()

	# Update animation state
	_update_animation_state()

# ============================================================================
# INPUT HANDLING
# ============================================================================

func _get_input_direction() -> Vector2:
	var direction = Vector2.ZERO

	# 8-directional movement (WASD)
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1

	return direction

func _is_running_input() -> bool:
	return Input.is_action_pressed("run")

func _is_crouching_input() -> bool:
	return Input.is_action_pressed("crouch")

# ============================================================================
# STATE MANAGEMENT
# ============================================================================

func _update_movement_state() -> void:
	if movement_direction == Vector2.ZERO:
		current_state = MovementState.IDLE
		return

	# Priority: Crouch > Run > Walk
	if _is_crouching_input():
		current_state = MovementState.CROUCHING
	elif _is_running_input():
		current_state = MovementState.RUNNING
	else:
		current_state = MovementState.WALKING

func _get_current_speed() -> float:
	match current_state:
		MovementState.IDLE:
			return 0.0
		MovementState.WALKING:
			return Constants.PLAYER_SPEED_WALK  # 6.0 tiles/s
		MovementState.RUNNING:
			return Constants.PLAYER_SPEED_RUN  # 9.0 tiles/s
		MovementState.CROUCHING:
			return Constants.PLAYER_SPEED_CROUCH  # 3.0 tiles/s
		_:
			return Constants.PLAYER_SPEED_WALK

func get_current_speed_tiles_per_sec() -> float:
	return _get_current_speed()

func get_current_speed_pixels_per_sec() -> float:
	return Constants.tiles_per_sec_to_pixels(_get_current_speed())

# ============================================================================
# ANIMATION STATE
# ============================================================================

func _update_animation_state() -> void:
	var new_state = "idle"

	if is_moving:
		match current_state:
			MovementState.WALKING:
				new_state = "walk"
			MovementState.RUNNING:
				new_state = "run"
			MovementState.CROUCHING:
				new_state = "crouch"

	if new_state != animation_state:
		animation_state = new_state
		# Emit signal for animation player (will be connected in player_controller.gd)
		if player.has_signal("animation_state_changed"):
			player.emit_signal("animation_state_changed", animation_state)

func get_animation_state() -> String:
	return animation_state

# ============================================================================
# DIRECTION & FACING
# ============================================================================

func get_movement_direction() -> Vector2:
	return movement_direction.normalized() if movement_direction != Vector2.ZERO else Vector2.ZERO

func get_facing_direction() -> Vector2:
	# Return normalized movement direction, or last facing direction
	if movement_direction != Vector2.ZERO:
		return movement_direction.normalized()
	else:
		# Return default facing (down) or store last facing
		return Vector2(0, 1)

func get_movement_angle() -> float:
	var dir = get_movement_direction()
	if dir == Vector2.ZERO:
		return 0.0
	return dir.angle()

# ============================================================================
# STATE QUERIES
# ============================================================================

func is_idle() -> bool:
	return current_state == MovementState.IDLE

func is_walking() -> bool:
	return current_state == MovementState.WALKING

func is_running() -> bool:
	return current_state == MovementState.RUNNING

func is_crouching() -> bool:
	return current_state == MovementState.CROUCHING

# ============================================================================
# DEBUG
# ============================================================================

func get_debug_info() -> Dictionary:
	return {
		"state": MovementState.keys()[current_state],
		"speed_tiles": "%.1f tiles/s" % get_current_speed_tiles_per_sec(),
		"speed_pixels": "%.1f px/s" % get_current_speed_pixels_per_sec(),
		"velocity": velocity,
		"direction": movement_direction,
		"is_moving": is_moving,
	}
