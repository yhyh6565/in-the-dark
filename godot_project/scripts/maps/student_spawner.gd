extends Node2D
## StudentSpawner - Spawns students on a floor
## Manages student placement and ensures proper distribution

@export var student_scene: PackedScene
@export var student_count: int = 17  # 15-20 for 2F
@export var assigned_floor: int = 2
@export var spawn_area: Rect2 = Rect2(32, 32, 896, 736)  # Default 2F area (with margins)

var spawned_students: Array[StudentEntity] = []

func _ready() -> void:
	# Wait for navigation to be ready
	await get_tree().create_timer(0.5).timeout

	if student_scene == null:
		student_scene = load("res://scenes/entities/student_entity.tscn")

	spawn_students()

func spawn_students() -> void:
	print("Spawning %d students on floor %dF..." % [student_count, assigned_floor])

	for i in range(student_count):
		var student = student_scene.instantiate() as StudentEntity
		if student == null:
			push_error("Failed to instantiate student scene")
			continue

		# Generate random spawn position within area
		var spawn_pos = _get_random_spawn_position()
		student.global_position = spawn_pos

		# Set assigned floor
		student.set_assigned_floor(assigned_floor)

		# Add to scene
		add_child(student)
		spawned_students.append(student)

		print("  Spawned %s at %s" % [student.name, spawn_pos])

	print("Spawned %d students successfully" % spawned_students.size())

func _get_random_spawn_position() -> Vector2:
	# Try to find valid position (not inside walls)
	var max_attempts = 20
	for attempt in range(max_attempts):
		var x = spawn_area.position.x + randf() * spawn_area.size.x
		var y = spawn_area.position.y + randf() * spawn_area.size.y
		var pos = Vector2(x, y)

		# TODO: Check if position is valid (not in wall)
		# For now, just use random position
		return pos

	# Fallback to center of spawn area
	return spawn_area.get_center()

func get_student_count() -> int:
	return spawned_students.size()

func get_alive_students() -> Array[StudentEntity]:
	var alive = []
	for student in spawned_students:
		if student != null and student.is_alive:
			alive.append(student)
	return alive
