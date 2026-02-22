extends Node
## Constants - Single Source of Truth for all game values
## Based on SYSTEM_BALANCING.md v2.1
## All numerical values are defined here and referenced throughout the project

# ============================================================================
# TILE SYSTEM
# ============================================================================
const TILE_SIZE: int = 16  # pixels per tile
const TILE_SIZE_VECTOR: Vector2 = Vector2(16, 16)

# ============================================================================
# 1. PLAYER STATS
# ============================================================================

## 1.1 Movement Speed (tiles/second)
const PLAYER_SPEED_WALK: float = 6.0  # 96 px/s - Base speed
const PLAYER_SPEED_RUN: float = 9.0  # 144 px/s - 150% of walk
const PLAYER_SPEED_CROUCH: float = 3.0  # 48 px/s - 50% of walk
const PLAYER_SPEED_CARRYING_NPC: float = 4.2  # 67.2 px/s - 70% of walk

## 1.2 Health System
const PLAYER_MAX_HP: int = 100
const PLAYER_DAMAGE_STUDENT_CONTACT: int = 50  # 2 hits to die
const PLAYER_DAMAGE_TEACHER_ATTACK: int = 100  # Instant death
const PLAYER_DAMAGE_ENVIRONMENT_FIRE: int = 30  # 4F special zones
const PLAYER_DAMAGE_ENVIRONMENT_FALLING: int = 20  # Corridor traps

## 1.3 Combat Stats
const PLAYER_ATTACK_DAMAGE: int = 35  # 3-hit kill on students
const PLAYER_ATTACK_COOLDOWN: float = 0.5  # seconds between attacks
const PLAYER_ATTACK_RANGE: float = 1.0  # tiles
const PLAYER_STEALTH_KILL_DAMAGE: int = 100  # 1-hit kill from behind
const PLAYER_STEALTH_KILL_CHARGE_TIME: float = 1.0  # Hold E for 1 second
const PLAYER_STEALTH_KILL_MAX_DISTANCE: float = 2.0  # tiles
const PLAYER_COMBAT_NOISE_RADIUS: float = 20.0  # tiles - attracts 3 students

## 1.4 Stamina/Battery
# No stamina system - flashlight battery only (see Item Stats)

## 1.5 Hitbox & Collision
const PLAYER_HITBOX_SIZE: Vector2 = Vector2(14, 14)  # 87.5% of tile size
const COLLISION_OVERLAP_THRESHOLD: float = 0.5  # 50% overlap required
const DOOR_TRIGGER_THRESHOLD: float = 0.5  # Center must enter door tile
const ITEM_PICKUP_RANGE: float = 1.0  # tiles from hitbox center
const STAIRS_TRIGGER_THRESHOLD: float = 0.5  # 50% overlap to change floor

# ============================================================================
# 2. ENEMY STATS
# ============================================================================

## 2.1 Student Entity (General)
const STUDENT_MAX_HP: int = 100  # 3 normal attacks or 1 stealth kill
const STUDENT_HITBOX_SIZE: Vector2 = Vector2(14, 14)  # Same as player
const STUDENT_SPEED_PATROL: float = 2.0  # 32 px/s - 33% of player walk
const STUDENT_SPEED_CHASE: float = 6.0  # 96 px/s - Same as player walk
const STUDENT_SPEED_PRAYER: float = 8.0  # 128 px/s - 133% of player walk
const STUDENT_ATTACK_DAMAGE: int = 50  # 2 hits to kill player
const STUDENT_CHASE_RELEASE_DISTANCE: float = 15.0  # tiles
const STUDENT_AGGRO_NOISE_RADIUS: float = 20.0  # tiles
const STUDENT_AGGRO_BRIGHT_LIGHT_RADIUS: float = 10.0  # tiles (strong flashlight)

## 2.2 Floor Distribution
const STUDENT_COUNT_FLOOR_1: int = 5  # 4-6 students (sparse)
const STUDENT_COUNT_FLOOR_2: int = 17  # 15-20 students (high density)
const STUDENT_COUNT_FLOOR_3: int = 17  # 15-20 students (high density)
const STUDENT_COUNT_FLOOR_4_BOUND: int = 30  # Fixed "Bound Arms" students
const STUDENT_COUNT_FLOOR_4_ROAMING: int = 30  # Roaming students
const STUDENT_COUNT_FLOOR_4_TOTAL: int = 60  # Total 4F students
const STUDENT_COUNT_FLOOR_5_AUDITORIUM: int = 300  # Integrated with chairs

## 2.3 AI State Machine Optimization
const AI_STATE_SLEEPING_DISTANCE: float = 30.0  # tiles - AI disabled
const AI_STATE_DORMANT_MIN_DISTANCE: float = 10.0  # tiles
const AI_STATE_DORMANT_MAX_DISTANCE: float = 30.0  # tiles
const AI_STATE_ACTIVE_DISTANCE: float = 10.0  # tiles - Full AI
const AI_DORMANT_CHECK_INTERVAL: float = 1.0  # seconds
const AI_ACTIVE_MAX_COUNT: int = 20  # Maximum simultaneous active AIs

## 2.4 Teacher Boss
const TEACHER_SPEED: float = 5.0  # 80 px/s - Slower than player (escapable)
const TEACHER_ATTACK_DAMAGE: int = 100  # Instant kill
const TEACHER_HP: int = -1  # Infinite (cannot be killed normally)
const TEACHER_SPAWN_NAME_TAG_THRESHOLD: int = 4  # Spawns at 4+ name tags
const TEACHER_LOCATION_BASE: int = 5  # Always on 5F initially

## 2.5 Teacher Detection by Name Tag Count
const TEACHER_DETECTION_LEVEL_4_PLUS: String = "precise"  # Exact location
const TEACHER_DETECTION_LEVEL_3: String = "approximate"  # General area
const TEACHER_DETECTION_LEVEL_2: String = "weak"  # Greatly reduced
const TEACHER_DETECTION_LEVEL_1: String = "minimal"  # Almost none

## 2.6 Boss Fight (Graduation Ceremony)
const BOSS_FIGHT_DURATION: float = 40.0  # seconds to survive
const BOSS_FIGHT_PHASE_1_DURATION: float = 10.0  # Teacher speed 5.0
const BOSS_FIGHT_PHASE_2_DURATION: float = 10.0  # Teacher speed 7.0
const BOSS_FIGHT_PHASE_3_DURATION: float = 10.0  # Teacher speed 9.0
const BOSS_FIGHT_PHASE_4_DURATION: float = 10.0  # Teacher speed 10.0
const BOSS_FIGHT_TEACHER_SPEED_PHASE_1: float = 5.0
const BOSS_FIGHT_TEACHER_SPEED_PHASE_2: float = 7.0
const BOSS_FIGHT_TEACHER_SPEED_PHASE_3: float = 9.0
const BOSS_FIGHT_TEACHER_SPEED_PHASE_4: float = 10.0

# ============================================================================
# 3. SYSTEM MECHANICS
# ============================================================================

## 3.1 Blackout System (Floor-specific)
const BLACKOUT_INTERVAL_FLOOR_1: float = 420.0  # 7 minutes
const BLACKOUT_INTERVAL_FLOOR_2: float = 300.0  # 5 minutes
const BLACKOUT_INTERVAL_FLOOR_3: float = 240.0  # 4 minutes
const BLACKOUT_INTERVAL_FLOOR_4: float = 180.0  # 3 minutes
const BLACKOUT_INTERVAL_FLOOR_5: float = -1.0  # No blackouts
const BLACKOUT_WARNING_TIME: float = 5.0  # seconds
const BLACKOUT_DURATION: float = 1.0  # seconds of darkness
const BLACKOUT_TELEPORT_MIN_DISTANCE: float = 3.0  # tiles from player
const BLACKOUT_TELEPORT_MAX_DISTANCE: float = 10.0  # tiles from player

## 3.2 Silent Prayer System
const PRAYER_TRIGGER_DELAY: float = 5.0  # seconds after student death
const PRAYER_DURATION: float = 5.0  # seconds of prayer
const PRAYER_DARKNESS_INTENSITY: float = 0.7  # 70% darker (normal mode)
const PRAYER_BRIGHTNESS_INTENSITY: float = 1.5  # 150% brighter (transfer mode)
const PRAYER_STUDENT_SPEED: float = 8.0  # 133% of player walk speed
const PRAYER_PLAYER_SPEED_TRANSFER: float = 9.0  # Same as run speed

## 3.3 Gaze System
const GAZE_MAX_DISTANCE: float = 25.0  # tiles
const GAZE_LINE_WIDTH: float = 2.0  # pixels
const GAZE_WALL_PENETRATION: bool = false  # Cannot see through walls
const GAZE_GLASS_PENETRATION: bool = true  # Can see through glass/windows
const GAZE_FRONT_ANGLE_THRESHOLD: float = 90.0  # degrees - triggers chase
const GAZE_BACK_ANGLE_THRESHOLD: float = 90.0  # degrees - no effect
const GAZE_FIRST_TIME_MESSAGE_COUNT: int = 3  # Show text for first 3 times

## 3.4 Name Tag System
const NAME_TAG_THRESHOLD_SAFE_MAX: int = 3  # 0-3 tags safe
const NAME_TAG_THRESHOLD_WARNING: int = 3  # Warning at 3 tags
const NAME_TAG_THRESHOLD_TEACHER_SPAWN: int = 4  # Teacher spawns at 4+
const NAME_TAG_REQUIRED_MIN: int = 1  # Need at least 1 to escape
const NAME_TAG_UNCLAIMED_PER_CLASSROOM: int = 1  # Hidden in each room
const NAME_TAG_UNCLAIMED_TOTAL_ESTIMATE: int = 20  # Approximate total
const NAME_TAG_DETECTION_RANGE: float = 5.0  # tiles - "Something hidden nearby"

## 3.5 Door Lock System
const DOOR_LOCK_CHANCE_SILENT: float = 0.66  # 66% no noise
const DOOR_LOCK_CHANCE_NOISE: float = 0.34  # 34% makes noise
const DOOR_LOCK_NOISE_RADIUS: float = 20.0  # tiles

# ============================================================================
# 4. ITEM STATS
# ============================================================================

## 4.1 Flashlight System (3 brightness levels)
enum FlashlightMode { OFF, WEAK, MEDIUM, STRONG }

const FLASHLIGHT_BATTERY_DRAIN_WEAK: float = 0.1  # % per second (1x)
const FLASHLIGHT_BATTERY_DRAIN_MEDIUM: float = 0.15  # % per second (1.5x)
const FLASHLIGHT_BATTERY_DRAIN_STRONG: float = 0.2  # % per second (2x)

const FLASHLIGHT_ANGLE_WEAK: float = 45.0  # degrees
const FLASHLIGHT_ANGLE_MEDIUM: float = 60.0  # degrees
const FLASHLIGHT_ANGLE_STRONG: float = 75.0  # degrees

const FLASHLIGHT_RANGE_WEAK: float = 10.0  # tiles
const FLASHLIGHT_RANGE_MEDIUM: float = 15.0  # tiles
const FLASHLIGHT_RANGE_STRONG: float = 20.0  # tiles

const FLASHLIGHT_AGGRO_WEAK: float = 0.0  # No aggro
const FLASHLIGHT_AGGRO_MEDIUM: float = 5.0  # tiles - students turn heads
const FLASHLIGHT_AGGRO_STRONG: float = 10.0  # tiles - students immediately turn

const FLASHLIGHT_EMERGENCY_BATTERY: float = 600.0  # seconds (10 minutes)
const FLASHLIGHT_INDUSTRIAL_BATTERY: float = 1800.0  # seconds (30 minutes)
const FLASHLIGHT_INDUSTRIAL_COUNT: int = 2  # Only 2 in entire game (3F, 4F)

## 4.2 Tactical Items
const GLASS_MARBLE_DURATION: float = 5.0  # seconds of distraction
const GLASS_MARBLE_COUNT_INITIAL: int = 20  # Starting marbles from Bronze Agent

## 4.3 Recovery Items
const ITEM_EMERGENCY_MEDICINE_HEAL: int = 50  # HP
const ITEM_BANDAGE_HEAL: int = 30  # HP
const ITEM_NOSTALGIA_CANDY_HEAL: int = 100  # HP (full recovery)
const ITEM_EMERGENCY_MEDICINE_PER_FLOOR: int = 2  # 2-3 per floor
const ITEM_BANDAGE_PER_FLOOR: int = 4  # 4-5 per floor
const ITEM_NOSTALGIA_CANDY_TOTAL: int = 3  # Only 3 in entire game

## 4.4 Special Items
# Quest items (no numerical stats, just flags)
const ITEM_TOMATO_TREE_TATTOO_REQUIRED: bool = true  # Happy Ending 02
const ITEM_GRADUATION_DECORATION_REQUIRED: bool = true  # 5F entrance
const ITEM_UNIFORM_TRANSFER_MODE: bool = true  # Transfer student mode
const ITEM_BRAINWASHING_PEN_ENDING_BRANCH: bool = true  # Ending branch

# ============================================================================
# 5. UI/CAMERA STATS
# ============================================================================

## 5.1 Camera & View System
const CAMERA_ZOOM: float = 2.0  # Fixed zoom level
const SCREEN_RESOLUTION: Vector2 = Vector2(1920, 1080)  # Base resolution
const VISIBLE_TILES_WIDTH: int = 60  # tiles
const VISIBLE_TILES_HEIGHT: int = 34  # tiles
const VISIBLE_AREA_PIXELS: Vector2 = Vector2(960, 544)  # At 2.0x zoom
const CAMERA_FOV_ANGLE: float = 120.0  # degrees - Less dark area
const CAMERA_FOV_MEDIUM_FLASHLIGHT: float = 140.0  # degrees
const CAMERA_FOV_STRONG_FLASHLIGHT: float = 160.0  # degrees

## 5.2 UI Element Positions (placeholder - will be refined in UI phase)
const UI_HP_BAR_SIZE: Vector2 = Vector2(150, 15)
const UI_BLACKOUT_TIMER_SIZE: Vector2 = Vector2(200, 20)
const UI_BATTERY_GAUGE_SIZE: Vector2 = Vector2(200, 15)
const UI_INVENTORY_SIZE: Vector2 = Vector2(800, 600)
const UI_QUICKSLOT_COUNT: int = 10  # 0-9 keys
const UI_SYSTEM_MESSAGE_DURATION: float = 2.0  # seconds

## 5.3 Blackout Timer Colors (by time remaining)
const BLACKOUT_TIMER_COLOR_SAFE: Color = Color.GREEN
const BLACKOUT_TIMER_COLOR_WARNING: Color = Color.YELLOW
const BLACKOUT_TIMER_COLOR_DANGER: Color = Color.RED

# Floor-specific warning thresholds (seconds before blackout)
const BLACKOUT_WARNING_THRESHOLD_FLOOR_1: float = 85.0  # 420 - 335
const BLACKOUT_WARNING_THRESHOLD_FLOOR_2: float = 65.0  # 300 - 235
const BLACKOUT_WARNING_THRESHOLD_FLOOR_3: float = 65.0  # 240 - 175
const BLACKOUT_WARNING_THRESHOLD_FLOOR_4: float = 65.0  # 180 - 115

const BLACKOUT_DANGER_THRESHOLD: float = 5.0  # Last 5 seconds always red

# ============================================================================
# 6. DIFFICULTY BALANCING
# ============================================================================

## 6.1 Floor Difficulty Ratings (for reference)
enum FloorDifficulty { TUTORIAL = 1, EASY = 2, MEDIUM = 3, HARD = 4, EXTREME = 5 }

const FLOOR_DIFFICULTY_1F: int = FloorDifficulty.TUTORIAL
const FLOOR_DIFFICULTY_2F: int = FloorDifficulty.EASY
const FLOOR_DIFFICULTY_3F: int = FloorDifficulty.MEDIUM
const FLOOR_DIFFICULTY_4F: int = FloorDifficulty.HARD
const FLOOR_DIFFICULTY_5F: int = FloorDifficulty.EXTREME

## 6.2 Recommended Name Tag Collection
const RECOMMENDED_NAME_TAGS_2F: int = 2  # By end of 2F
const RECOMMENDED_NAME_TAGS_3F: int = 3  # By end of 3F
const RECOMMENDED_NAME_TAGS_4F_MAX: int = 3  # Never go above 3 on 4F

## 6.3 Playtime Estimates (minutes)
const PLAYTIME_TUTORIAL: float = 7.5  # 5-10 minutes
const PLAYTIME_2F: float = 25.0  # 20-30 minutes
const PLAYTIME_3F: float = 25.0  # 20-30 minutes
const PLAYTIME_4F: float = 20.0  # 15-25 minutes
const PLAYTIME_5F_BOSS: float = 12.5  # 10-15 minutes
const PLAYTIME_TOTAL_FIRST_RUN: float = 180.0  # 2-4 hours (3 hours average)

# ============================================================================
# 7. SAVE SYSTEM
# ============================================================================

## 7.1 Auto-save
const AUTOSAVE_INTERVAL: float = 600.0  # seconds (10 minutes)
const AUTOSAVE_MESSAGE_DURATION: float = 2.0  # seconds

## 7.2 Manual Save
const MANUAL_SAVE_MAX_COUNT: int = 5  # Total manual saves allowed
const MANUAL_SAVE_LOCATION_3F_INFIRMARY: bool = true
const MANUAL_SAVE_LOCATION_STAIRS_BENCHES: bool = true

# ============================================================================
# 8. ENDING CONDITIONS
# ============================================================================

## Ending Types
enum EndingType {
	HAPPY_01_TRUE,  # S-rank - Library sealing
	HAPPY_02_NORMAL,  # A-rank - Graduation success
	BAD_01_LOOP,  # F-rank - 0 tags + death
	BAD_02_DELETION,  # F-rank - Teacher kill
	BAD_03_INCOMPLETE,  # D-rank - 1-3 tags + death
	BAD_04_SYSTEM_LOCKOUT  # F-rank - Graduation fail
}

## Happy Ending 02 Conditions
const ENDING_HAPPY_02_MIN_NAME_TAGS: int = 1
const ENDING_HAPPY_02_MAX_NAME_TAGS: int = 3
const ENDING_HAPPY_02_REQUIRES_DECORATION: bool = true
const ENDING_HAPPY_02_SURVIVAL_TIME: float = 40.0  # seconds

## Bad Ending Conditions
const ENDING_BAD_01_NAME_TAG_COUNT: int = 0  # Exactly 0 tags
const ENDING_BAD_02_KILLER: String = "teacher"  # Killed by teacher
const ENDING_BAD_03_MIN_NAME_TAGS: int = 1  # 1-3 tags
const ENDING_BAD_03_MAX_NAME_TAGS: int = 3  # 1-3 tags
const ENDING_BAD_04_TRIGGER: String = "graduation_fail"  # Failed ceremony

# ============================================================================
# 9. AUDIO CONSTANTS
# ============================================================================

## Sound Effect Types
const SFX_SCHOOL_BELL_TONES: int = 4  # 딩동댕동
const SFX_FOOTSTEP_VARIATION: int = 3  # Different surface types

## Music Tracks
const MUSIC_TRACK_MAIN_MENU: String = "main_menu_theme"
const MUSIC_TRACK_1F_AMBIENT: String = "floor_1_ambient"
const MUSIC_TRACK_2F_AMBIENT: String = "floor_2_ambient"
const MUSIC_TRACK_3F_AMBIENT: String = "floor_3_ambient"
const MUSIC_TRACK_4F_AMBIENT: String = "floor_4_ambient"
const MUSIC_TRACK_5F_COMBAT: String = "floor_5_combat"
const MUSIC_TRACK_GRADUATION: String = "graduation_song"
const MUSIC_TRACK_HAPPY_01: String = "happy_ending_01_theme"
const MUSIC_TRACK_BAD_ENDING: String = "bad_ending_theme"

# ============================================================================
# 10. FLOOR IDENTIFIERS
# ============================================================================

enum Floor {
	FLOOR_1 = 1,
	FLOOR_2 = 2,
	FLOOR_3 = 3,
	FLOOR_4 = 4,
	FLOOR_5 = 5,
	BACKYARD = 6  # Hidden area
}

const FLOOR_STARTING: int = Floor.FLOOR_2  # Game starts on 2F
const FLOOR_SAFE_ZONE: int = Floor.FLOOR_3  # 3F Infirmary
const FLOOR_HELL: int = Floor.FLOOR_4  # Hardest floor
const FLOOR_BOSS: int = Floor.FLOOR_5  # Boss arena

# ============================================================================
# 11. NPC IDENTIFIERS
# ============================================================================

enum NPCType {
	BRONZE_AGENT,  # Ryu Jae-gwan
	LEE_GYEOL,  # The blonde student
	HAEGEUM_AGENT,  # Team 3 leader
	CHOI_AGENT,  # Team 1 ace
	LEE_JAHEON  # Manager (alien entity)
}

# ============================================================================
# 12. TRANSFER STUDENT MODE
# ============================================================================

const TRANSFER_MODE_VISUAL_CHANGE: bool = true  # Students appear normal
const TRANSFER_MODE_BACKYARD_ACCESS: bool = true  # Can access backyard
const TRANSFER_MODE_PRAYER_BRIGHTNESS: bool = true  # Prayer brightens instead
const TRANSFER_MODE_4F_BYPASS: bool = true  # Can pass bound students

# ============================================================================
# 13. PERFORMANCE OPTIMIZATION
# ============================================================================

const TARGET_FPS: int = 60
const MAX_ACTIVE_AI_COUNT: int = 20  # Limit simultaneous active AIs
const AI_UPDATE_BUDGET_MS: float = 5.0  # Max 5ms per frame for AI
const FLOOR_TRANSITION_MAX_TIME: float = 1.0  # seconds

# ============================================================================
# 14. DEBUG FLAGS (Disable in production)
# ============================================================================

var DEBUG_MODE: bool = false  # Toggle via command line or settings
var DEBUG_SHOW_HITBOXES: bool = false
var DEBUG_SHOW_AI_STATES: bool = false
var DEBUG_SHOW_GAZE_LINE: bool = true  # Always show in gameplay
var DEBUG_INVINCIBLE: bool = false
var DEBUG_INFINITE_BATTERY: bool = false
var DEBUG_SHOW_ALL_NAME_TAGS: bool = false

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

## Convert tiles to pixels
static func tiles_to_pixels(tiles: float) -> float:
	return tiles * TILE_SIZE

## Convert pixels to tiles
static func pixels_to_tiles(pixels: float) -> float:
	return pixels / TILE_SIZE

## Convert tiles/second to pixels/second
static func tiles_per_sec_to_pixels(tiles_per_sec: float) -> float:
	return tiles_per_sec * TILE_SIZE

## Get blackout interval for floor
static func get_blackout_interval(floor: int) -> float:
	match floor:
		Floor.FLOOR_1: return BLACKOUT_INTERVAL_FLOOR_1
		Floor.FLOOR_2: return BLACKOUT_INTERVAL_FLOOR_2
		Floor.FLOOR_3: return BLACKOUT_INTERVAL_FLOOR_3
		Floor.FLOOR_4: return BLACKOUT_INTERVAL_FLOOR_4
		Floor.FLOOR_5: return BLACKOUT_INTERVAL_FLOOR_5
		_: return BLACKOUT_INTERVAL_FLOOR_2  # Default to 2F

## Get student count for floor
static func get_student_count(floor: int) -> int:
	match floor:
		Floor.FLOOR_1: return STUDENT_COUNT_FLOOR_1
		Floor.FLOOR_2: return STUDENT_COUNT_FLOOR_2
		Floor.FLOOR_3: return STUDENT_COUNT_FLOOR_3
		Floor.FLOOR_4: return STUDENT_COUNT_FLOOR_4_TOTAL
		Floor.FLOOR_5: return STUDENT_COUNT_FLOOR_5_AUDITORIUM
		_: return 0

## Get floor difficulty
static func get_floor_difficulty(floor: int) -> int:
	match floor:
		Floor.FLOOR_1: return FLOOR_DIFFICULTY_1F
		Floor.FLOOR_2: return FLOOR_DIFFICULTY_2F
		Floor.FLOOR_3: return FLOOR_DIFFICULTY_3F
		Floor.FLOOR_4: return FLOOR_DIFFICULTY_4F
		Floor.FLOOR_5: return FLOOR_DIFFICULTY_5F
		_: return FLOOR_DIFFICULTY_2F

## Check if name tag count is safe
static func is_name_tag_count_safe(count: int) -> bool:
	return count <= NAME_TAG_THRESHOLD_SAFE_MAX

## Check if teacher should spawn
static func should_teacher_spawn(count: int) -> bool:
	return count >= NAME_TAG_THRESHOLD_TEACHER_SPAWN

## Get teacher detection level by name tag count
static func get_teacher_detection_level(count: int) -> String:
	if count >= 4:
		return TEACHER_DETECTION_LEVEL_4_PLUS
	elif count == 3:
		return TEACHER_DETECTION_LEVEL_3
	elif count == 2:
		return TEACHER_DETECTION_LEVEL_2
	else:
		return TEACHER_DETECTION_LEVEL_1

func _ready() -> void:
	print("Constants loaded - SYSTEM_BALANCING.md v2.1")
	print("Tile size: %d px" % TILE_SIZE)
	print("Player walk speed: %.1f tiles/s (%.1f px/s)" % [PLAYER_SPEED_WALK, tiles_per_sec_to_pixels(PLAYER_SPEED_WALK)])
	print("Student chase speed: %.1f tiles/s (%.1f px/s)" % [STUDENT_SPEED_CHASE, tiles_per_sec_to_pixels(STUDENT_SPEED_CHASE)])
