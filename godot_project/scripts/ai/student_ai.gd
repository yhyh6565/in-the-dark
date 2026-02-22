extends CharacterBody2D
## StudentAI - Main student entity controller
## Manages AI state machine and student behavior

class_name StudentEntity

# ============================================================================
# SIGNALS
# ============================================================================

signal died()
signal chase_started()
signal chase_ended()
signal frozen()
signal unfrozen()

# ============================================================================
# AI STATES
# ============================================================================

enum State {
	SLEEPING,   # 30+ tiles away - AI disabled
	DORMANT,    # 10-30 tiles away - check distance only
	PATROL,     # Active patrol
	CHASE,      # Chasing player (Phase 1.7)
	FROZEN,     # Frozen by flashlight (Phase 1.8)
	PRAYER      # Silent prayer movement (Phase 1.13)
}

var current_state: State = State.PATROL
var state_handlers: Dictionary = {}
var active_state: AIStateBase = null

# ============================================================================
# STUDENT STATS
# ============================================================================

var current_hp: int = Constants.STUDENT_MAX_HP
var max_hp: int = Constants.STUDENT_MAX_HP
var is_alive: bool = true

# Assigned floor (students never leave their floor)
var assigned_floor: int = Constants.FLOOR_STARTING

# ============================================================================
# COMPONENTS
# ============================================================================

@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null
@onready var collision_shape: CollisionShape2D = $CollisionShape2D if has_node("CollisionShape2D") else null
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D if has_node("NavigationAgent2D") else null

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready() -> void:
	# Set up collision shape
	if collision_shape and collision_shape.shape == null:
		collision_shape.shape = RectangleShape2D.new()
		collision_shape.shape.size = Constants.STUDENT_HITBOX_SIZE

	# Initialize state handlers
	_setup_state_machine()

	# Start in Patrol state
	change_state(State.PATROL)

	# Connect to EventBus
	EventBus.blackout_started.connect(_on_blackout_started)
	EventBus.prayer_started.connect(_on_prayer_started)

	print("%s initialized on floor %dF" % [name, assigned_floor])

func _setup_state_machine() -> void:
	# Create state handler instances
	state_handlers[State.PATROL] = PatrolState.new(self)
	state_handlers[State.CHASE] = ChaseState.new(self)
	state_handlers[State.FROZEN] = FrozenState.new(self)

	# TODO Phase 1.13+: Add other states
	# state_handlers[State.PRAYER] = PrayerState.new(self)
	# etc.

	# Set floor bounds for patrol state
	var patrol_state: PatrolState = state_handlers[State.PATROL]
	var floor_bounds = _get_floor_bounds()
	patrol_state.set_floor_bounds(floor_bounds)

func _get_floor_bounds() -> Rect2:
	# Get bounds for assigned floor (prevent leaving floor)
	# For now, use standard 60x50 tile bounds
	return Rect2(
		Constants.TILE_SIZE * 2,  # Leave 2 tile margin
		Constants.TILE_SIZE * 2,
		Constants.TILE_SIZE * 56,  # 60 - 4 margin
		Constants.TILE_SIZE * 46   # 50 - 4 margin
	)

# ============================================================================
# STATE MACHINE
# ============================================================================

func _physics_process(delta: float) -> void:
	if not is_alive:
		return

	# Check distance-based state transitions (optimization)
	_check_distance_based_states()

	# Process active state
	if active_state:
		active_state.physics_process(delta)

		# Check for state transitions
		var new_state_name = active_state.check_transitions()
		if new_state_name != "":
			# Transition to new state
			match new_state_name:
				"PATROL":
					change_state(State.PATROL)
				"CHASE":
					change_state(State.CHASE)
				"FROZEN":
					change_state(State.FROZEN)
				"PRAYER":
					# TODO Phase 1.13
					pass

func change_state(new_state: State) -> void:
	# Exit current state
	if active_state:
		active_state.exit()

	# Change state
	var old_state = current_state
	current_state = new_state

	# Enter new state
	if state_handlers.has(new_state):
		active_state = state_handlers[new_state]

		# If entering Frozen state, tell it what state to return to
		if new_state == State.FROZEN and active_state is FrozenState:
			var frozen_state: FrozenState = active_state
			frozen_state.set_previous_state(State.keys()[old_state])

		active_state.enter()
	else:
		push_warning("State %d not implemented for %s" % [new_state, name])

	print("%s: %s -> %s" % [name, State.keys()[old_state], State.keys()[new_state]])

# ============================================================================
# DISTANCE-BASED OPTIMIZATION
# ============================================================================

func _check_distance_based_states() -> void:
	var distance_to_player = global_position.distance_to(GameManager.player_position)
	var distance_in_tiles = distance_to_player / Constants.TILE_SIZE

	# Sleeping state (30+ tiles away)
	if distance_in_tiles > Constants.AI_STATE_SLEEPING_DISTANCE:
		if current_state != State.SLEEPING:
			_enter_sleeping_state()
		return

	# Wake up from sleeping if player approaches
	if current_state == State.SLEEPING and distance_in_tiles <= Constants.AI_STATE_SLEEPING_DISTANCE:
		change_state(State.PATROL)
		return

	# Dormant state (10-30 tiles away)
	# TODO Phase 1.5: Implement dormant state (check distance every 1s)

func _enter_sleeping_state() -> void:
	# Disable AI processing (just store position)
	if active_state:
		active_state.exit()
	active_state = null
	current_state = State.SLEEPING
	velocity = Vector2.ZERO

# ============================================================================
# COMBAT
# ============================================================================

func take_damage(amount: int, source: Node = null) -> void:
	if not is_alive:
		return

	current_hp -= amount
	current_hp = clampi(current_hp, 0, max_hp)

	print("%s took %d damage. HP: %d/%d" % [name, amount, current_hp, max_hp])

	# Visual feedback
	_play_damage_effect()

	if current_hp <= 0:
		die()

func die() -> void:
	if not is_alive:
		return

	is_alive = false
	print("%s died" % name)

	died.emit()
	EventBus.student_died.emit(global_position, self)

	# Increment statistics
	GameManager.increment_students_killed()

	# Play death animation
	_play_death_effect()

	# Remove from scene after animation
	await get_tree().create_timer(1.0).timeout
	queue_free()

# ============================================================================
# VISUAL EFFECTS
# ============================================================================

func _play_damage_effect() -> void:
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color.RED, 0.1)
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

func _play_death_effect() -> void:
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate:a", 0.0, 1.0)

# ============================================================================
# EVENT HANDLERS
# ============================================================================

func _on_blackout_started(floor: int) -> void:
	if floor != assigned_floor:
		return

	# Teleport to random position 3-10 tiles from player
	var min_dist = Constants.BLACKOUT_TELEPORT_MIN_DISTANCE * Constants.TILE_SIZE
	var max_dist = Constants.BLACKOUT_TELEPORT_MAX_DISTANCE * Constants.TILE_SIZE

	var angle = randf() * TAU
	var distance = randf_range(min_dist, max_dist)
	var offset = Vector2(cos(angle), sin(angle)) * distance
	var new_position = GameManager.player_position + offset

	# Ensure within floor bounds
	var bounds = _get_floor_bounds()
	new_position.x = clampf(new_position.x, bounds.position.x, bounds.end.x)
	new_position.y = clampf(new_position.y, bounds.position.y, bounds.end.y)

	global_position = new_position
	print("%s teleported to %s (blackout)" % [name, new_position])

func _on_prayer_started() -> void:
	# TODO Phase 1.13: Implement prayer movement (8.0 tiles/s)
	pass

# ============================================================================
# CONFIGURATION
# ============================================================================

func set_assigned_floor(floor: int) -> void:
	assigned_floor = floor
	print("%s assigned to floor %dF" % [name, floor])

# ============================================================================
# GAZE SYSTEM INTEGRATION
# ============================================================================

func start_chasing() -> void:
	"""Called by GazeSystem when player looks at this student's front"""
	if current_state != State.CHASE and is_alive:
		change_state(State.CHASE)

# ============================================================================
# SCENE SETUP
# ============================================================================

static func create_student_entity() -> StudentEntity:
	var student = StudentEntity.new()
	student.name = "Student"

	# Add sprite
	var sprite = Sprite2D.new()
	sprite.name = "Sprite2D"
	student.add_child(sprite)
	sprite.owner = student

	# Add collision shape
	var collision = CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	var shape = RectangleShape2D.new()
	shape.size = Constants.STUDENT_HITBOX_SIZE
	collision.shape = shape
	student.add_child(collision)
	collision.owner = student

	# Add navigation agent
	var nav = NavigationAgent2D.new()
	nav.name = "NavigationAgent2D"
	nav.path_desired_distance = 4.0
	nav.target_desired_distance = 8.0
	student.add_child(nav)
	nav.owner = student

	return student
