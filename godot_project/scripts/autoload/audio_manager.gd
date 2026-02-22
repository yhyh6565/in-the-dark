extends Node
## AudioManager - Audio system (Skeleton for Phase 1, full implementation in Phase 3)
## Manages music tracks, sound effects, and volume settings

# ============================================================================
# AUDIO PLAYERS
# ============================================================================

var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
const MAX_SFX_PLAYERS = 16  # Simultaneous sound effects

# ============================================================================
# STATE
# ============================================================================

var current_music_track: String = ""
var current_music_intensity: float = 1.0
var is_music_fading: bool = false

# Music/SFX libraries (will be populated in Phase 3)
var music_library: Dictionary = {}
var sfx_library: Dictionary = {}

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready() -> void:
	print("AudioManager initialized (Skeleton)")

	# Create music player
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.bus = "Music"
	add_child(music_player)

	# Create SFX player pool
	for i in range(MAX_SFX_PLAYERS):
		var sfx_player = AudioStreamPlayer.new()
		sfx_player.name = "SFXPlayer_%d" % i
		sfx_player.bus = "SFX"
		add_child(sfx_player)
		sfx_players.append(sfx_player)

	# Connect to EventBus
	EventBus.play_sfx.connect(_on_play_sfx)
	EventBus.play_music.connect(_on_play_music)
	EventBus.stop_music.connect(_on_stop_music)
	EventBus.change_music_intensity.connect(_on_change_music_intensity)

	# Apply volume settings from GameManager
	_apply_volume_settings()

	print("Audio system ready - %d SFX players created" % MAX_SFX_PLAYERS)

# ============================================================================
# MUSIC PLAYBACK
# ============================================================================

func play_music(music_id: String, fade_duration: float = 1.0) -> void:
	if current_music_track == music_id and music_player.playing:
		return  # Already playing this track

	print("Playing music: %s (fade: %.1fs)" % [music_id, fade_duration])

	# TODO Phase 3: Load actual music file
	# var stream = music_library.get(music_id)
	# if stream == null:
	#     push_warning("Music track not found: %s" % music_id)
	#     return

	# For now, just placeholder
	current_music_track = music_id

	# TODO: Implement fade-in/fade-out
	# if fade_duration > 0:
	#     _fade_music(stream, fade_duration)
	# else:
	#     music_player.stream = stream
	#     music_player.play()

func stop_music(fade_duration: float = 1.0) -> void:
	print("Stopping music (fade: %.1fs)" % fade_duration)

	# TODO Phase 3: Implement fade-out
	# if fade_duration > 0:
	#     _fade_out_music(fade_duration)
	# else:
	#     music_player.stop()

	current_music_track = ""

func _on_play_music(music_id: String, fade_duration: float) -> void:
	play_music(music_id, fade_duration)

func _on_stop_music(fade_duration: float) -> void:
	stop_music(fade_duration)

func _on_change_music_intensity(intensity: float) -> void:
	current_music_intensity = clampf(intensity, 0.0, 2.0)
	print("Music intensity changed: %.2f" % current_music_intensity)

	# TODO Phase 3: Adjust music volume or switch to intense version
	# music_player.volume_db = linear_to_db(current_music_intensity)

# ============================================================================
# SFX PLAYBACK
# ============================================================================

func play_sfx(sfx_id: String, position: Vector2 = Vector2.ZERO) -> void:
	# TODO Phase 3: Load actual SFX file
	# var stream = sfx_library.get(sfx_id)
	# if stream == null:
	#     push_warning("SFX not found: %s" % sfx_id)
	#     return

	# Find available SFX player
	var player = _get_available_sfx_player()
	if player == null:
		push_warning("No available SFX player for: %s" % sfx_id)
		return

	print("Playing SFX: %s" % sfx_id)

	# TODO: Load and play actual audio
	# player.stream = stream
	# player.play()

	# TODO: If position is provided, use AudioStreamPlayer2D instead for spatial audio

func _on_play_sfx(sfx_id: String, position: Vector2) -> void:
	play_sfx(sfx_id, position)

func _get_available_sfx_player() -> AudioStreamPlayer:
	for player in sfx_players:
		if not player.playing:
			return player
	return null  # All players busy

# ============================================================================
# VOLUME SETTINGS
# ============================================================================

func set_master_volume(volume: float) -> void:
	volume = clampf(volume, 0.0, 1.0)
	GameManager.settings.master_volume = volume
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(volume))
	print("Master volume set to: %.2f" % volume)

func set_music_volume(volume: float) -> void:
	volume = clampf(volume, 0.0, 1.0)
	GameManager.settings.music_volume = volume
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(volume))
	print("Music volume set to: %.2f" % volume)

func set_sfx_volume(volume: float) -> void:
	volume = clampf(volume, 0.0, 1.0)
	GameManager.settings.sfx_volume = volume
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(volume))
	print("SFX volume set to: %.2f" % volume)

func _apply_volume_settings() -> void:
	set_master_volume(GameManager.settings.master_volume)
	set_music_volume(GameManager.settings.music_volume)
	set_sfx_volume(GameManager.settings.sfx_volume)

# ============================================================================
# SPECIAL EFFECTS
# ============================================================================

func play_school_bell() -> void:
	print("Playing school bell (딩동댕동)")
	play_sfx("school_bell")
	EventBus.school_bell_played.emit()

func play_teacher_footsteps() -> void:
	print("Playing teacher footsteps (저벅...)")
	play_sfx("teacher_footsteps")

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

func is_music_playing() -> bool:
	return music_player.playing

func get_current_music_track() -> String:
	return current_music_track

## Load music/SFX libraries (Phase 3)
func load_audio_libraries() -> void:
	# TODO Phase 3: Load all music and SFX files
	# music_library = {
	#     "main_menu_theme": load("res://assets/audio/music/main_menu.ogg"),
	#     "floor_2_ambient": load("res://assets/audio/music/floor_2.ogg"),
	#     etc.
	# }
	# sfx_library = {
	#     "school_bell": load("res://assets/audio/sfx/school_bell.wav"),
	#     "footsteps": load("res://assets/audio/sfx/footsteps.wav"),
	#     etc.
	# }
	pass
