extends CharacterBody2D
## PlayerController - Main player script
## Coordinates all player systems: movement, combat, HP, etc.

class_name Player

# ============================================================================
# SIGNALS
# ============================================================================

signal animation_state_changed(new_state: String)
signal hp_changed(current: int, max_hp: int)
signal died()

# ============================================================================
# COMPONENTS
# ============================================================================

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var camera: Camera2D = $Camera2D

# Movement component (created in _ready)
var movement: PlayerMovement

# Gaze system component (created in _ready)
var gaze: GazeSystem

# Flashlight system component (created in _ready)
var flashlight: FlashlightSystem

# ============================================================================
# PLAYER STATE
# ============================================================================

var current_hp: int = Constants.PLAYER_MAX_HP
var max_hp: int = Constants.PLAYER_MAX_HP
var is_alive: bool = true

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready() -> void:
	# Initialize movement component
	movement = PlayerMovement.new(self)
	add_child(movement)

	# Initialize gaze system
	gaze = GazeSystem.new(self)
	add_child(gaze)

	# Initialize flashlight system
	flashlight = FlashlightSystem.new(self)
	add_child(flashlight)

	# Configure collision shape (14x14 px hitbox)
	if collision_shape.shape == null:
		collision_shape.shape = RectangleShape2D.new()
	collision_shape.shape.size = Constants.PLAYER_HITBOX_SIZE

	# Configure camera
	if camera:
		camera.zoom = Vector2(Constants.CAMERA_ZOOM, Constants.CAMERA_ZOOM)
		camera.position_smoothing_enabled = true
		camera.position_smoothing_speed = 5.0

		# Set camera limits for current floor
		CameraLimits.set_limits_for_floor(camera, GameManager.current_floor)
		CameraLimits.enable_limits(camera)

	# Connect to GameManager
	GameManager.player_hp_changed.connect(_on_game_manager_hp_changed)
	GameManager.player_died.connect(_on_game_manager_player_died)

	# Sync HP with GameManager
	current_hp = GameManager.player_hp
	max_hp = GameManager.player_max_hp

	# Connect animation state signal
	animation_state_changed.connect(_on_animation_state_changed)

	print("Player initialized at position: %s" % global_position)
	print("HP: %d/%d" % [current_hp, max_hp])

func _physics_process(delta: float) -> void:
	if not is_alive:
		return

	# Process movement
	movement.process_movement(delta)

	# Process gaze system
	gaze.process_gaze(delta)

	# Process flashlight system
	flashlight.process_flashlight(delta)

	# Update GameManager with player position
	GameManager.player_position = global_position

	# Emit movement event for other systems
	if movement.is_moving:
		EventBus.player_moved.emit(global_position)

	# Debug info
	if Constants.DEBUG_MODE and Input.is_action_just_pressed("ui_cancel"):
		print_debug_info()

	# Queue redraw for gaze line
	queue_redraw()

func _draw() -> void:
	# Draw gaze line
	if gaze:
		gaze.draw_gaze_line(self)

# ============================================================================
# HP MANAGEMENT
# ============================================================================

func take_damage(amount: int, source: String = "unknown") -> void:
	if not is_alive:
		return

	if Constants.DEBUG_INVINCIBLE:
		print("DEBUG: Invincible mode - damage ignored")
		return

	current_hp -= amount
	current_hp = clampi(current_hp, 0, max_hp)

	# Update GameManager
	GameManager.player_hp = current_hp
	hp_changed.emit(current_hp, max_hp)
	EventBus.player_damaged.emit(amount, source)

	print("Player took %d damage from %s. HP: %d/%d" % [amount, source, current_hp, max_hp])

	# Visual feedback
	_play_damage_effect()

	if current_hp <= 0:
		die(source)

func heal(amount: int) -> void:
	if not is_alive:
		return

	var old_hp = current_hp
	current_hp += amount
	current_hp = clampi(current_hp, 0, max_hp)

	# Update GameManager
	GameManager.player_hp = current_hp
	hp_changed.emit(current_hp, max_hp)

	print("Player healed %d HP (%d -> %d)" % [amount, old_hp, current_hp])

	# Visual feedback
	_play_heal_effect()

func die(cause: String) -> void:
	if not is_alive:
		return

	is_alive = false
	current_hp = 0

	print("Player died. Cause: %s" % cause)

	died.emit()
	EventBus.player_died.emit(cause)
	GameManager.kill_player(cause)

	# Stop movement
	velocity = Vector2.ZERO

	# Play death animation/effect
	_play_death_effect()

func respawn() -> void:
	is_alive = true
	current_hp = max_hp
	GameManager.player_hp = max_hp
	GameManager.respawn_player()

	print("Player respawned")
	EventBus.player_respawned.emit()

# ============================================================================
# VISUAL EFFECTS
# ============================================================================

func _play_damage_effect() -> void:
	# TODO Phase 1.3: Implement damage flash effect
	# Tween sprite modulate to red and back
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color.RED, 0.1)
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

func _play_heal_effect() -> void:
	# TODO Phase 1.3: Implement heal effect
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color.GREEN, 0.1)
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

func _play_death_effect() -> void:
	# TODO: Implement death effect (fade out, etc.)
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate:a", 0.0, 1.0)

# ============================================================================
# ANIMATION HANDLING
# ============================================================================

func _on_animation_state_changed(new_state: String) -> void:
	# TODO Phase 1.3: Connect to AnimationPlayer when sprites are added
	# For now, just print
	if Constants.DEBUG_MODE:
		print("Animation state: %s" % new_state)

# ============================================================================
# GAME MANAGER CALLBACKS
# ============================================================================

func _on_game_manager_hp_changed(current: int, max_value: int) -> void:
	# Sync with GameManager if HP changed externally
	if current != current_hp:
		current_hp = current
		max_hp = max_value
		hp_changed.emit(current_hp, max_hp)

func _on_game_manager_player_died(cause: String) -> void:
	# GameManager triggered death
	if is_alive:
		die(cause)

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

func get_center_position() -> Vector2:
	return global_position

func get_facing_direction() -> Vector2:
	return movement.get_facing_direction()

func get_movement_direction() -> Vector2:
	return movement.get_movement_direction()

func is_moving() -> bool:
	return movement.is_moving

func get_current_speed() -> float:
	return movement.get_current_speed_tiles_per_sec()

# ============================================================================
# DEBUG
# ============================================================================

func print_debug_info() -> void:
	print("\n=== PLAYER DEBUG INFO ===")
	print("Position: %s" % global_position)
	print("HP: %d/%d" % [current_hp, max_hp])
	print("Alive: %s" % is_alive)
	print("\nMovement:")
	var move_info = movement.get_debug_info()
	for key in move_info.keys():
		print("  %s: %s" % [key, move_info[key]])
	print("\nFlashlight:")
	var flashlight_info = flashlight.get_debug_info()
	for key in flashlight_info.keys():
		print("  %s: %s" % [key, flashlight_info[key]])
	print("========================\n")

# ============================================================================
# SCENE TREE SETUP HELPER
# ============================================================================

## Call this to set up the player node structure programmatically
static func create_player_scene() -> Player:
	var player = Player.new()
	player.name = "Player"

	# Add sprite
	var sprite = Sprite2D.new()
	sprite.name = "Sprite2D"
	# TODO: Load actual sprite texture
	# sprite.texture = load("res://assets/sprites/player/player.png")
	player.add_child(sprite)
	sprite.owner = player

	# Add collision shape
	var collision = CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	var shape = RectangleShape2D.new()
	shape.size = Constants.PLAYER_HITBOX_SIZE
	collision.shape = shape
	player.add_child(collision)
	collision.owner = player

	# Add camera
	var camera = Camera2D.new()
	camera.name = "Camera2D"
	camera.zoom = Vector2(Constants.CAMERA_ZOOM, Constants.CAMERA_ZOOM)
	camera.position_smoothing_enabled = true
	player.add_child(camera)
	camera.owner = player

	return player
