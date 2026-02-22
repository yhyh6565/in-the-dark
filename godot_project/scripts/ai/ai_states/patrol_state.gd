extends AIStateBase
## PatrolState - Student wanders randomly at 2.0 tiles/s
## Picks random waypoints and moves between them

class_name PatrolState

# Patrol parameters
var patrol_speed: float = Constants.STUDENT_SPEED_PATROL  # 2.0 tiles/s
var current_target: Vector2 = Vector2.ZERO
var wait_time: float = 0.0
var max_wait_time: float = 3.0  # Wait 2-5 seconds at waypoint
var waypoint_radius: float = 160.0  # 10 tiles in pixels

# State tracking
var is_waiting: bool = false
var has_target: bool = false

# Floor bounds (set by student_ai.gd)
var floor_bounds: Rect2 = Rect2()

func _init(entity_node: CharacterBody2D) -> void:
	super._init(entity_node)
	state_name = "Patrol"

# ============================================================================
# STATE LIFECYCLE
# ============================================================================

func enter() -> void:
	print("%s entered Patrol state" % entity.name)
	_pick_new_waypoint()

func exit() -> void:
	has_target = false
	is_waiting = false

func physics_process(delta: float) -> void:
	if is_waiting:
		_process_waiting(delta)
	else:
		_process_movement(delta)

# ============================================================================
# MOVEMENT
# ============================================================================

func _process_movement(delta: float) -> void:
	if not has_target:
		_pick_new_waypoint()
		return

	# Move towards target
	var direction = (current_target - entity.global_position).normalized()
	var speed_pixels = Constants.tiles_per_sec_to_pixels(patrol_speed)
	entity.velocity = direction * speed_pixels

	# Use NavigationAgent if available
	if entity.has_node("NavigationAgent2D"):
		var nav_agent: NavigationAgent2D = entity.get_node("NavigationAgent2D")
		if nav_agent.is_navigation_finished():
			_arrive_at_waypoint()
		else:
			var next_position = nav_agent.get_next_path_position()
			direction = (next_position - entity.global_position).normalized()
			entity.velocity = direction * speed_pixels
	else:
		# Simple direct movement without navigation
		var distance_to_target = entity.global_position.distance_to(current_target)
		if distance_to_target < Constants.TILE_SIZE:
			_arrive_at_waypoint()

	entity.move_and_slide()

func _process_waiting(delta: float) -> void:
	wait_time -= delta
	entity.velocity = Vector2.ZERO

	if wait_time <= 0:
		is_waiting = false
		_pick_new_waypoint()

# ============================================================================
# WAYPOINT MANAGEMENT
# ============================================================================

func _pick_new_waypoint() -> void:
	# Pick random point within patrol radius
	var attempts = 0
	var max_attempts = 10

	while attempts < max_attempts:
		var angle = randf() * TAU
		var distance = randf() * waypoint_radius
		var potential_target = entity.global_position + Vector2(cos(angle), sin(angle)) * distance

		# Check if within floor bounds
		if _is_within_floor_bounds(potential_target):
			current_target = potential_target
			has_target = true

			# Set navigation target if NavigationAgent exists
			if entity.has_node("NavigationAgent2D"):
				var nav_agent: NavigationAgent2D = entity.get_node("NavigationAgent2D")
				nav_agent.target_position = current_target

			break

		attempts += 1

	# If failed to find valid point, wait a bit
	if attempts >= max_attempts:
		_arrive_at_waypoint()

func _arrive_at_waypoint() -> void:
	has_target = false
	is_waiting = true
	wait_time = randf_range(2.0, max_wait_time)
	entity.velocity = Vector2.ZERO

func _is_within_floor_bounds(position: Vector2) -> bool:
	if floor_bounds.has_area():
		return floor_bounds.has_point(position)
	return true  # No bounds set, allow anywhere

# ============================================================================
# STATE TRANSITIONS
# ============================================================================

func check_transitions() -> String:
	# Check if frozen by flashlight (Phase 1.8)
	if _is_in_flashlight_beam():
		return "FROZEN"

	# Gaze trigger handled by GazeSystem calling student.start_chasing()
	# (implemented in Phase 1.6)
	return ""

func _is_in_flashlight_beam() -> bool:
	"""Check if this student is in player's flashlight beam"""
	var players = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return false

	var player = players[0]
	if not player.has_node("FlashlightSystem"):
		return false

	var flashlight: FlashlightSystem = player.get_node("FlashlightSystem")
	return flashlight.is_position_in_cone(entity.global_position)

# ============================================================================
# CONFIGURATION
# ============================================================================

func set_floor_bounds(bounds: Rect2) -> void:
	floor_bounds = bounds
	print("%s patrol bounds set: %s" % [entity.name, bounds])

# ============================================================================
# DEBUG
# ============================================================================

func get_debug_info() -> Dictionary:
	var base_info = super.get_debug_info()
	base_info["is_waiting"] = is_waiting
	base_info["wait_time"] = "%.1fs" % wait_time if is_waiting else "N/A"
	base_info["has_target"] = has_target
	base_info["target"] = current_target if has_target else Vector2.ZERO
	return base_info
