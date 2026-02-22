extends Node
## SaveManager - Save/Load system (Skeleton for Phase 1, full implementation in Phase 3)
## Auto-save every 10 minutes + Manual save (5 slots)

# ============================================================================
# CONSTANTS
# ============================================================================

const SAVE_FILE_EXTENSION = ".save"
const SAVE_DIRECTORY = "user://saves/"
const AUTO_SAVE_SLOT = -1  # Special slot for auto-save
const MAX_MANUAL_SAVE_SLOTS = 5

# ============================================================================
# STATE
# ============================================================================

var auto_save_timer: float = 0.0
var manual_saves_used: int = 0
var last_save_time: float = 0.0

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready() -> void:
	print("SaveManager initialized (Skeleton)")
	_ensure_save_directory_exists()

	# Connect to EventBus for save/load requests
	EventBus.auto_save_triggered.connect(_on_auto_save_triggered)
	EventBus.manual_save_requested.connect(_on_manual_save_requested)
	EventBus.load_requested.connect(_on_load_requested)

func _process(delta: float) -> void:
	# Auto-save timer (every 10 minutes)
	if GameManager.current_state == GameManager.GameState.PLAYING:
		auto_save_timer += delta
		if auto_save_timer >= Constants.AUTOSAVE_INTERVAL:
			auto_save_timer = 0.0
			auto_save()

# ============================================================================
# DIRECTORY MANAGEMENT
# ============================================================================

func _ensure_save_directory_exists() -> void:
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("saves"):
		dir.make_dir("saves")
		print("Created save directory: %s" % SAVE_DIRECTORY)

# ============================================================================
# AUTO-SAVE
# ============================================================================

func auto_save() -> void:
	print("Auto-saving...")
	var success = save_game(AUTO_SAVE_SLOT)
	if success:
		EventBus.show_system_message.emit("자동 저장되었습니다", Constants.AUTOSAVE_MESSAGE_DURATION)
		last_save_time = Time.get_ticks_msec() / 1000.0
	EventBus.save_completed.emit(AUTO_SAVE_SLOT, success)

func _on_auto_save_triggered() -> void:
	auto_save()

# ============================================================================
# MANUAL SAVE
# ============================================================================

func manual_save(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= MAX_MANUAL_SAVE_SLOTS:
		push_error("Invalid save slot: %d" % slot_index)
		return false

	print("Manual saving to slot %d..." % slot_index)
	var success = save_game(slot_index)

	if success:
		EventBus.show_system_message.emit("저장되었습니다 (슬롯 %d)" % (slot_index + 1), 2.0)
		last_save_time = Time.get_ticks_msec() / 1000.0

	EventBus.save_completed.emit(slot_index, success)
	return success

func _on_manual_save_requested(slot_index: int) -> void:
	manual_save(slot_index)

# ============================================================================
# SAVE GAME
# ============================================================================

func save_game(slot_index: int) -> bool:
	var save_data = _compile_save_data()
	var file_path = _get_save_file_path(slot_index)

	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open save file: %s" % file_path)
		return false

	var json_string = JSON.stringify(save_data, "\t")
	file.store_string(json_string)
	file.close()

	print("Game saved to: %s" % file_path)
	return true

func _compile_save_data() -> Dictionary:
	var data = {
		"meta": {
			"version": "1.0",
			"timestamp": Time.get_unix_time_from_system(),
			"playtime": GameManager.stats.playtime_seconds,
		},
		"game_manager": GameManager.get_save_data(),
		# TODO Phase 3: Add more systems
		# "inventory": InventorySystem.get_save_data(),
		# "blackout": BlackoutSystem.get_save_data(),
		# "player_position": player.global_position,
		# etc.
	}
	return data

# ============================================================================
# LOAD GAME
# ============================================================================

func load_game(slot_index: int) -> bool:
	var file_path = _get_save_file_path(slot_index)

	if not FileAccess.file_exists(file_path):
		push_warning("Save file does not exist: %s" % file_path)
		EventBus.load_completed.emit(false)
		return false

	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("Failed to open save file: %s" % file_path)
		EventBus.load_completed.emit(false)
		return false

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		push_error("Failed to parse save file JSON")
		EventBus.load_completed.emit(false)
		return false

	var save_data = json.get_data()
	_apply_save_data(save_data)

	print("Game loaded from: %s" % file_path)
	EventBus.load_completed.emit(true)
	return true

func _on_load_requested(slot_index: int) -> void:
	load_game(slot_index)

func _apply_save_data(data: Dictionary) -> void:
	if not data.has("game_manager"):
		push_error("Invalid save data: missing game_manager")
		return

	GameManager.load_save_data(data.game_manager)

	# TODO Phase 3: Load other systems
	# InventorySystem.load_save_data(data.inventory)
	# etc.

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

func _get_save_file_path(slot_index: int) -> String:
	if slot_index == AUTO_SAVE_SLOT:
		return SAVE_DIRECTORY + "autosave" + SAVE_FILE_EXTENSION
	else:
		return SAVE_DIRECTORY + "save_slot_%d" % slot_index + SAVE_FILE_EXTENSION

func save_exists(slot_index: int) -> bool:
	var file_path = _get_save_file_path(slot_index)
	return FileAccess.file_exists(file_path)

func get_save_info(slot_index: int) -> Dictionary:
	if not save_exists(slot_index):
		return {}

	var file_path = _get_save_file_path(slot_index)
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		return {}

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	if json.parse(json_string) != OK:
		return {}

	var data = json.get_data()
	if not data.has("meta"):
		return {}

	return data.meta

func delete_save(slot_index: int) -> bool:
	var file_path = _get_save_file_path(slot_index)
	if not FileAccess.file_exists(file_path):
		return false

	var dir = DirAccess.open(SAVE_DIRECTORY)
	var err = dir.remove(file_path)
	return err == OK

func get_all_save_slots() -> Array:
	var slots = []
	for i in range(MAX_MANUAL_SAVE_SLOTS):
		var info = get_save_info(i)
		slots.append({
			"slot_index": i,
			"exists": save_exists(i),
			"info": info
		})
	return slots
