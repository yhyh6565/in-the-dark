extends AIStateBase
## ChaseState - Student chases player at 6.0 tiles/s
## Chase is permanent until student dies or loses sight for 5+ seconds

class_name ChaseState

# Chase parameters
var chase_speed: float = Constants.STUDENT_SPEED_CHASE  # 6.0 tiles/s (same as player walk)
var chase_release_distance: float = Constants.STUDENT_CHASE_RELEASE_DISTANCE  # 15 tiles
var out_of_sight_timer: float = 0.0
var max_out_of_sight_time: float = 5.0  # 5 seconds

# State tracking
var is_chasing: bool = false
var last_known_player_position: Vector2 = Vector2.ZERO

func _init(entity_node: CharacterBody2D) -> void:
	super._init(entity_node)
	state_name = "Chase"

# ============================================================================
# STATE LIFECYCLE
# ============================================================================

func enter() -> void:
	print("%s entered Chase state" % entity.name)
	is_chasing = true
	out_of_sight_timer = 0.0
	last_known_player_position = GameManager.player_position

	# Emit events
	entity.chase_started.emit()
	EventBus.student_chase_started.emit(entity)

	# Change sprite to red (chasing visual)
	_set_chase_visual(true)

func exit() -> void:
	is_chasing = false

	# Emit events
	entity.chase_ended.emit()
	EventBus.student_chase_ended.emit(entity)

	# Restore normal sprite
	_set_chase_visual(false)

func physics_process(delta: float) -> void:
	if not is_chasing:
		return

	# Update last known position
	if has_line_of_sight_to_player():
		last_known_player_position = GameManager.player_position
		out_of_sight_timer = 0.0
	else:
		out_of_sight_timer += delta

	# Chase towards player (or last known position)
	_process_chase_movement(delta)

# ============================================================================
# CHASE MOVEMENT
# ============================================================================

func _process_chase_movement(delta: float) -> void:
	var target_position = last_known_player_position

	# Use NavigationAgent if available
	if entity.has_node("NavigationAgent2D"):
		var nav_agent: NavigationAgent2D = entity.get_node("NavigationAgent2D")
		nav_agent.target_position = target_position

		if not nav_agent.is_navigation_finished():
			var next_position = nav_agent.get_next_path_position()
			var direction = (next_position - entity.global_position).normalized()
			var speed_pixels = Constants.tiles_per_sec_to_pixels(chase_speed)
			entity.velocity = direction * speed_pixels
		else:
			# Reached last known position
			entity.velocity = Vector2.ZERO
	else:
		# Direct movement without navigation
		var direction = (target_position - entity.global_position).normalized()
		var speed_pixels = Constants.tiles_per_sec_to_pixels(chase_speed)
		entity.velocity = direction * speed_pixels

	entity.move_and_slide()

	# Check collision with player (attack)
	_check_player_collision()

# ============================================================================
# COMBAT
# ============================================================================

func _check_player_collision() -> void:
	# Check if colliding with player
	for i in range(entity.get_slide_collision_count()):
		var collision = entity.get_slide_collision(i)
		var collider = collision.get_collider()

		if collider and collider.is_in_group("player"):
			_attack_player(collider)
			break

func _attack_player(player: Node) -> void:
	# Deal damage to player
	if player.has_method("take_damage"):
		player.take_damage(Constants.STUDENT_ATTACK_DAMAGE, entity.name)
		print("%s attacked player for %d damage" % [entity.name, Constants.STUDENT_ATTACK_DAMAGE])

		# Emit event
		entity.emit_signal("attacked_player")
		EventBus.student_attacked_player.emit(entity)

# ============================================================================
# STATE TRANSITIONS
# ============================================================================

func check_transitions() -> String:
	# Check if frozen by flashlight (Phase 1.8)
	if _is_in_flashlight_beam():
		return "FROZEN"

	# Check if should release chase (out of sight for too long)
	if out_of_sight_timer > max_out_of_sight_time:
		var distance_to_player = get_distance_to_player()
		var distance_in_tiles = distance_to_player / Constants.TILE_SIZE

		if distance_in_tiles > chase_release_distance:
			print("%s released chase (out of sight for %.1fs, distance: %.1f tiles)" % [entity.name, out_of_sight_timer, distance_in_tiles])
			return "PATROL"  # Return to patrol

	return ""  # Stay in chase

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
# VISUAL
# ============================================================================

func _set_chase_visual(chasing: bool) -> void:
	if entity.has_node("Sprite2D"):
		var sprite: Sprite2D = entity.get_node("Sprite2D")

		if chasing:
			# Load chasing sprite (red)
			var chase_texture = load("res://assets/sprites/entities/student_chasing.png")
			if chase_texture:
				sprite.texture = chase_texture
		else:
			# Restore normal sprite (gray)
			var normal_texture = load("res://assets/sprites/entities/student_placeholder.png")
			if normal_texture:
				sprite.texture = normal_texture

# ============================================================================
# DEBUG
# ============================================================================

func get_debug_info() -> Dictionary:
	var base_info = super.get_debug_info()
	base_info["is_chasing"] = is_chasing
	base_info["out_of_sight_time"] = "%.1fs" % out_of_sight_timer
	base_info["last_known_pos"] = last_known_player_position
	base_info["has_line_of_sight"] = has_line_of_sight_to_player()
	return base_info
