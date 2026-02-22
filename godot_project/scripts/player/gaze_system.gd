extends Node
## GazeSystem - Handles player gaze line and student detection
## Draws dotted line from player to mouse cursor
## Triggers chase when looking at student's front

class_name GazeSystem

# ============================================================================
# GAZE PARAMETERS
# ============================================================================

var max_gaze_distance: float = Constants.GAZE_MAX_DISTANCE * Constants.TILE_SIZE  # 25 tiles in pixels
var gaze_line_width: float = Constants.GAZE_LINE_WIDTH
var can_penetrate_walls: bool = Constants.GAZE_WALL_PENETRATION
var can_penetrate_glass: bool = Constants.GAZE_GLASS_PENETRATION

# Gaze trigger tracking
var gaze_trigger_count: int = 0
var max_message_triggers: int = Constants.GAZE_FIRST_TIME_MESSAGE_COUNT

# ============================================================================
# STATE
# ============================================================================

var player: CharacterBody2D
var current_gaze_start: Vector2 = Vector2.ZERO
var current_gaze_end: Vector2 = Vector2.ZERO
var is_gaze_active: bool = false
var hit_something: bool = false
var hit_student: StudentEntity = null

# ============================================================================
# INITIALIZATION
# ============================================================================

func _init(player_node: CharacterBody2D) -> void:
	player = player_node

# ============================================================================
# GAZE PROCESSING
# ============================================================================

func process_gaze(delta: float) -> void:
	if not player:
		return

	# Get mouse position in world coordinates
	var mouse_pos = player.get_global_mouse_position()
	current_gaze_start = player.global_position

	# Calculate gaze direction and end point
	var gaze_direction = (mouse_pos - current_gaze_start).normalized()
	var max_end_point = current_gaze_start + gaze_direction * max_gaze_distance

	# Perform raycast
	var raycast_result = _perform_gaze_raycast(current_gaze_start, max_end_point)

	if raycast_result:
		current_gaze_end = raycast_result.position
		hit_something = true

		# Check if hit a student entity
		if raycast_result.collider and raycast_result.collider.is_in_group("student_entity"):
			_handle_student_gaze(raycast_result.collider)
		else:
			hit_student = null
	else:
		# No hit, gaze extends to max distance
		current_gaze_end = max_end_point
		hit_something = false
		hit_student = null

	# Update gaze line visual
	is_gaze_active = true
	EventBus.gaze_line_updated.emit(current_gaze_start, current_gaze_end, hit_something)

# ============================================================================
# RAYCAST
# ============================================================================

func _perform_gaze_raycast(from: Vector2, to: Vector2) -> Dictionary:
	var space_state = player.get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(from, to)
	query.exclude = [player]
	query.collide_with_areas = false
	query.collide_with_bodies = true

	var result = space_state.intersect_ray(query)

	return result

# ============================================================================
# STUDENT DETECTION
# ============================================================================

func _handle_student_gaze(student: Node) -> void:
	if not student is StudentEntity:
		return

	if not student.is_alive:
		return

	# Check if looking at front or back
	var is_looking_at_front = _is_looking_at_student_front(student)

	if is_looking_at_front:
		# Trigger chase if not already chasing
		if student.current_state != StudentEntity.State.CHASE:
			_trigger_student_chase(student)
			hit_student = student
	else:
		# Looking at back - no effect
		hit_student = null

func _is_looking_at_student_front(student: StudentEntity) -> bool:
	# Get student's facing direction
	var student_facing = _get_student_facing_direction(student)

	# Get direction from student to player
	var to_player = (player.global_position - student.global_position).normalized()

	# Calculate angle between student's facing and player direction
	var dot_product = student_facing.dot(to_player)
	var angle_deg = rad_to_deg(acos(dot_product))

	# Front if angle < 90 degrees
	return angle_deg < Constants.GAZE_FRONT_ANGLE_THRESHOLD

func _get_student_facing_direction(student: StudentEntity) -> Vector2:
	# Get student's movement direction as facing direction
	if student.velocity.length() > 0.1:
		return student.velocity.normalized()
	else:
		# If not moving, assume facing down (default)
		return Vector2(0, 1)

# ============================================================================
# CHASE TRIGGER
# ============================================================================

func _trigger_student_chase(student: StudentEntity) -> void:
	print("Gaze triggered chase on %s" % student.name)

	gaze_trigger_count += 1

	# Show message for first 3 times
	if gaze_trigger_count <= max_message_triggers:
		var message = "시선이 마주쳤다. 이제 저 학생 개체는 죽을 때까지 나를 쫓아올 것이다."
		EventBus.show_system_message.emit(message, 3.0)
	else:
		# Visual effect only (eye icon blink)
		_show_gaze_trigger_effect(student)

	# Emit event
	EventBus.gaze_triggered_chase.emit(student)

	# Tell student to start chasing
	# TODO: Student needs to implement change_state(CHASE) based on this event
	# For now, we'll call it directly if the method exists
	if student.has_method("start_chasing"):
		student.start_chasing()

func _show_gaze_trigger_effect(student: StudentEntity) -> void:
	# TODO Phase 1.6: Add visual eye icon blink effect
	# For now, just print
	print("👁️ Gaze trigger effect on %s" % student.name)

# ============================================================================
# DRAWING
# ============================================================================

func draw_gaze_line(canvas_item: CanvasItem) -> void:
	if not is_gaze_active:
		return

	if not Constants.DEBUG_SHOW_GAZE_LINE:
		return

	# Draw dotted line
	var line_color = Color.WHITE if not hit_something else Color.YELLOW
	if hit_student:
		line_color = Color.RED

	_draw_dotted_line(canvas_item, current_gaze_start, current_gaze_end, line_color)

func _draw_dotted_line(canvas_item: CanvasItem, from: Vector2, to: Vector2, color: Color) -> void:
	var direction = (to - from).normalized()
	var distance = from.distance_to(to)
	var dash_length = 8.0
	var gap_length = 4.0
	var segment_length = dash_length + gap_length

	var current_distance = 0.0
	while current_distance < distance:
		var dash_start = from + direction * current_distance
		var dash_end = from + direction * min(current_distance + dash_length, distance)

		canvas_item.draw_line(dash_start, dash_end, color, gaze_line_width)

		current_distance += segment_length

# ============================================================================
# GETTERS
# ============================================================================

func get_gaze_start() -> Vector2:
	return current_gaze_start

func get_gaze_end() -> Vector2:
	return current_gaze_end

func is_hitting_student() -> bool:
	return hit_student != null

func get_hit_student() -> StudentEntity:
	return hit_student

# ============================================================================
# DEBUG
# ============================================================================

func get_debug_info() -> Dictionary:
	return {
		"gaze_active": is_gaze_active,
		"gaze_distance": "%.1f tiles" % (current_gaze_start.distance_to(current_gaze_end) / Constants.TILE_SIZE),
		"hit_something": hit_something,
		"hit_student": hit_student.name if hit_student else "None",
		"trigger_count": gaze_trigger_count,
	}
