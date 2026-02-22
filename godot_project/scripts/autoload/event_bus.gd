extends Node
## EventBus - Global event system for decoupled communication
## All systems can emit and listen to events through this singleton

# ============================================================================
# PLAYER EVENTS
# ============================================================================

## Emitted when player takes damage
signal player_damaged(amount: int, source: String)

## Emitted when player HP changes
signal player_hp_changed(current_hp: int, max_hp: int)

## Emitted when player dies
signal player_died(cause: String)

## Emitted when player respawns
signal player_respawned()

## Emitted when player moves to new position
signal player_moved(new_position: Vector2)

## Emitted when player attacks
signal player_attacked(position: Vector2, direction: Vector2)

## Emitted when player performs stealth kill
signal player_stealth_killed(target: Node)

# ============================================================================
# STUDENT ENTITY EVENTS
# ============================================================================

## Emitted when any student entity dies
signal student_died(position: Vector2, student_node: Node)

## Emitted when student starts chasing player
signal student_chase_started(student_node: Node)

## Emitted when student stops chasing player
signal student_chase_ended(student_node: Node)

## Emitted when student is frozen by flashlight
signal student_frozen(student_node: Node)

## Emitted when student is unfrozen
signal student_unfrozen(student_node: Node)

## Emitted when student attacks player
signal student_attacked_player(student_node: Node)

# ============================================================================
# TEACHER BOSS EVENTS
# ============================================================================

## Emitted when teacher spawns (4+ name tags)
signal teacher_spawned()

## Emitted when teacher starts chasing
signal teacher_chase_started()

## Emitted when teacher attacks
signal teacher_attacked()

## Emitted when teacher is temporarily defeated (Phase 2 only)
signal teacher_temporarily_defeated()

## Emitted when teacher is permanently defeated (Happy Ending 01)
signal teacher_permanently_defeated()

# ============================================================================
# BLACKOUT SYSTEM EVENTS
# ============================================================================

## Emitted when blackout warning starts (5 seconds before)
signal blackout_warning(floor: int, seconds_remaining: float)

## Emitted when blackout starts (screen goes dark)
signal blackout_started(floor: int)

## Emitted when blackout ends (screen returns to normal)
signal blackout_ended(floor: int)

## Emitted when blackout timer updates
signal blackout_timer_updated(floor: int, time_remaining: float, total_time: float)

# ============================================================================
# SILENT PRAYER SYSTEM EVENTS
# ============================================================================

## Emitted when silent prayer warning starts (5 seconds before)
signal prayer_warning()

## Emitted when silent prayer starts (school bell rings)
signal prayer_started()

## Emitted when silent prayer ends
signal prayer_ended()

## Emitted when school bell plays (딩동댕동)
signal school_bell_played()

# ============================================================================
# NAME TAG SYSTEM EVENTS
# ============================================================================

## Emitted when name tag is collected
signal name_tag_collected(total_count: int)

## Emitted when name tag count reaches 3 (warning)
signal name_tag_warning(count: int)

## Emitted when name tag count reaches 4+ (teacher spawn)
signal name_tag_danger(count: int)

## Emitted when name tag is removed/discarded
signal name_tag_removed(total_count: int)

# ============================================================================
# FLASHLIGHT SYSTEM EVENTS
# ============================================================================

## Emitted when flashlight is turned on
signal flashlight_turned_on(brightness_level: int)

## Emitted when flashlight is turned off
signal flashlight_turned_off()

## Emitted when flashlight battery changes
signal flashlight_battery_changed(current: float, max_capacity: float, percent: float)

## Emitted when flashlight battery is low (< 20%)
signal flashlight_battery_low()

## Emitted when flashlight battery is depleted
signal flashlight_battery_depleted()

# ============================================================================
# GAZE SYSTEM EVENTS
# ============================================================================

## Emitted when gaze line hits a student's front (triggers chase)
signal gaze_triggered_chase(student_node: Node)

## Emitted when gaze line is updated (for visual)
signal gaze_line_updated(start: Vector2, end: Vector2, hit_something: bool)

# ============================================================================
# FLOOR TRANSITION EVENTS
# ============================================================================

## Emitted when floor transition starts
signal floor_transition_started(from_floor: int, to_floor: int)

## Emitted when floor transition completes
signal floor_transition_completed(current_floor: int)

## Emitted when player enters stairs area
signal stairs_entered(leads_to_floor: int)

# ============================================================================
# ITEM EVENTS
# ============================================================================

## Emitted when item is picked up
signal item_picked_up(item_id: String, item_name: String)

## Emitted when item is used
signal item_used(item_id: String, item_name: String)

## Emitted when item is discarded
signal item_discarded(item_id: String, item_name: String)

## Emitted when inventory slot changes
signal inventory_slot_changed(slot_index: int, item_id: String)

## Emitted when inventory is full
signal inventory_full()

# ============================================================================
# NPC EVENTS
# ============================================================================

## Emitted when NPC dialogue starts
signal npc_dialogue_started(npc_id: String, npc_name: String)

## Emitted when NPC dialogue ends
signal npc_dialogue_ended(npc_id: String)

## Emitted when NPC gives item to player
signal npc_gave_item(npc_id: String, item_id: String)

## Emitted when player helps NPC
signal npc_helped(npc_id: String)

# ============================================================================
# QUEST EVENTS
# ============================================================================

## Emitted when quest flag is set
signal quest_flag_set(flag_name: String, value: bool)

## Emitted when quest is completed
signal quest_completed(quest_id: String)

## Emitted when transfer student mode is activated
signal transfer_student_mode_activated()

## Emitted when backyard is unlocked
signal backyard_unlocked()

# ============================================================================
# GRADUATION CEREMONY EVENTS
# ============================================================================

## Emitted when graduation ceremony starts
signal graduation_ceremony_started()

## Emitted when ceremony phase changes (1-4)
signal graduation_ceremony_phase_changed(phase: int)

## Emitted when ceremony timer updates
signal graduation_ceremony_timer_updated(time_remaining: float)

## Emitted when ceremony is completed successfully
signal graduation_ceremony_completed()

## Emitted when ceremony fails (player dies)
signal graduation_ceremony_failed()

# ============================================================================
# ENDING EVENTS
# ============================================================================

## Emitted when ending sequence starts
signal ending_started(ending_type: Constants.EndingType)

## Emitted when ending cutscene completes
signal ending_completed(ending_type: Constants.EndingType)

# ============================================================================
# UI EVENTS
# ============================================================================

## Emitted to show system message in UI
signal show_system_message(message: String, duration: float)

## Emitted to show warning message
signal show_warning_message(message: String)

## Emitted to show danger alert
signal show_danger_alert(message: String)

## Emitted to update HUD element
signal update_hud(element_name: String, value: Variant)

## Emitted to show tutorial overlay
signal show_tutorial(tutorial_id: String, message: String)

# ============================================================================
# AUDIO EVENTS
# ============================================================================

## Emitted to play sound effect
signal play_sfx(sfx_id: String, position: Vector2 = Vector2.ZERO)

## Emitted to play music track
signal play_music(music_id: String, fade_duration: float = 1.0)

## Emitted to stop music
signal stop_music(fade_duration: float = 1.0)

## Emitted to change music intensity (e.g., when teacher chases)
signal change_music_intensity(intensity: float)

# ============================================================================
# SAVE/LOAD EVENTS
# ============================================================================

## Emitted when auto-save triggers
signal auto_save_triggered()

## Emitted when manual save is requested
signal manual_save_requested(slot_index: int)

## Emitted when save completes
signal save_completed(slot_index: int, success: bool)

## Emitted when load is requested
signal load_requested(slot_index: int)

## Emitted when load completes
signal load_completed(success: bool)

# ============================================================================
# DEBUG EVENTS
# ============================================================================

## Emitted to show debug info
signal debug_info_updated(info: Dictionary)

## Emitted when debug mode toggled
signal debug_mode_toggled(enabled: bool)

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

func _ready() -> void:
	print("EventBus initialized - Global event system ready")

## Connect to multiple signals at once (convenience function)
func connect_signals(target: Object, signal_connections: Dictionary) -> void:
	for signal_name in signal_connections.keys():
		var callback = signal_connections[signal_name]
		if has_signal(signal_name):
			self[signal_name].connect(callback.bind(target))
		else:
			push_warning("EventBus: Unknown signal '%s'" % signal_name)

## Emit student death and trigger prayer sequence
func trigger_student_death(position: Vector2, student_node: Node = null) -> void:
	student_died.emit(position, student_node)
	# SilentPrayerSystem will listen to this and trigger the prayer sequence

## Emit blackout sequence
func trigger_blackout(floor: int) -> void:
	blackout_started.emit(floor)
	# BlackoutSystem will handle the actual mechanics

## Emit prayer sequence
func trigger_prayer() -> void:
	prayer_warning.emit()
	# Wait 5 seconds, then emit prayer_started

## Show important message to player
func show_message(message: String, duration: float = 2.0, is_warning: bool = false) -> void:
	if is_warning:
		show_warning_message.emit(message)
	else:
		show_system_message.emit(message, duration)

## Show danger alert (red, urgent)
func show_alert(message: String) -> void:
	show_danger_alert.emit(message)
