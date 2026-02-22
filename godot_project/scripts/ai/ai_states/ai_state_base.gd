extends Node
## AIStateBase - Base class for all AI states
## Subclasses implement specific behaviors (Patrol, Chase, Frozen, etc.)

class_name AIStateBase

# Reference to the entity that owns this state
var entity: CharacterBody2D

# State name for debugging
var state_name: String = "Base"

# ============================================================================
# LIFECYCLE
# ============================================================================

func _init(entity_node: CharacterBody2D) -> void:
	entity = entity_node

## Called when entering this state
func enter() -> void:
	pass

## Called when exiting this state
func exit() -> void:
	pass

## Called every physics frame while in this state
func physics_process(delta: float) -> void:
	pass

## Called every frame while in this state
func process(delta: float) -> void:
	pass

# ============================================================================
# STATE TRANSITIONS
# ============================================================================

## Check if state should transition to another state
## Returns: State name to transition to, or "" to stay in current state
func check_transitions() -> String:
	return ""

# ============================================================================
# UTILITIES
# ============================================================================

## Get distance to player
func get_distance_to_player() -> float:
	if not GameManager.player_position:
		return 99999.0
	return entity.global_position.distance_to(GameManager.player_position)

## Get direction to player
func get_direction_to_player() -> Vector2:
	if not GameManager.player_position:
		return Vector2.ZERO
	return (GameManager.player_position - entity.global_position).normalized()

## Check if player is in line of sight
func has_line_of_sight_to_player() -> bool:
	if not GameManager.player_position:
		return false

	var space_state = entity.get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		entity.global_position,
		GameManager.player_position
	)
	query.exclude = [entity]

	var result = space_state.intersect_ray(query)

	# If nothing hit, or hit the player, we have line of sight
	return result.is_empty() or result.collider.is_in_group("player")

## Get random point within radius
func get_random_point_nearby(radius: float) -> Vector2:
	var angle = randf() * TAU
	var distance = randf() * radius
	return entity.global_position + Vector2(cos(angle), sin(angle)) * distance

# ============================================================================
# DEBUG
# ============================================================================

func get_debug_info() -> Dictionary:
	return {
		"state": state_name,
		"distance_to_player": "%.1f tiles" % (get_distance_to_player() / Constants.TILE_SIZE)
	}
