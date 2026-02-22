extends Node
## GameManager - Global game state management
## Handles: Current floor, name tags, player HP, game state, floor transitions

# ============================================================================
# SIGNALS
# ============================================================================

signal floor_changed(new_floor: int, old_floor: int)
signal name_tag_collected(total_count: int)
signal name_tag_warning(count: int)  # At 3 tags
signal teacher_spawned()  # At 4+ tags
signal player_hp_changed(current: int, max_hp: int)
signal player_died(cause: String)
signal game_state_changed(new_state: GameState)

# ============================================================================
# ENUMS
# ============================================================================

enum GameState {
	MAIN_MENU,
	PLAYING,
	PAUSED,
	GAME_OVER,
	ENDING_CUTSCENE
}

# ============================================================================
# GAME STATE
# ============================================================================

var current_state: GameState = GameState.MAIN_MENU
var current_floor: int = Constants.FLOOR_STARTING  # Start at 2F
var previous_floor: int = Constants.FLOOR_STARTING

# ============================================================================
# PLAYER STATE
# ============================================================================

var player_hp: int = Constants.PLAYER_MAX_HP
var player_max_hp: int = Constants.PLAYER_MAX_HP
var player_position: Vector2 = Vector2.ZERO
var player_is_alive: bool = true

# ============================================================================
# NAME TAG SYSTEM
# ============================================================================

var name_tag_count: int = 0
var teacher_has_spawned: bool = false

# ============================================================================
# QUEST FLAGS
# ============================================================================

var quest_flags: Dictionary = {
	# NPC interactions
	"bronze_agent_met": false,
	"lee_gyeol_helped": false,
	"haegeum_agent_met": false,
	"choi_agent_met": false,
	"lee_jaheon_met": false,

	# Special items acquired
	"has_uniform": false,  # Transfer student mode
	"has_graduation_decoration": false,  # 5F access
	"has_tomato_tattoo": false,  # Happy Ending 02 requirement
	"has_brainwashing_pen": false,  # Ending branch

	# Happy Ending 01 items
	"has_broken_lantern": false,
	"has_torn_talisman": false,
	"has_sutra_paper": false,
	"has_spirit_sword": false,
	"has_complete_talisman": false,

	# Mode flags
	"transfer_student_mode_active": false,
	"backyard_unlocked": false,

	# Story progress
	"tutorial_completed": false,
	"first_blackout_experienced": false,
	"first_student_killed": false,
	"first_prayer_experienced": false,
	"graduation_ceremony_started": false,
}

# ============================================================================
# STATISTICS (for save/load and endings)
# ============================================================================

var stats: Dictionary = {
	"playtime_seconds": 0.0,
	"students_killed": 0,
	"deaths": 0,
	"floors_visited": [2],  # Start with 2F
	"blackouts_experienced": 0,
	"prayers_experienced": 0,
}

# ============================================================================
# GAME SETTINGS
# ============================================================================

var settings: Dictionary = {
	"master_volume": 1.0,
	"music_volume": 0.8,
	"sfx_volume": 1.0,
	"fullscreen": false,
	"vsync": true,
}

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready() -> void:
	print("GameManager initialized")
	print("Starting floor: %dF" % current_floor)
	print("Player HP: %d/%d" % [player_hp, player_max_hp])
	process_mode = Node.PROCESS_MODE_ALWAYS  # Always process, even when paused

func _process(delta: float) -> void:
	if current_state == GameState.PLAYING:
		stats.playtime_seconds += delta

# ============================================================================
# GAME STATE MANAGEMENT
# ============================================================================

func change_state(new_state: GameState) -> void:
	var old_state = current_state
	current_state = new_state
	game_state_changed.emit(new_state)
	print("Game state changed: %s -> %s" % [GameState.keys()[old_state], GameState.keys()[new_state]])

func start_new_game() -> void:
	reset_game_state()
	change_state(GameState.PLAYING)
	print("New game started")

func pause_game() -> void:
	change_state(GameState.PAUSED)
	get_tree().paused = true

func resume_game() -> void:
	change_state(GameState.PLAYING)
	get_tree().paused = false

func quit_to_menu() -> void:
	get_tree().paused = false
	change_state(GameState.MAIN_MENU)
	# Load main menu scene (will be implemented in Phase 1.18)
	# get_tree().change_scene_to_file("res://scenes/main/main_menu.tscn")

# ============================================================================
# FLOOR MANAGEMENT
# ============================================================================

func change_floor(new_floor: int) -> void:
	if new_floor == current_floor:
		return

	previous_floor = current_floor
	current_floor = new_floor

	# Track visited floors
	if not stats.floors_visited.has(new_floor):
		stats.floors_visited.append(new_floor)

	floor_changed.emit(new_floor, previous_floor)
	print("Floor changed: %dF -> %dF" % [previous_floor, new_floor])

func get_current_floor() -> int:
	return current_floor

func is_on_safe_floor() -> bool:
	return current_floor == Constants.FLOOR_SAFE_ZONE

# ============================================================================
# PLAYER HP MANAGEMENT
# ============================================================================

func damage_player(amount: int, source: String = "unknown") -> void:
	if not player_is_alive:
		return

	player_hp -= amount
	player_hp = clampi(player_hp, 0, player_max_hp)
	player_hp_changed.emit(player_hp, player_max_hp)

	print("Player took %d damage from %s. HP: %d/%d" % [amount, source, player_hp, player_max_hp])

	if player_hp <= 0:
		kill_player(source)

func heal_player(amount: int) -> void:
	if not player_is_alive:
		return

	var old_hp = player_hp
	player_hp += amount
	player_hp = clampi(player_hp, 0, player_max_hp)
	player_hp_changed.emit(player_hp, player_max_hp)

	print("Player healed %d HP. HP: %d/%d" % [amount, player_hp, player_max_hp])

func kill_player(cause: String) -> void:
	if not player_is_alive:
		return

	player_is_alive = false
	player_hp = 0
	stats.deaths += 1
	player_died.emit(cause)

	print("Player died. Cause: %s" % cause)
	print("Total deaths: %d" % stats.deaths)

	# Trigger game over (will show death screen with respawn options)
	change_state(GameState.GAME_OVER)

func respawn_player() -> void:
	player_hp = player_max_hp
	player_is_alive = true
	print("Player respawned")

# ============================================================================
# NAME TAG SYSTEM
# ============================================================================

func add_name_tag() -> void:
	name_tag_count += 1
	name_tag_collected.emit(name_tag_count)

	print("Name tag collected. Total: %d" % name_tag_count)

	# Check thresholds
	if name_tag_count == Constants.NAME_TAG_THRESHOLD_WARNING:
		# Warning at 3 tags
		name_tag_warning.emit(name_tag_count)
		print("WARNING: Teacher can detect you now!")
		EventBus.show_system_message.emit("선생님이 나를 감지할 수 있으니 주의하자.", 3.0)

	elif name_tag_count == Constants.NAME_TAG_THRESHOLD_TEACHER_SPAWN:
		# Teacher spawns at 4 tags
		if not teacher_has_spawned:
			spawn_teacher()

func remove_name_tag() -> void:
	if name_tag_count > 0:
		name_tag_count -= 1
		name_tag_collected.emit(name_tag_count)
		print("Name tag removed. Total: %d" % name_tag_count)

func get_name_tag_count() -> int:
	return name_tag_count

func is_name_tag_count_safe() -> bool:
	return Constants.is_name_tag_count_safe(name_tag_count)

func spawn_teacher() -> void:
	if teacher_has_spawned:
		return

	teacher_has_spawned = true
	teacher_spawned.emit()

	print("TEACHER SPAWNED!")
	EventBus.show_system_message.emit("선생님이 내 위치를 감지했다! 선생님이 5층에서 출발합니다!", 5.0)
	# Play ominous sound effect
	EventBus.play_sfx.emit("teacher_footsteps")

# ============================================================================
# QUEST FLAG MANAGEMENT
# ============================================================================

func set_quest_flag(flag_name: String, value: bool = true) -> void:
	if quest_flags.has(flag_name):
		quest_flags[flag_name] = value
		print("Quest flag set: %s = %s" % [flag_name, value])
	else:
		push_warning("Unknown quest flag: %s" % flag_name)

func get_quest_flag(flag_name: String) -> bool:
	if quest_flags.has(flag_name):
		return quest_flags[flag_name]
	else:
		push_warning("Unknown quest flag: %s" % flag_name)
		return false

func check_happy_ending_01_requirements() -> bool:
	return (
		quest_flags.has_broken_lantern and
		quest_flags.has_torn_talisman and
		quest_flags.has_sutra_paper and
		quest_flags.has_spirit_sword and
		quest_flags.transfer_student_mode_active
	)

func check_happy_ending_02_requirements() -> bool:
	return (
		quest_flags.has_graduation_decoration and
		quest_flags.has_tomato_tattoo and
		name_tag_count >= Constants.ENDING_HAPPY_02_MIN_NAME_TAGS and
		name_tag_count <= Constants.ENDING_HAPPY_02_MAX_NAME_TAGS
	)

# ============================================================================
# STATISTICS
# ============================================================================

func increment_students_killed() -> void:
	stats.students_killed += 1
	if stats.students_killed == 1 and not quest_flags.first_student_killed:
		quest_flags.first_student_killed = true
		print("First student killed!")

func increment_blackouts_experienced() -> void:
	stats.blackouts_experienced += 1
	if stats.blackouts_experienced == 1 and not quest_flags.first_blackout_experienced:
		quest_flags.first_blackout_experienced = true
		print("First blackout experienced!")

func increment_prayers_experienced() -> void:
	stats.prayers_experienced += 1
	if stats.prayers_experienced == 1 and not quest_flags.first_prayer_experienced:
		quest_flags.first_prayer_experienced = true
		print("First prayer experienced!")

func get_playtime_formatted() -> String:
	var total_seconds = int(stats.playtime_seconds)
	var hours = total_seconds / 3600
	var minutes = (total_seconds % 3600) / 60
	var seconds = total_seconds % 60
	return "%02d:%02d:%02d" % [hours, minutes, seconds]

# ============================================================================
# SAVE/LOAD DATA
# ============================================================================

func get_save_data() -> Dictionary:
	return {
		"version": "1.0",
		"timestamp": Time.get_unix_time_from_system(),

		# Game state
		"current_floor": current_floor,
		"player_hp": player_hp,
		"player_position": {"x": player_position.x, "y": player_position.y},
		"name_tag_count": name_tag_count,
		"teacher_has_spawned": teacher_has_spawned,

		# Quest flags
		"quest_flags": quest_flags.duplicate(),

		# Statistics
		"stats": stats.duplicate(),
	}

func load_save_data(data: Dictionary) -> void:
	if not data.has("version"):
		push_error("Invalid save data: no version")
		return

	# Game state
	if data.has("current_floor"):
		current_floor = data.current_floor
	if data.has("player_hp"):
		player_hp = data.player_hp
	if data.has("player_position"):
		var pos = data.player_position
		player_position = Vector2(pos.x, pos.y)
	if data.has("name_tag_count"):
		name_tag_count = data.name_tag_count
	if data.has("teacher_has_spawned"):
		teacher_has_spawned = data.teacher_has_spawned

	# Quest flags
	if data.has("quest_flags"):
		quest_flags = data.quest_flags.duplicate()

	# Statistics
	if data.has("stats"):
		stats = data.stats.duplicate()

	print("Game state loaded successfully")
	print("Floor: %dF, HP: %d, Name tags: %d" % [current_floor, player_hp, name_tag_count])

func reset_game_state() -> void:
	# Reset to starting values
	current_floor = Constants.FLOOR_STARTING
	previous_floor = Constants.FLOOR_STARTING
	player_hp = player_max_hp
	player_is_alive = true
	player_position = Vector2.ZERO
	name_tag_count = 0
	teacher_has_spawned = false

	# Reset quest flags
	for key in quest_flags.keys():
		quest_flags[key] = false

	# Reset statistics
	stats = {
		"playtime_seconds": 0.0,
		"students_killed": 0,
		"deaths": 0,
		"floors_visited": [2],
		"blackouts_experienced": 0,
		"prayers_experienced": 0,
	}

	print("Game state reset to defaults")

# ============================================================================
# ENDING DETERMINATION
# ============================================================================

func determine_ending() -> Constants.EndingType:
	# Check death conditions first
	if not player_is_alive:
		# Bad Ending 01: Loop Ending (0 tags + death)
		if name_tag_count == Constants.ENDING_BAD_01_NAME_TAG_COUNT:
			return Constants.EndingType.BAD_01_LOOP

		# Bad Ending 02: Deletion Ending (killed by teacher)
		# This should be set by the death cause parameter

		# Bad Ending 03: Incomplete Escape (1-3 tags + death)
		if name_tag_count >= Constants.ENDING_BAD_03_MIN_NAME_TAGS and \
		   name_tag_count <= Constants.ENDING_BAD_03_MAX_NAME_TAGS:
			return Constants.EndingType.BAD_03_INCOMPLETE

	# Check happy endings
	if check_happy_ending_01_requirements():
		return Constants.EndingType.HAPPY_01_TRUE

	if check_happy_ending_02_requirements():
		return Constants.EndingType.HAPPY_02_NORMAL

	# Default to bad ending
	return Constants.EndingType.BAD_03_INCOMPLETE
