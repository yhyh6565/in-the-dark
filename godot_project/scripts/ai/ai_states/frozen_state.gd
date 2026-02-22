extends AIStateBase
## FrozenState - Student is frozen by flashlight beam
## Student stops all movement when in flashlight cone
## Resumes previous state when light turns off or leaves cone

class_name FrozenState

# ============================================================================
# STATE TRACKING
# ============================================================================

var previous_state: String = "PATROL"  # State to return to when unfrozen
var freeze_timer: float = 0.0

func _init(entity_node: CharacterBody2D) -> void:
	super._init(entity_node)
	state_name = "Frozen"

# ============================================================================
# STATE LIFECYCLE
# ============================================================================

func enter() -> void:
	print("%s entered Frozen state" % entity.name)
	freeze_timer = 0.0

	# Stop all movement
	entity.velocity = Vector2.ZERO

	# Emit events
	entity.frozen.emit()
	EventBus.student_frozen.emit(entity)

	# Visual feedback (turn blue-ish to indicate frozen)
	_set_frozen_visual(true)

func exit() -> void:
	# Emit events
	entity.unfrozen.emit()
	EventBus.student_unfrozen.emit(entity)

	# Restore normal visual
	_set_frozen_visual(false)

	print("%s exited Frozen state, returning to %s" % [entity.name, previous_state])

func physics_process(delta: float) -> void:
	# Remain frozen - no movement
	entity.velocity = Vector2.ZERO
	entity.move_and_slide()

	freeze_timer += delta

# ============================================================================
# STATE TRANSITIONS
# ============================================================================

func check_transitions() -> String:
	# Check if still in flashlight beam
	if not _is_in_flashlight_beam():
		# No longer in beam - return to previous state
		return previous_state

	# Stay frozen
	return ""

func set_previous_state(state_name: String) -> void:
	"""Set which state to return to when unfrozen"""
	previous_state = state_name

# ============================================================================
# FLASHLIGHT DETECTION
# ============================================================================

func _is_in_flashlight_beam() -> bool:
	"""Check if this student is currently in player's flashlight beam"""
	# Get player
	var players = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return false

	var player = players[0]
	if not player.has_node("FlashlightSystem"):
		return false

	var flashlight: FlashlightSystem = player.get_node("FlashlightSystem")

	# Check if this student is in the cone
	return flashlight.is_position_in_cone(entity.global_position)

# ============================================================================
# VISUAL
# ============================================================================

func _set_frozen_visual(frozen: bool) -> void:
	if entity.has_node("Sprite2D"):
		var sprite: Sprite2D = entity.get_node("Sprite2D")

		if frozen:
			# Tint blue to show frozen state
			sprite.modulate = Color(0.5, 0.7, 1.0, 1.0)  # Light blue tint
		else:
			# Restore normal color (will be overridden by state-specific colors)
			sprite.modulate = Color.WHITE

# ============================================================================
# DEBUG
# ============================================================================

func get_debug_info() -> Dictionary:
	var base_info = super.get_debug_info()
	base_info["freeze_time"] = "%.1fs" % freeze_timer
	base_info["previous_state"] = previous_state
	base_info["in_beam"] = _is_in_flashlight_beam()
	return base_info
