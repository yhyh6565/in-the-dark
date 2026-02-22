extends TileMap
## Floor 2 Layout Generator
## Creates the 2F map programmatically based on LEVEL_DESIGN.md

# Tile IDs from tileset
const FLOOR = 0
const FLOOR_DARK = 1
const FLOOR_LIGHT = 2
const WALL = 3
const WALL_VARIANT = 4
const DOOR_CLOSED = 5
const DOOR_OPEN = 6
const DESK = 8
const CHAIR = 9
const WINDOW = 10
const STAIRS_UP = 11
const STAIRS_DOWN = 12

# Map dimensions (in tiles)
const MAP_WIDTH = 60
const MAP_HEIGHT = 50

# Courtyard (중정) position and size
const COURTYARD_X = 22
const COURTYARD_Y = 15
const COURTYARD_WIDTH = 16
const COURTYARD_HEIGHT = 16

# Classroom positions (9x12 tiles each)
const CLASSROOM_WIDTH = 9
const CLASSROOM_HEIGHT = 12

func _ready() -> void:
	# Generate the 2F layout
	generate_floor_2()
	print("2F map generated")

func generate_floor_2() -> void:
	# Layer 0: Floor
	# Layer 1: Walls
	# Layer 2: Objects (desks, chairs, etc.)

	# Step 1: Fill entire map with floor tiles
	_fill_floor()

	# Step 2: Draw outer walls
	_draw_outer_walls()

	# Step 3: Draw courtyard (central empty space)
	_draw_courtyard()

	# Step 4: Draw corridors (ㅁ-shaped)
	_draw_corridors()

	# Step 5: Draw classrooms (1-1 through 1-8)
	_draw_classrooms()

	# Step 6: Draw stairs
	_draw_stairs()

	# Step 7: Draw spawn point marker (Class 1-5)
	_mark_spawn_point()

## Fill entire map with floor tiles
func _fill_floor() -> void:
	for x in range(MAP_WIDTH):
		for y in range(MAP_HEIGHT):
			# Alternate floor tiles for visual variety
			var tile_id = FLOOR if (x + y) % 3 == 0 else FLOOR_LIGHT
			set_cell(0, Vector2i(x, y), 0, Vector2i(tile_id % 8, tile_id / 8))

## Draw outer perimeter walls
func _draw_outer_walls() -> void:
	# Top wall
	for x in range(MAP_WIDTH):
		set_cell(1, Vector2i(x, 0), 0, Vector2i(WALL % 8, WALL / 8))

	# Bottom wall
	for x in range(MAP_WIDTH):
		set_cell(1, Vector2i(x, MAP_HEIGHT - 1), 0, Vector2i(WALL % 8, WALL / 8))

	# Left wall
	for y in range(MAP_HEIGHT):
		set_cell(1, Vector2i(0, y), 0, Vector2i(WALL % 8, WALL / 8))

	# Right wall
	for y in range(MAP_HEIGHT):
		set_cell(1, Vector2i(MAP_WIDTH - 1, y), 0, Vector2i(WALL % 8, WALL / 8))

## Draw courtyard (impassable central area)
func _draw_courtyard() -> void:
	for x in range(COURTYARD_WIDTH):
		for y in range(COURTYARD_HEIGHT):
			var pos_x = COURTYARD_X + x
			var pos_y = COURTYARD_Y + y

			# Courtyard walls
			if x == 0 or x == COURTYARD_WIDTH - 1 or y == 0 or y == COURTYARD_HEIGHT - 1:
				set_cell(1, Vector2i(pos_x, pos_y), 0, Vector2i(WALL % 8, WALL / 8))

## Draw ㅁ-shaped corridors
func _draw_corridors() -> void:
	# Corridors are the space between outer walls and classrooms
	# For now, corridors are just the floor tiles (already filled)
	# We'll add walls for classroom boundaries
	pass

## Draw 8 classrooms (1-1 through 1-8)
func _draw_classrooms() -> void:
	# Classroom layout (clockwise from top-left):
	# West side: 1-1, 1-2, 1-3 (top to bottom)
	# North side: none (bathrooms)
	# East side: 1-4, 1-5, 1-6, 1-7, 1-8 (top to bottom)

	# Based on LEVEL_DESIGN.md 2F layout
	var classrooms = [
		# West side
		{"name": "1-1", "x": 2, "y": 8},
		{"name": "1-2", "x": 2, "y": 21},
		{"name": "1-3", "x": 2, "y": 34},

		# East side
		{"name": "1-4", "x": 40, "y": 8},
		{"name": "1-5", "x": 40, "y": 21},  # SPAWN POINT
		{"name": "1-6", "x": 40, "y": 34},
		{"name": "1-7", "x": 49, "y": 8},
		{"name": "1-8", "x": 49, "y": 21},
	]

	for classroom in classrooms:
		_draw_classroom(classroom.x, classroom.y, classroom.name)

## Draw a single classroom
func _draw_classroom(start_x: int, start_y: int, class_name: String) -> void:
	# Draw classroom walls (9x12 tiles)
	for x in range(CLASSROOM_WIDTH):
		for y in range(CLASSROOM_HEIGHT):
			var pos_x = start_x + x
			var pos_y = start_y + y

			# Walls on perimeter
			if x == 0 or x == CLASSROOM_WIDTH - 1 or y == 0 or y == CLASSROOM_HEIGHT - 1:
				set_cell(1, Vector2i(pos_x, pos_y), 0, Vector2i(WALL % 8, WALL / 8))

	# Add door (center of bottom wall for west classrooms, center of right wall for east)
	var door_x = start_x + CLASSROOM_WIDTH // 2
	var door_y = start_y + CLASSROOM_HEIGHT - 1
	set_cell(1, Vector2i(door_x, door_y), 0, Vector2i(DOOR_CLOSED % 8, DOOR_CLOSED / 8))

	# Add desks and chairs inside (simple 3x2 grid)
	for row in range(3):
		for col in range(2):
			var desk_x = start_x + 2 + col * 3
			var desk_y = start_y + 2 + row * 3
			set_cell(2, Vector2i(desk_x, desk_y), 0, Vector2i(DESK % 8, DESK / 8))
			set_cell(2, Vector2i(desk_x + 1, desk_y), 0, Vector2i(CHAIR % 8, CHAIR / 8))

## Draw stairs to 1F and 3F
func _draw_stairs() -> void:
	# Stair 1 (Southwest): x=5, y=45
	_draw_stair_block(5, 45, true)  # Up to 3F

	# Stair 2 (Southeast): x=52, y=45
	_draw_stair_block(52, 45, true)  # Up to 3F

	# Stair 3 (North-center): x=28, y=3
	_draw_stair_block(28, 3, true)  # Up to 3F

func _draw_stair_block(x: int, y: int, has_up: bool) -> void:
	# 4x6 tile stair block
	for i in range(4):
		for j in range(6):
			var tile_id = STAIRS_UP if has_up else STAIRS_DOWN
			set_cell(2, Vector2i(x + i, y + j), 0, Vector2i(tile_id % 8, tile_id / 8))

## Mark spawn point (Class 1-5 center)
func _mark_spawn_point() -> void:
	# Class 1-5 is at x=40, y=21
	# Center of classroom: x=40 + 4, y=21 + 6
	var spawn_x = 40 + CLASSROOM_WIDTH // 2
	var spawn_y = 21 + CLASSROOM_HEIGHT // 2

	# Store spawn point globally
	if has_node("/root/GameManager"):
		GameManager.set_meta("spawn_point_2f", Vector2(spawn_x * 16, spawn_y * 16))

	print("Spawn point marked at tile (%d, %d), world pos (%d, %d)" % [spawn_x, spawn_y, spawn_x * 16, spawn_y * 16])

## Get spawn position in world coordinates
func get_spawn_position() -> Vector2:
	var spawn_tile = Vector2(40 + CLASSROOM_WIDTH // 2, 21 + CLASSROOM_HEIGHT // 2)
	return spawn_tile * 16  # Convert to pixels
