# Godot 4.x Implementation Plan
**Project**: In the Dark (검은 그늘 속에서)
**Target**: Happy Ending 01 Complete Implementation
**Engine**: Godot 4.x (GDScript 2.0)
**Version**: 1.0
**Last Updated**: 2026-02-22

---

## Table of Contents
1. [Overview](#overview)
2. [Technical Architecture](#technical-architecture)
3. [System Dependency Graph](#system-dependency-graph)
4. [Phase 1: Core Systems (MVP to Happy Ending 02)](#phase-1-core-systems)
5. [Phase 2: Advanced Features (Happy Ending 01)](#phase-2-advanced-features)
6. [Phase 3: Polish & Production](#phase-3-polish--production)
7. [Development Timeline Estimates](#development-timeline-estimates)
8. [Asset Specifications](#asset-specifications)
9. [Testing Strategy](#testing-strategy)

---

## Overview

### Project Scope
Complete implementation of the Saekwang Industrial High School horror game from 2F starting point through Happy Ending 01 (TRUE ENDING), including all 6 endings.

### Development Philosophy
- **Iterative**: Build playable vertical slices per phase
- **Data-driven**: All values from SYSTEM_BALANCING.md
- **Modular**: Systems should be loosely coupled
- **Performance-first**: Optimize for 4F's 60 simultaneous entities

### Success Criteria (Phase 1 Complete)
- ✅ Player can navigate 2F → 3F → 4F → 5F
- ✅ Gaze system triggers student chase correctly
- ✅ Flashlight stops students (3 brightness levels)
- ✅ Blackout system teleports students per floor
- ✅ Name tag collection (0-4+ with teacher trigger)
- ✅ Silent prayer sequence works on student death
- ✅ Happy Ending 02 achievable (40s boss survival)
- ✅ Bad Endings 01-04 achievable

---

## Technical Architecture

### Godot 4.x Project Structure

```
godot_project/
├── project.godot              # Project configuration
├── .gitignore                 # Godot-specific ignores
│
├── scenes/                    # All .tscn scene files
│   ├── main/
│   │   ├── main_menu.tscn
│   │   ├── game_world.tscn
│   │   └── hud.tscn
│   │
│   ├── player/
│   │   └── player.tscn        # Player with Camera2D
│   │
│   ├── entities/
│   │   ├── student_entity.tscn
│   │   ├── teacher_boss.tscn
│   │   └── npc_base.tscn
│   │
│   ├── maps/
│   │   ├── floor_1.tscn
│   │   ├── floor_2.tscn       # Start floor
│   │   ├── floor_3.tscn
│   │   ├── floor_4.tscn       # Hell floor
│   │   ├── floor_5.tscn       # Boss arena
│   │   └── backyard.tscn      # Hidden area
│   │
│   ├── ui/
│   │   ├── inventory_ui.tscn
│   │   ├── dialogue_box.tscn
│   │   ├── blackout_timer.tscn
│   │   └── name_tag_counter.tscn
│   │
│   └── effects/
│       ├── flashlight_cone.tscn
│       ├── gaze_line.tscn
│       ├── silent_prayer_overlay.tscn
│       └── blackout_effect.tscn
│
├── scripts/                   # All .gd script files
│   ├── autoload/             # Singletons (AutoLoad)
│   │   ├── game_manager.gd   # Global state, floor transitions
│   │   ├── save_manager.gd   # Save/load system
│   │   ├── event_bus.gd      # Global event signals
│   │   └── audio_manager.gd  # Sound/music controller
│   │
│   ├── player/
│   │   ├── player_controller.gd
│   │   ├── player_movement.gd
│   │   ├── player_combat.gd
│   │   ├── gaze_system.gd
│   │   └── flashlight_controller.gd
│   │
│   ├── ai/
│   │   ├── student_ai.gd         # State machine
│   │   ├── ai_states/
│   │   │   ├── ai_state_base.gd
│   │   │   ├── patrol_state.gd
│   │   │   ├── chase_state.gd
│   │   │   ├── frozen_state.gd   # Flashlight freeze
│   │   │   └── sleeping_state.gd # 4F optimization
│   │   └── teacher_ai.gd         # Boss behavior
│   │
│   ├── systems/
│   │   ├── blackout_system.gd
│   │   ├── silent_prayer_system.gd
│   │   ├── name_tag_system.gd
│   │   ├── inventory_system.gd
│   │   └── transfer_student_mode.gd
│   │
│   ├── ui/
│   │   ├── hud_controller.gd
│   │   ├── inventory_ui.gd
│   │   ├── dialogue_manager.gd
│   │   └── menu_controller.gd
│   │
│   └── utilities/
│       ├── constants.gd          # All SYSTEM_BALANCING values
│       ├── tile_helper.gd
│       └── debug_overlay.gd
│
├── assets/                    # All game assets
│   ├── sprites/
│   │   ├── player/
│   │   │   └── [placeholder: 16x16 colored squares]
│   │   ├── entities/
│   │   │   └── [placeholder: simple shapes]
│   │   ├── items/
│   │   └── ui/
│   │
│   ├── tilesets/
│   │   ├── floor_tiles.png    # 16x16 pixel tiles
│   │   ├── walls.png
│   │   └── objects.png
│   │
│   ├── audio/
│   │   ├── sfx/
│   │   │   ├── footsteps/
│   │   │   ├── school_bell.wav
│   │   │   └── flashlight_click.wav
│   │   └── music/
│   │       ├── ambient_1f.ogg
│   │       └── graduation_song.ogg
│   │
│   └── fonts/
│       └── pixel_font.ttf
│
├── data/                      # JSON/Resource files
│   ├── dialogue/
│   │   └── npc_dialogues.json
│   ├── items/
│   │   └── item_database.json
│   └── maps/
│       └── spawn_points.json
│
└── addons/                    # Third-party plugins (if needed)
    └── [none initially]
```

### Key Architecture Decisions

#### 1. AutoLoad Singletons
**GameManager** (`res://scripts/autoload/game_manager.gd`):
- Current floor tracking
- Name tag counter (triggers teacher at 4+)
- Player HP
- Game state (playing, paused, game_over)
- Floor transition logic

**EventBus** (`res://scripts/autoload/event_bus.gd`):
- Global signals for decoupled communication
- Example signals:
  ```gdscript
  signal student_died(position: Vector2)
  signal blackout_started(floor: int)
  signal name_tag_collected(total: int)
  signal teacher_spawned()
  ```

**SaveManager** (`res://scripts/autoload/save_manager.gd`):
- Auto-save every 10 minutes
- Manual save at 3F infirmary (5 slots)
- Save data structure (JSON format)

#### 2. State Machine Pattern (AI)
All entities use state machine:
```gdscript
# student_ai.gd
class_name StudentAI extends CharacterBody2D

enum State { SLEEPING, DORMANT, PATROL, CHASE, FROZEN, PRAYER }
var current_state: State = State.PATROL
var state_handlers: Dictionary = {}

func _ready():
    state_handlers = {
        State.PATROL: PatrolState.new(self),
        State.CHASE: ChaseState.new(self),
        # ...
    }
```

#### 3. Tile-Based Movement
- **Tile size**: 16×16 pixels
- **Movement**: Smooth interpolation between tiles (not grid-locked)
- **Speed**: Defined in tiles/second (convert to pixels/second in code)
- **Collision**: Use Godot's built-in physics (CharacterBody2D)

#### 4. Camera System
- **Type**: Camera2D attached to player
- **Zoom**: 2.0x (shows 960×544px of 1920×1088px world)
- **Smoothing**: Enabled for smooth follow
- **Limits**: Set per-floor to prevent out-of-bounds view

---

## System Dependency Graph

```
[Legend]
├─ Must implement before
└─ Optional dependency

PHASE 1 DEPENDENCIES:
====================

1. Constants System (constants.gd)
   └─ (No dependencies - START HERE)

2. Player Movement
   ├─ Constants
   └─ Tile-based physics setup

3. Camera System
   └─ Player Movement

4. 2F Map (floor_2.tscn)
   ├─ Tileset creation
   └─ Constants (for tile size)

5. Student AI (Patrol only)
   ├─ Constants
   ├─ 2F Map (for navigation)
   └─ State machine base

6. Gaze System
   ├─ Player Movement
   ├─ Student AI
   └─ Camera (for mouse-to-world conversion)

7. Student AI (Chase state)
   ├─ Gaze System (trigger)
   └─ Student AI (Patrol)

8. Flashlight System
   ├─ Player Movement
   ├─ Student AI (Frozen state)
   └─ Inventory System (battery items)

9. Inventory System
   ├─ Constants
   └─ UI basic setup

10. Blackout System
    ├─ Student AI (all states)
    ├─ 2F Map (for teleport positions)
    └─ GameManager (timer tracking)

11. Combat System
    ├─ Player Movement
    ├─ Student AI
    └─ Inventory (weapons)

12. Name Tag System
    ├─ Combat System (drop on death)
    ├─ Inventory System
    └─ GameManager (counter)

13. Silent Prayer System
    ├─ Combat System (trigger on death)
    ├─ Student AI (prayer movement boost)
    └─ Audio (school bell)

14. Teacher Boss AI
    ├─ Name Tag System (spawn trigger at 4+)
    ├─ Student AI base (for movement)
    └─ 5F Map

15. 3F/4F/5F Maps
    ├─ 2F Map (template)
    ├─ Blackout System (different timers)
    └─ Student AI (spawning)

16. Graduation Ceremony (Happy Ending 02)
    ├─ Teacher Boss AI
    ├─ 5F Map
    ├─ Name Tag System (check count)
    └─ Audio (graduation song)

17. Bad Endings 01-04
    ├─ Name Tag System (check thresholds)
    ├─ Combat System (death detection)
    └─ Graduation Ceremony (fail detection)


PHASE 2 DEPENDENCIES:
====================

18. Transfer Student Mode
    ├─ Inventory (uniform item)
    ├─ Student AI (visual changes)
    └─ 3F Infirmary (trigger location)

19. Backyard Map
    ├─ Transfer Student Mode (access requirement)
    └─ 3F Map (window exit point)

20. NPC System (Bronze/Hae-geum/Choi/Lee Ja-heon)
    ├─ Dialogue System
    ├─ Inventory (special items)
    └─ Quest tracking

21. Happy Ending 01 (10-phase sequence)
    ├─ NPC System (all 4 agents)
    ├─ Backyard Map (talisman items)
    ├─ Teacher Boss AI (defeat sequence)
    └─ Custom cutscene system


PHASE 3 DEPENDENCIES:
====================

22. Tutorial System
    ├─ All Phase 1 systems
    └─ UI tutorial overlays

23. Save/Load System
    ├─ GameManager (serialize state)
    ├─ 3F Infirmary (manual save point)
    └─ All systems (state serialization)

24. Audio System (full implementation)
    ├─ All systems (trigger points)
    └─ Audio assets

25. UI Polish
    ├─ All systems (data display)
    └─ Pixel art UI assets
```

### Critical Path (Minimum Viable Product)
To get a playable demo with Happy Ending 02:
1. Constants → 2. Player Movement → 3. Camera → 4. 2F Map → 5-7. Student AI (Patrol+Chase) → 8. Flashlight → 9. Inventory → 10. Blackout → 11. Combat → 12. Name Tags → 13. Silent Prayer → 14. Teacher Boss → 15. Maps (3F/4F/5F) → 16. Graduation Ceremony

**Estimated time**: 80-120 hours for solo developer

---

## Phase 1: Core Systems

### Goal
Implement all systems required for Happy Ending 02 and Bad Endings 01-04. Player should be able to:
- Navigate from 2F (start) → 3F → 4F → 5F
- Collect name tags (avoid 4+ to prevent teacher spawn)
- Survive to 5F auditorium
- Complete 40-second graduation ceremony
- Die in various ways to see all bad endings

### Implementation Order

#### **1.1 Project Setup** (2 hours)
- [ ] Create `project.godot` with Godot 4.x settings
- [ ] Set window size: 1920×1080, stretch mode: viewport, aspect: keep
- [ ] Enable pixel snap in Project Settings → Rendering → 2D
- [ ] Configure input map (WASD, Shift, Ctrl, F, E, 0-9)
- [ ] Create folder structure as per architecture
- [ ] Add `.gitignore` for Godot projects

**Deliverable**: Empty project that opens in Godot 4.x editor

---

#### **1.2 Constants & Global Systems** (3 hours)
- [ ] Create `scripts/autoload/constants.gd`
  - All values from SYSTEM_BALANCING.md v2.1
  - Tile size, speeds, HP, damage, timers, etc.
- [ ] Create `scripts/autoload/game_manager.gd`
  - Current floor (starts at 2)
  - Name tag counter
  - Player HP (max 100)
  - Floor transition methods
- [ ] Create `scripts/autoload/event_bus.gd`
  - Define all global signals
- [ ] Set up AutoLoad in Project Settings

**Deliverable**: `constants.gd` with all game values accessible globally

---

#### **1.3 Player Character** (8 hours)
- [ ] Create `scenes/player/player.tscn`
  - CharacterBody2D root
  - Sprite2D (placeholder: 14×14px colored square)
  - CollisionShape2D (14×14px rectangle)
  - Camera2D (zoom 2.0, smoothing enabled)
- [ ] Create `scripts/player/player_movement.gd`
  - Walk: 6.0 tiles/s (96 px/s)
  - Run (Shift): 9.0 tiles/s (144 px/s)
  - Crouch (Ctrl): 3.0 tiles/s (48 px/s)
  - 8-directional movement (normalized diagonal)
- [ ] Implement HP system (current_hp/max_hp)
- [ ] Add basic animation states (idle, walk, run, crouch)

**Deliverable**: Player can move smoothly in all directions with correct speeds

**Test**:
```
- Walk 96 pixels in 1 second
- Run 144 pixels in 1 second
- Crouch 48 pixels in 1 second
```

---

#### **1.4 Tileset & 2F Map** (10 hours)
- [ ] Create placeholder tileset `assets/tilesets/floor_tiles.png`
  - 16×16 tiles: floor, wall, door, desk, chair
  - Use distinct colors for each type
- [ ] Set up TileMap in Godot
  - Tile size: 16×16
  - Physics layers for walls
- [ ] Create `scenes/maps/floor_2.tscn`
  - Layout from LEVEL_DESIGN.md (2F section)
  - ㅁ-shaped corridors
  - 8 classrooms (1-1 through 1-8)
  - Class 1-5 marked as spawn point
  - Staircases to 1F and 3F
  - NavigationRegion2D for AI pathfinding
- [ ] Add spawn point marker (Node2D) at Class 1-5 center
- [ ] Set camera limits to floor bounds

**Deliverable**: Player spawns in Class 1-5 and can walk around 2F

**Test**:
```
- Player cannot walk through walls
- Camera stays within floor bounds
- All 8 classrooms accessible
- Staircases marked (non-functional yet)
```

---

#### **1.5 Student Entity AI (Patrol State)** (12 hours)
- [ ] Create `scenes/entities/student_entity.tscn`
  - CharacterBody2D root
  - Sprite2D (placeholder: faceless ghost shape)
  - CollisionShape2D
  - NavigationAgent2D (for pathfinding)
  - Area2D (detection range: 10 tiles radius)
- [ ] Create `scripts/ai/ai_states/ai_state_base.gd` (interface)
- [ ] Create `scripts/ai/ai_states/patrol_state.gd`
  - Random waypoint selection within floor bounds
  - Move at 2.0 tiles/s (32 px/s)
  - Wait 2-5 seconds at waypoint
  - Never leave assigned floor
- [ ] Create `scripts/ai/student_ai.gd` (state machine)
  - Start in PATROL state
  - HP: 100
  - Forward direction tracking (for gaze detection)
- [ ] Spawn 15-20 students on 2F (from LEVEL_DESIGN.md)

**Deliverable**: Students wander randomly around 2F corridors

**Test**:
```
- Students navigate around obstacles
- Students move at 32 px/s
- Students never leave 2F
- Students never overlap with walls
```

---

#### **1.6 Gaze System** (10 hours)
- [ ] Create `scripts/player/gaze_system.gd`
  - Raycast from player to mouse cursor (world position)
  - Draw dotted line from player to cursor (Line2D)
  - Max gaze distance: 10 tiles (160px)
- [ ] Implement front/back detection in `student_ai.gd`
  - Calculate angle between student's forward vector and player position
  - Front: angle < 90° triggers chase
  - Back: angle ≥ 90° no effect
- [ ] Add chase trigger logic
  - When gaze line hits student's front → switch to CHASE state
  - Chase is permanent until student dies or loses line of sight for 5+ seconds

**Deliverable**: Looking at student's front triggers chase, back is safe

**Test**:
```
- Gaze line visible from player to mouse
- Looking at front of student starts chase
- Looking at back of student does nothing
- Chase persists even after looking away (until out of sight)
```

---

#### **1.7 Student AI (Chase State)** (8 hours)
- [ ] Create `scripts/ai/ai_states/chase_state.gd`
  - Use NavigationAgent2D to pathfind to player
  - Move at 6.0 tiles/s (96 px/s) - same as player walk speed
  - Update target position every 0.1s
  - Transition to PATROL if player out of sight for 5+ seconds
- [ ] Implement line-of-sight check
  - Raycast from student to player
  - Blocked by walls → loses sight
- [ ] Add damage on collision
  - Student deals 35 damage on contact (0.5s cooldown)
  - Player knockback on hit

**Deliverable**: Students chase player at same speed, can be escaped by breaking line of sight

**Test**:
```
- Chasing student moves at 96 px/s
- Student navigates around walls
- Student stops chasing after 5s out of sight
- Student deals damage on contact
```

---

#### **1.8 Flashlight System** (12 hours)
- [ ] Create `scenes/effects/flashlight_cone.tscn`
  - Polygon2D for cone shape
  - Light2D for actual lighting
  - Area2D for freeze detection (cone-shaped collision)
- [ ] Create `scripts/player/flashlight_controller.gd`
  - F key toggles: Weak → Medium → Strong → Off
  - Brightness levels:
    - Weak: 5 tiles range, 0.1%/s drain
    - Medium: 8 tiles range, 0.3%/s drain
    - Strong: 12 tiles range, 0.5%/s drain
  - Battery capacity: 600s (emergency flashlight)
- [ ] Create inventory item: Battery (restores 600s)
- [ ] Implement freeze logic in `student_ai.gd`
  - Create FROZEN state
  - When flashlight cone hits student → freeze
  - Frozen students cannot move/attack
  - Unfreeze when light turns off or leaves area

**Deliverable**: Flashlight stops all students in cone, drains battery

**Test**:
```
- F key cycles through 4 states correctly
- Weak flashlight has 5-tile cone
- Strong flashlight has 12-tile cone
- Students freeze when in light
- Students resume when light turns off
- Battery drains at correct rates
```

---

#### **1.9 Inventory System** (10 hours)
- [ ] Create `scripts/systems/inventory_system.gd` (AutoLoad)
  - 10 slots (0-9 keys)
  - Stackable items: Battery (99), Coins (99), Glass Marbles (99)
  - Non-stackable: Flashlights, Name Tags, Quest Items
- [ ] Create `scenes/ui/inventory_ui.tscn`
  - 10 slot display (bottom-center of screen)
  - Show item icons + quantity
  - Highlight selected slot (0-9 key press)
- [ ] Create item pickup system
  - Area2D on items
  - Press E to pick up
  - Show "Press E" prompt when near item
- [ ] Add basic items to 2F:
  - 3 batteries (random classrooms)
  - 5 "unclaimed" name tags (hidden in desks)

**Deliverable**: Can pick up items, see inventory, use items (batteries restore flashlight)

**Test**:
```
- Pick up battery, see in slot
- Press slot key to use battery (restores 600s)
- Stackable items show quantity
- Non-stackable items take 1 slot each
- Cannot pick up when inventory full
```

---

#### **1.10 Blackout System** (8 hours)
- [ ] Create `scripts/systems/blackout_system.gd` (attached to each floor scene)
  - Timer based on floor:
    - 1F: 7 minutes
    - 2F: 5 minutes
    - 3F: 4 minutes
    - 4F: 3 minutes
    - 5F: No blackouts
- [ ] Implement blackout sequence:
  - 5-second warning (lights flicker)
  - Screen fades to black over 1 second
  - All students on floor teleport 3-10 tiles away from player (outside vision range)
  - Screen fades back over 1 second
  - Reset timer
- [ ] Create `scenes/ui/blackout_timer.tscn`
  - Show countdown (top-right HUD)
  - Warning color when < 30 seconds

**Deliverable**: Blackouts occur on schedule, students teleport away

**Test**:
```
- 2F blackout every 5 minutes
- Students teleport to random positions 3-10 tiles from player
- Timer displays correctly
- Warning shows at 30s remaining
```

---

#### **1.11 Combat System** (10 hours)
- [ ] Create `scripts/player/player_combat.gd`
  - Attack: Left mouse click
  - Damage: 35 per hit
  - Range: 1 tile (16px)
  - Cooldown: 0.5s
  - Hitbox detection (front of player only)
- [ ] Implement stealth kill:
  - Hold E for 1 second when behind student (angle ≥ 135°)
  - Deals 100 damage (1-hit kill)
  - Requires student not chasing
- [ ] Add HP system to `student_ai.gd`
  - Max HP: 100
  - Die at 0 HP
  - Drop name tag on death (if not already collected from room)
- [ ] Add death animation/effect
  - Fade out sprite
  - Emit EventBus.student_died signal

**Deliverable**: Can kill students with 3 attacks or 1 stealth kill

**Test**:
```
- Left click deals 35 damage (3 hits to kill)
- E hold for 1s from behind kills instantly
- Cannot stealth kill chasing student
- Name tag drops on death
```

---

#### **1.12 Name Tag System** (6 hours)
- [ ] Create `scripts/systems/name_tag_system.gd` (component of GameManager)
  - Track total collected (starts at 0)
  - Emit signal at thresholds: 3 tags (warning), 4 tags (teacher spawn)
- [ ] Create `scenes/ui/name_tag_counter.tscn`
  - Display current count (top-left HUD)
  - Visual warning at 3 tags ("Teacher can detect you!")
  - Red alert at 4+ tags ("Teacher is hunting you!")
- [ ] Implement collection:
  - Pick up "unclaimed" tags from rooms (safer)
  - Receive tag when student dies (riskier)
- [ ] Add warning system:
  - At 3 tags: UI message only
  - At 4+ tags: Trigger teacher spawn (next section)

**Deliverable**: Name tag counter visible, warnings at 3 and 4+ tags

**Test**:
```
- Counter starts at 0
- Collecting tag increments counter
- Warning appears at 3 tags
- Alert appears at 4 tags (teacher doesn't spawn yet - Phase 1.14)
```

---

#### **1.13 Silent Prayer System** (8 hours)
- [ ] Create `scripts/systems/silent_prayer_system.gd` (AutoLoad)
  - Listen to EventBus.student_died signal
  - Trigger 10-second sequence:
    - 5-second warning (UI message: "You feel an eerie presence...")
    - School bell sound (딩동댕동) plays
    - 5-second prayer phase:
      - Screen darkens 70% (or brightens 150% in transfer student mode)
      - All students move at 8.0 tiles/s (128 px/s = 133% of player)
      - Player can still move/act
    - Return to normal
- [ ] Create `scenes/effects/silent_prayer_overlay.tscn`
  - Full-screen ColorRect with transparency
  - Timer display ("Silent Prayer: 5s")
- [ ] Add speed boost to `student_ai.gd`
  - PRAYER state (overrides current state temporarily)
  - Speed multiplier: 1.33x
  - Return to previous state after prayer

**Deliverable**: Killing student triggers 10s prayer sequence with visual/audio cues

**Test**:
```
- Kill student → 5s warning → school bell → 5s prayer
- Screen darkens during prayer
- Students move 33% faster during prayer
- Returns to normal after 5 seconds
```

---

#### **1.14 Teacher Boss AI** (12 hours)
- [ ] Create `scenes/entities/teacher_boss.tscn`
  - CharacterBody2D (larger sprite than students)
  - Placeholder: menacing faceless figure
  - NavigationAgent2D
- [ ] Create `scripts/ai/teacher_ai.gd`
  - Spawns on 5F when name_tag_count ≥ 4
  - Always knows player position (wallhack)
  - Move at 5.0 tiles/s (80 px/s - slower than player, escapable)
  - Damage: 100 (instant kill on contact)
  - Immune to flashlight
  - Infinite HP (cannot be killed normally)
- [ ] Add stagger mechanic (glass hand cannon only - Phase 2)
- [ ] Implement spawn sequence:
  - Listen to EventBus.teacher_spawned signal (triggered by name tag system)
  - Cutscene: Screen shake, ominous sound
  - Teacher appears in 5F auditorium
  - Begins hunting player

**Deliverable**: Teacher spawns at 4+ tags, chases player relentlessly but can be outrun

**Test**:
```
- Collect 4th name tag → teacher spawns
- Teacher moves at 80 px/s (slower than player's 96 px/s walk)
- Teacher always pathfinds to player (ignores walls for pathfinding)
- Teacher kills player on contact (instant 100 damage)
- Flashlight has no effect on teacher
```

---

#### **1.15 Additional Floors** (20 hours total)

**1F Map** (5 hours):
- [ ] Create `scenes/maps/floor_1.tscn`
- [ ] Layout: Cafeteria, library (Hanbbit Library), admin office, counseling room
- [ ] Spawn 4-6 students (low density)
- [ ] Blackout timer: 7 minutes
- [ ] Staircase connections to 2F and backyard entrance (locked until transfer student mode)
- [ ] Gray color filter

**3F Map** (6 hours):
- [ ] Create `scenes/maps/floor_3.tscn`
- [ ] Layout: Classes 2-1 through 2-7, infirmary
- [ ] **Infirmary = SAFE ZONE**:
  - No students inside
  - HP recovery spot (interact with bed)
  - Manual save point (5 slots)
  - Lee Gyeol spawn location (Phase 2)
- [ ] Blackout timer: 4 minutes
- [ ] Green color filter
- [ ] Window exit to backyard (requires transfer student mode - Phase 2)

**4F Map** (7 hours):
- [ ] Create `scenes/maps/floor_4.tscn`
- [ ] **HELL FLOOR** layout:
  - Complete darkness (no ambient light)
  - All corridors lined with students
  - 60 students total:
    - 30 "Bound Arms" (fixed positions, never move)
    - 30 roaming students (patrol)
- [ ] Blackout timer: 3 minutes (highest difficulty)
- [ ] Blue color filter (barely visible)
- [ ] Storage room with graduation decoration item (quest item for 5F access)
- [ ] Implement AI optimization:
  - Students > 30 tiles away: SLEEPING state (0% CPU)
  - Students 10-30 tiles away: DORMANT state (check distance every 1s)
  - Students < 10 tiles: ACTIVE state (full AI)

**5F Map** (2 hours):
- [ ] Create `scenes/maps/floor_5.tscn`
- [ ] Layout: Auditorium (boss arena)
- [ ] Red color filter
- [ ] No blackouts
- [ ] Entrance requires graduation decoration (from 4F storage)
- [ ] Teacher spawn point (also spawns here when 4+ tags collected anywhere)

**Deliverable**: All 5 floors playable, can navigate 2F → 3F → 4F → 5F

**Test**:
```
- Can climb stairs from 2F to 3F
- 3F infirmary restores HP
- 4F has 60 students (30 fixed + 30 roaming)
- Performance stays > 60 FPS on 4F
- 5F entrance blocked without graduation decoration
```

---

#### **1.16 Graduation Ceremony (Happy Ending 02)** (10 hours)
- [ ] Create `scenes/main/graduation_ceremony.tscn`
  - Triggered when player enters 5F auditorium with:
    - Graduation decoration item ✓
    - 1-3 name tags (safe zone) ✓
- [ ] Implement 40-second survival sequence:
  - **Phase 1 (0-10s)**: Teacher slow approach (5.0 tiles/s)
  - **Phase 2 (10-20s)**: Teacher speeds up (7.0 tiles/s)
  - **Phase 3 (20-30s)**: Teacher maximum speed (9.0 tiles/s = player run speed)
  - **Phase 4 (30-40s)**: Teacher desperate lunge (10.0 tiles/s)
  - All 4F students teleport to auditorium, chase player
  - Graduation song plays (looping audio)
- [ ] Add survival UI:
  - Timer countdown (40s → 0s)
  - "Survive until the song ends!"
  - Red vignette increasing with time
- [ ] Implement ending trigger:
  - If player survives 40 seconds → Happy Ending 02 cutscene
  - If player dies → Bad Ending 04
- [ ] Create `scenes/endings/happy_ending_02.tscn`
  - Text scroll: "The students are freed from the curse..."
  - Show ending grade: A-rank (Epic)
  - Return to main menu button

**Deliverable**: Happy Ending 02 achievable by surviving graduation ceremony

**Test**:
```
- Enter 5F with decoration + 1-3 tags → ceremony starts
- Teacher speeds up in 4 phases
- All students from 4F appear in auditorium
- Surviving 40s shows Happy Ending 02
- Dying shows Bad Ending 04
```

---

#### **1.17 Bad Endings** (8 hours)
- [ ] Create `scenes/endings/bad_ending_01.tscn` (Loop Ending)
  - Trigger: Die with 0 name tags
  - Text: "김솔음은 영원히 이 학교에 갇혔다..."
  - Grade: F-rank (Trash)
  - Option: Restart from beginning

- [ ] Create `scenes/endings/bad_ending_02.tscn` (Deletion Ending)
  - Trigger: Die from teacher (4+ tags) before reaching auditorium
  - Text: "김솔음은 현실에서 지워졌다..."
  - Grade: F-rank (Trash)
  - Glitch effect on screen

- [ ] Create `scenes/endings/bad_ending_03.tscn` (Death Ending)
  - Trigger: Die with 1-3 name tags (not from teacher)
  - Text: "시체에서 B~C급 꿈 용액을 추출했다..."
  - Grade: D-rank (Common)
  - Shows dream solution extraction

- [ ] Create `scenes/endings/bad_ending_04.tscn` (System Lockout)
  - Trigger: Fail graduation ceremony (die during 40s)
  - Text: "모두가 선생님의 시종이 되었다..."
  - Grade: F-rank (Trash)
  - Zombie apocalypse ending

**Deliverable**: All 4 bad endings achievable based on death conditions

**Test**:
```
- Die with 0 tags → Bad Ending 01
- Die from teacher → Bad Ending 02
- Die with 2 tags (not from teacher) → Bad Ending 03
- Die during ceremony → Bad Ending 04
```

---

#### **1.18 Main Menu & HUD** (6 hours)
- [ ] Create `scenes/main/main_menu.tscn`
  - New Game button
  - Load Game button (grayed out until saves exist)
  - Settings button
  - Quit button
- [ ] Create `scenes/main/hud.tscn`
  - HP bar (top-left)
  - Name tag counter (top-left, below HP)
  - Blackout timer (top-right)
  - Flashlight battery gauge (bottom-left)
  - Floor indicator (bottom-right: "2F", "3F", etc.)
  - Inventory slots (bottom-center: 10 slots)
  - Auto-save icon (flashes when saving)
- [ ] Implement pause menu (ESC key)
  - Resume
  - Save Game (only in safe zones)
  - Load Game
  - Settings
  - Quit to Menu

**Deliverable**: Functional main menu and in-game HUD

**Test**:
```
- New Game starts at 2F Class 1-5
- HUD shows all required elements
- Pause menu accessible with ESC
- Quit to menu works without errors
```

---

### Phase 1 Completion Criteria
- ✅ All systems 1.1 through 1.18 implemented and tested
- ✅ Happy Ending 02 achievable
- ✅ All 4 Bad Endings achievable
- ✅ No game-breaking bugs
- ✅ Performance: 60 FPS on 4F with 60 students
- ✅ Playthrough time: 30-60 minutes (2F → 5F → Ending)

**Playtesting Checklist**:
```
□ Start at 2F Class 1-5
□ Navigate to 3F, find infirmary
□ Collect 2 name tags (stay in safe zone)
□ Use flashlight to freeze students
□ Experience blackout on 2F (5 min), 3F (4 min), 4F (3 min)
□ Navigate 4F with 60 students (use stealth)
□ Find graduation decoration in 4F storage
□ Reach 5F auditorium
□ Survive 40-second graduation ceremony
□ See Happy Ending 02
□ Replay and get all 4 Bad Endings
```

---

## Phase 2: Advanced Features

### Goal
Implement Happy Ending 01 (TRUE ENDING) and all related systems:
- Transfer student mode (visual changes, backyard access)
- Backyard hidden map (talisman items)
- NPC cooperation system (Bronze, Hae-geum, Choi, Lee Ja-heon)
- 10-phase Happy Ending 01 sequence (talisman completion, teacher defeat, library sealing)

### Implementation Order

#### **2.1 Transfer Student Mode** (10 hours)
- [ ] Create quest item: Saekwang High Uniform (찾아보기 in 3F infirmary)
- [ ] Implement visual mode toggle:
  - Normal mode: Students appear as faceless ghosts
  - Transfer mode: Students appear as normal uniformed students (less scary)
  - Brightness during silent prayer (instead of darkness)
- [ ] Add backyard access:
  - 3F infirmary window becomes interactable
  - Press E to exit to backyard (only in transfer mode)
- [ ] Implement 4F corridor bypass:
  - "Bound Arms" (fixed students) don't attack in transfer mode
  - Can walk past them safely

**Deliverable**: Obtaining uniform changes visuals and enables backyard access

---

#### **2.2 Backyard Hidden Map** (8 hours)
- [ ] Create `scenes/maps/backyard.tscn`
  - Small outdoor area (20×15 tiles)
  - Contains: Broken glass lantern (item)
  - Contains: Torn talisman (item)
  - No enemies
  - Exit returns to 3F infirmary window
- [ ] Create quest items:
  - Broken glass lantern (pickup)
  - Torn talisman (pickup)
  - These trigger Happy Ending 01 route when both collected

**Deliverable**: Backyard accessible from 3F, contains talisman items

---

#### **2.3 NPC System Foundation** (12 hours)
- [ ] Create `scripts/npc/npc_base.gd` (base class)
  - Dialogue interaction (press E)
  - Quest state tracking
  - Item giving/receiving
- [ ] Create `scripts/ui/dialogue_manager.gd`
  - Display NPC name + dialogue text
  - Choice buttons (up to 4 options)
  - Portrait display (placeholder)
  - Typewriter text effect
- [ ] Implement dialogue data structure (JSON):
  ```json
  {
    "npc_id": "bronze_agent",
    "dialogues": [
      {
        "id": "first_meeting",
        "text": "아, 드디어 사람을 만났네요...",
        "choices": [
          {"text": "당신은 누구죠?", "next": "introduce"},
          {"text": "어떻게 여기 들어왔어요?", "next": "how_entered"}
        ]
      }
    ]
  }
  ```

**Deliverable**: Dialogue system functional, can talk to NPCs

---

#### **2.4 Bronze Agent (Ryu Jae-gwan)** (6 hours)
- [ ] Create `scenes/entities/npc_bronze.tscn`
  - Spawn location: 2F Class 1-3 (random classroom)
  - Available from game start
- [ ] Implement dialogue tree from SCENARIO doc
- [ ] Implement item exchange:
  - Give player: Glass hand cannon + 20 glass marbles
  - Glass hand cannon stagger mechanic:
    - Right-click to shoot marble
    - Hitting teacher staggers for 3 seconds (can run away)
    - Limited ammo (20 marbles, find more in classrooms)
- [ ] Add quest flag: "bronze_agent_met"

**Deliverable**: Bronze agent gives glass hand cannon, can stagger teacher

---

#### **2.5 Lee Gyeol (The Blonde Student)** (8 hours)
- [ ] Create `scenes/entities/npc_lee_gyeol.tscn`
  - Initial spawn: 3F hallway (injured, sitting)
  - Appears only after helping him (give bandage)
- [ ] Implement dialogue tree:
  - Initial: Cynical, untrusting
  - After helping: Opens up, tells backstory
  - Reveals name only after Happy Ending 01 trigger
- [ ] Create quest: Help Lee Gyeol
  - Give bandage → unlocks infirmary access
  - He moves to infirmary after healing
  - Enables uniform acquisition (hidden in infirmary cabinet)
- [ ] Add quest flag: "lee_gyeol_helped"

**Deliverable**: Can help Lee Gyeol, unlock transfer student mode

---

#### **2.6 Hae-geum Agent** (6 hours)
- [ ] Create `scenes/entities/npc_haegeum.tscn`
  - Spawn location: 3F staircase (appears only after talisman items collected)
  - Leader of Team 3
- [ ] Implement dialogue tree
- [ ] Give spirit sword (Sain-geom) item:
  - Special weapon (replaces normal attack temporarily)
  - Can temporarily "defeat" teacher (10-second death, respawns)
  - Required for Happy Ending 01 (final battle)
- [ ] Add quest flag: "haegeum_agent_met"

**Deliverable**: Hae-geum gives spirit sword, can temp-kill teacher

---

#### **2.7 Choi Agent** (5 hours)
- [ ] Create `scenes/entities/npc_choi.tscn`
  - Spawn location: 4F storage room (appears after meeting Hae-geum)
  - Team 1 ace, PTSD from past incident
- [ ] Implement dialogue tree (more reluctant to help)
- [ ] Give talisman component:
  - Sutra paper (combines with broken lantern + torn talisman)
  - Creates complete talisman (final item for Happy Ending 01)
- [ ] Add quest flag: "choi_agent_met"

**Deliverable**: Choi gives sutra paper, enables talisman completion

---

#### **2.8 Lee Ja-heon (Manager)** (7 hours)
- [ ] Create `scenes/entities/npc_lee_jaheon.tscn`
  - Spawn location: 5F auditorium entrance (appears only during Happy Ending 01 sequence)
  - Alien entity (white lizard mask, superhuman strength)
- [ ] Implement dialogue (reveals true nature: "We" or "Alliance")
- [ ] Create cooperation mechanic:
  - Lee Ja-heon holds teacher during final battle
  - Player must complete talisman ritual while teacher is restrained
  - Time limit: 30 seconds
- [ ] Add quest flag: "lee_jaheon_met"

**Deliverable**: Lee Ja-heon assists in final boss fight

---

#### **2.9 Happy Ending 01 Sequence** (20 hours)

This is the most complex system in the game. Implement in 10 phases:

**Phase 1: Trigger Condition Check**
- [ ] Detect player has:
  - Broken glass lantern ✓
  - Torn talisman ✓
  - Sutra paper (from Choi) ✓
  - Spirit sword (from Hae-geum) ✓
  - Transfer student mode active ✓
- [ ] Spawn all NPCs in correct positions
- [ ] Trigger cutscene when entering 5F

**Phase 2: Initial Cutscene (30 seconds)**
- [ ] Camera pans to auditorium
- [ ] Teacher appears, roars
- [ ] Hae-geum agent appears, draws spirit sword
- [ ] Dialogue: "We'll handle this. You complete the talisman!"

**Phase 3: NPC Combat Phase (60 seconds)**
- [ ] Hae-geum fights teacher (scripted combat)
  - Sword slashes (visual effects)
  - Teacher staggers but doesn't die
- [ ] Bronze agent provides cover fire (glass marbles)
- [ ] Player must navigate to library (1F Hanbbit Library)

**Phase 4: Talisman Assembly Puzzle (45 seconds)**
- [ ] Player reaches library "private corner"
- [ ] UI puzzle: Combine 3 items in correct order
  - Broken glass lantern → Torn talisman → Sutra paper
  - Creates "Complete Talisman"
- [ ] Timer: 45 seconds (teacher is chasing)

**Phase 5: Return to Auditorium (30 seconds)**
- [ ] Player must run back to 5F
- [ ] Teacher chases at max speed (10.0 tiles/s)
- [ ] NPCs provide distractions (scripted)

**Phase 6: Barrier Activation (QTE)**
- [ ] Reach auditorium stage
- [ ] QTE sequence: Press keys in order (E-R-Space-E)
- [ ] Success: Barrier forms around teacher
- [ ] Failure: Teacher escapes, Bad Ending 02

**Phase 7: Lee Gyeol's Sacrifice**
- [ ] Cutscene: Lee Gyeol steps forward
- [ ] Dialogue: "I've been here long enough... Let me do this."
- [ ] Lee Gyeol enters barrier, triggers talisman
- [ ] Emotional dialogue (reveals his name: "My name is Lee Gyeol.")

**Phase 8: Teacher Defeat**
- [ ] Talisman activates (visual: bright golden light)
- [ ] Teacher screams, disintegrates
- [ ] All student entities freeze, then fade
- [ ] School begins to collapse (screen shake)

**Phase 9: Library Sealing**
- [ ] Lee Ja-heon reveals true form (alien entity)
- [ ] Dialogue: "We will seal this school in a safe place."
- [ ] Cutscene: Entire school shrinks into library's private corner
- [ ] 60-second camera work mimicking original novel:
  - Pan through empty school hallways
  - Show students sleeping peacefully in library
  - Close on Kim Sol-eum's face (relieved)

**Phase 10: Ending Credits**
- [ ] Text scroll: TRUE ENDING
- [ ] Grade: S-rank (Legendary)
- [ ] Ending text from HAPPY_ENDING_01_DESIGN.md
- [ ] Post-credits: All students await rescue in library (frozen in time)
- [ ] Return to main menu (unlock New Game+)

**Deliverable**: Full Happy Ending 01 sequence playable, all 10 phases functional

**Test**:
```
□ Collect all required items
□ Trigger cutscene at 5F
□ NPCs spawn correctly
□ Navigate to library during combat
□ Complete talisman puzzle in 45s
□ Return to auditorium
□ Pass QTE sequence
□ Watch Lee Gyeol sacrifice
□ See teacher defeat
□ Watch 60s camera ending
□ Reach ending credits
```

---

### Phase 2 Completion Criteria
- ✅ Transfer student mode functional
- ✅ Backyard accessible and contains talisman items
- ✅ All 4 NPCs (Bronze, Lee Gyeol, Hae-geum, Choi) implemented
- ✅ Lee Ja-heon (Manager) appears in Happy Ending 01
- ✅ Happy Ending 01 achievable (10-phase sequence)
- ✅ No game-breaking bugs in complex sequence
- ✅ Playtesting: Complete Happy Ending 01 start-to-finish

---

## Phase 3: Polish & Production

### Goal
Transform the functional game into a polished, release-ready product:
- Tutorial system (teach mechanics gradually)
- Full save/load system (manual + auto-save)
- Complete audio design (SFX + music)
- UI polish (pixel-perfect 8-bit style)
- Performance optimization
- Extensive playtesting and balancing

### Implementation Order

#### **3.1 Tutorial System** (12 hours)
- [ ] Create 8-stage tutorial (from UI_SPECIFICATION.md):
  1. Movement (WASD)
  2. Running (Shift)
  3. Gaze system (mouse aiming)
  4. Flashlight (F key, battery management)
  5. Combat (left-click attack)
  6. Stealth kill (E hold from behind)
  7. Inventory (0-9 keys, E pickup)
  8. Safe zones (infirmary, save points)
- [ ] Implement tutorial overlay UI:
  - Semi-transparent instruction boxes
  - Animated key press hints
  - Progress tracker (1/8, 2/8, etc.)
  - Skip tutorial option (for replay)
- [ ] First-time player detection (save flag)
- [ ] Tutorial dismissal after completion

**Deliverable**: New players complete 10-minute tutorial before main game

---

#### **3.2 Save/Load System** (15 hours)
- [ ] Expand `save_manager.gd` to serialize all game state:
  - Player position (floor, coordinates)
  - Player HP, inventory (all 10 slots)
  - Name tag count
  - Flashlight battery level
  - Quest flags (all NPC interactions)
  - Student entity states (dead/alive, positions)
  - Blackout timers (current time remaining)
- [ ] Implement auto-save:
  - Every 10 minutes (background save)
  - Floor transition (save before entering new floor)
  - Safe zone entry (3F infirmary)
- [ ] Create manual save UI (3F infirmary only):
  - 5 save slots
  - Show save details: Date/time, floor, playtime, name tags
  - Overwrite confirmation
- [ ] Implement load system:
  - Load from main menu
  - Load from pause menu (only to last save)
  - Restore all game state exactly
- [ ] Add death respawn options:
  - Start over (2F Class 1-5)
  - Load last save (auto or manual)
  - Return to main menu

**Deliverable**: Can save/load game state perfectly, no data loss

**Test**:
```
□ Save at 3F infirmary → quit → load → exact same state
□ Auto-save during gameplay → crash → reopen → restored
□ 5 manual save slots work independently
□ Loaded game continues blackout timers correctly
□ All quest flags preserved
```

---

#### **3.3 Audio System (Full)** (20 hours)

**SFX Implementation** (10 hours):
- [ ] Player sounds:
  - Footsteps (walk/run/crouch - different tiles: wood, concrete)
  - Attack swings
  - Damage grunt
  - Flashlight click (toggle on/off)
  - Item pickup
- [ ] Student entity sounds:
  - Patrol idle (breathing, shuffling)
  - Chase scream (when triggered)
  - Death sound
  - Prayer chanting (during silent prayer)
- [ ] Environment sounds:
  - School bell (딩동댕동 - 4 tones)
  - Blackout warning (lights flickering)
  - Door open/close
  - Wind ambience (backyard)
- [ ] UI sounds:
  - Menu button clicks
  - Inventory slot selection
  - Warning alerts (3 tags, 4 tags)
  - Save/load confirmation

**Music Implementation** (10 hours):
- [ ] Create/source 8-bit style music tracks:
  - Main menu theme (calm, mysterious)
  - 1F ambient (low tension, exploration)
  - 2F ambient (tutorial zone, safe feeling)
  - 3F ambient (medium tension)
  - 4F ambient (high tension, horror)
  - 5F combat theme (boss fight intensity)
  - Graduation song (for ceremony - actual Korean school song)
  - Happy Ending 01 theme (emotional, uplifting)
  - Bad Ending theme (somber, creepy)
- [ ] Implement dynamic music system:
  - Crossfade between tracks on floor transition
  - Increase intensity when teacher chasing
  - Silence during silent prayer (only school bell)
- [ ] Volume mixing (from audio_manager.gd):
  - Master volume
  - Music volume
  - SFX volume
  - Adjustable in settings menu

**Deliverable**: Full audio experience, all sounds and music integrated

---

#### **3.4 UI Polish** (18 hours)

**HUD Refinement** (8 hours):
- [ ] Design pixel-perfect UI elements:
  - HP bar (heart containers or numeric + bar)
  - Name tag counter (icon + number)
  - Blackout timer (clock icon + countdown)
  - Flashlight battery (battery icon + percentage)
  - Floor indicator (large stylized number)
- [ ] Inventory slot visuals:
  - 16×16px item icons (pixel art style)
  - Selected slot highlight (golden border)
  - Stack quantity display (small number overlay)
- [ ] Warning/alert animations:
  - 3-tag warning: Pulsing yellow border
  - 4-tag alert: Flashing red border + siren icon
  - Low HP: Red vignette + heartbeat effect
  - Low battery: Blinking battery icon

**Menu Polish** (6 hours):
- [ ] Main menu design:
  - Title logo (pixel art: "In the Dark" / "검은 그늘 속에서")
  - Animated background (flickering lights)
  - Button hover effects
  - Version number display
- [ ] Pause menu design:
  - Semi-transparent overlay
  - Clean button layout
  - Quick stats display (floor, tags, HP)
- [ ] Settings menu:
  - Volume sliders (Master, Music, SFX)
  - Fullscreen toggle
  - VSync toggle
  - Key rebinding (optional)

**Ending Screens Polish** (4 hours):
- [ ] Unique visual style per ending:
  - Happy Ending 01: Bright, warm colors, cherry blossoms
  - Happy Ending 02: Triumphant, school exterior in sunrise
  - Bad Ending 01: Dark loop symbol, eternal repetition
  - Bad Ending 02: Glitch effects, static noise
  - Bad Ending 03: Cold, clinical lab scene (dream extraction)
  - Bad Ending 04: Apocalyptic school, zombie students
- [ ] Grade display:
  - S-rank: Gold, shimmering
  - A-rank: Silver, gleaming
  - D/F-rank: Gray, dull

**Deliverable**: Polished, cohesive UI matching 8-bit pixel art aesthetic

---

#### **3.5 Performance Optimization** (10 hours)
- [ ] AI optimization (4F with 60 students):
  - Verify state machine (SLEEPING/DORMANT/ACTIVE) working
  - Profile CPU usage (should be < 15% for AI)
  - Optimize pathfinding (update rate based on distance)
- [ ] Rendering optimization:
  - Enable GPU particles (not CPU)
  - Cull off-screen sprites
  - Use VisibleOnScreenNotifier2D for entities
- [ ] Memory optimization:
  - Pool student entities (reuse instead of destroy/create)
  - Unload unused floor scenes (keep only current ± 1 floor)
- [ ] Frame rate target: 60 FPS on:
  - 4F with 60 students visible
  - Silent prayer with all students moving fast
  - Graduation ceremony with teacher + students

**Deliverable**: Stable 60 FPS in all scenarios on mid-range hardware

**Test**:
```
□ 4F with 60 students: 60 FPS stable
□ No frame drops during blackout teleport
□ Smooth camera movement (no jitter)
□ Fast loading times between floors (< 1s)
```

---

#### **3.6 Balancing & Playtesting** (20 hours)

**Difficulty Balancing** (10 hours):
- [ ] Player speed vs. student speed:
  - Confirm walk = student chase (both 6.0 tiles/s)
  - Run should comfortably escape (9.0 vs 6.0)
  - Teacher should be barely escapable (5.0 vs 6.0 walk)
- [ ] Flashlight battery economy:
  - Emergency flashlight (600s) should last 2F → 3F
  - Industrial flashlight (1800s) should last 3F → 5F
  - 3-5 batteries available per floor
- [ ] Name tag balance:
  - Recommend 1-3 tags (safe zone)
  - 15-20 "unclaimed" tags per floor (safer than killing)
  - 30-40 students per floor (can get tags from kills)
- [ ] Damage balance:
  - Player: 35 damage (3-hit kill feels fair)
  - Student: 35 damage (can take 2-3 hits before danger)
  - Teacher: 100 damage (instant kill maintains threat)
- [ ] Blackout timing:
  - 2F: 5 min (enough time to explore classrooms)
  - 3F: 4 min (moderate pressure)
  - 4F: 3 min (high pressure, need to move fast)

**Full Playthrough Testing** (10 hours):
- [ ] Happy Ending 01 route:
  - Time to complete: 120-180 minutes (first playthrough)
  - Collect all items, meet all NPCs, complete puzzle
  - Test QTE sequence (should be challenging but fair)
  - Verify all 10 phases trigger correctly
- [ ] Happy Ending 02 route:
  - Time to complete: 60-90 minutes (direct route)
  - 40-second ceremony should be survivable with skill
  - Test multiple strategies (kiting, hiding, running)
- [ ] Bad Ending routes:
  - Each bad ending should be achievable naturally
  - Death scenarios should feel fair (not cheap)
- [ ] Speedrun route:
  - Experienced players should complete Happy Ending 02 in 30-45 min
  - Test if any exploits/skips exist (patch if game-breaking)

**Deliverable**: Balanced difficulty curve, all endings achievable with fair challenge

---

#### **3.7 Bug Fixing & QA** (15 hours)
- [ ] Test all edge cases:
  - Die during blackout (should still trigger correctly)
  - Save/load during silent prayer (should restore state)
  - Teacher spawn while in safe zone (should not enter)
  - Flashlight on during blackout (should stay on)
  - Inventory full when picking up name tag (should drop or deny)
- [ ] Test all endings:
  - Verify correct ending triggers based on conditions
  - No softlocks (can always progress or die)
  - Ending screens display correctly
- [ ] Test floor transitions:
  - No player getting stuck in walls
  - Camera limits correct on all floors
  - Students don't follow between floors
- [ ] Test AI behaviors:
  - Students don't get stuck on obstacles
  - Pathfinding works in all hallways
  - Teacher always finds player (no stuck states)
- [ ] Memory leak testing:
  - Play for 2+ hours (no crashes)
  - Load/save repeatedly (no corruption)
  - Kill 100+ students (no memory buildup)

**Deliverable**: Zero known game-breaking bugs, smooth experience

---

#### **3.8 Localization Preparation** (8 hours)
- [ ] Extract all text to JSON files:
  - Dialogue strings
  - UI text
  - Item descriptions
  - Ending text
  - Tutorial instructions
- [ ] Korean (native) implementation:
  - Verify all Korean text displays correctly
  - Test font rendering (Hangul support)
- [ ] English translation (optional):
  - Translate all extracted strings
  - Create language toggle in settings
- [ ] Text overflow handling:
  - UI boxes resize for longer text
  - Line breaks handled gracefully

**Deliverable**: Game fully playable in Korean, English-ready

---

#### **3.9 Final Build & Distribution** (5 hours)
- [ ] Configure export settings:
  - Windows (64-bit) build
  - macOS (Universal) build (optional)
  - Linux (x86_64) build (optional)
  - HTML5 (WebGL) build for web deployment
- [ ] Optimize export:
  - Remove debug symbols
  - Compress textures (lossless)
  - Minimize executable size
- [ ] Create installer (Windows):
  - Inno Setup or similar
  - Desktop shortcut option
  - Uninstaller
- [ ] Test exported builds:
  - Run on clean Windows 10/11 machine
  - Verify all assets load correctly
  - Check save file paths (user directory)

**Deliverable**: Release-ready builds for target platforms

---

### Phase 3 Completion Criteria
- ✅ Tutorial system functional and helpful
- ✅ Save/load system robust (no data loss)
- ✅ Full audio implementation (SFX + music)
- ✅ Polished UI (pixel-perfect 8-bit style)
- ✅ 60 FPS stable performance
- ✅ Balanced difficulty (playtested)
- ✅ Zero game-breaking bugs
- ✅ Builds exported and tested
- ✅ Ready for release

---

## Development Timeline Estimates

### Solo Developer (Part-time: 20 hours/week)

| Phase | Tasks | Estimated Hours | Estimated Weeks |
|-------|-------|----------------|-----------------|
| **Phase 1** | Core Systems (1.1 - 1.18) | 143 hours | 7-8 weeks |
| **Phase 2** | Advanced Features (2.1 - 2.9) | 82 hours | 4-5 weeks |
| **Phase 3** | Polish & Production (3.1 - 3.9) | 123 hours | 6-7 weeks |
| **Buffer** | Unforeseen issues, iteration | 50 hours | 2-3 weeks |
| **TOTAL** | | **398 hours** | **19-23 weeks (~5-6 months)** |

### Solo Developer (Full-time: 40 hours/week)

| Phase | Estimated Weeks |
|-------|----------------|
| Phase 1 | 3.5-4 weeks |
| Phase 2 | 2-2.5 weeks |
| Phase 3 | 3-3.5 weeks |
| Buffer | 1-1.5 weeks |
| **TOTAL** | **10-12 weeks (~2.5-3 months)** |

### Team of 2-3 Developers

| Phase | Estimated Weeks (Parallel Work) |
|-------|-------------------------------|
| Phase 1 | 4-5 weeks |
| Phase 2 | 2-3 weeks |
| Phase 3 | 3-4 weeks |
| **TOTAL** | **9-12 weeks (~2-3 months)** |

**Note**: These are estimates based on:
- Developer(s) familiar with Godot 4.x
- GDScript proficiency
- No major technical blockers
- Asset creation handled separately (placeholder art OK)

---

## Asset Specifications

### Placeholder Art (Phase 1 & 2)

Since art assets will be created separately, use colored geometric shapes:

#### **Sprites**
- **Player**: 14×14px blue square (with small white dot for direction indicator)
- **Student Entity**: 14×14px gray oval (faceless ghost)
- **Teacher Boss**: 20×24px black rectangle (imposing figure)
- **NPCs**: 14×14px colored squares:
  - Bronze Agent: Orange square
  - Lee Gyeol: Yellow square (blonde)
  - Hae-geum Agent: Green square
  - Choi Agent: Purple square
  - Lee Ja-heon: White square (alien)

#### **Tiles** (16×16px)
- **Floor**: Light gray (#CCCCCC)
- **Wall**: Dark gray (#333333)
- **Door**: Brown (#8B4513)
- **Desk**: Wooden brown (#D2691E)
- **Chair**: Lighter brown (#DEB887)
- **Stairs**: Yellow (#FFD700) with arrow
- **Safe zone (infirmary bed)**: Green (#00FF00)

#### **Items** (12×12px icons)
- **Name Tag**: White rectangle with black border
- **Battery**: Yellow cylinder
- **Flashlight**: Gray handle + yellow bulb
- **Uniform**: Blue shirt icon
- **Glass Hand Cannon**: Silver gun shape
- **Glass Marble**: Blue circle
- **Talisman Items**: Red/gold symbols

#### **UI Elements**
- **HP Bar**: Red bar (empty: dark red)
- **Battery Gauge**: Yellow bar (empty: gray)
- **Flashlight Cone**: Semi-transparent yellow triangle (3 sizes)
- **Gaze Line**: White dotted line (2px width)

### Final Art Style (Phase 3 - Production)

**Visual Direction**: 8-bit pixel art inspired by:
- **Yume Nikki** (atmospheric, surreal)
- **Ib** (horror, clean pixel work)
- **OneShot** (detailed environments, expressive characters)

**Specifications**:
- **Resolution**: All sprites divisible by 16px (tile grid alignment)
- **Color Palette**: Limited palette (16-32 colors per sprite)
- **Animation**: 2-4 frames per action (idle, walk, attack)
- **Lighting**: Godot's Light2D for flashlight (dynamic)
- **Filters**: Color overlays per floor (gray/yellow/green/blue/red)

**Asset List for Final Production**:
1. Player sprite sheet (idle, walk, run, crouch, attack - 4 directions)
2. Student entity sheet (patrol, chase, frozen, death - 4 directions)
3. Teacher boss sheet (idle, walk, attack, death - 4 directions)
4. NPC portraits (5 NPCs × 3 expressions each)
5. Tileset (floors, walls, furniture - 100+ tiles)
6. Item icons (30+ items)
7. UI elements (HUD, menus, buttons)
8. Ending illustrations (6 unique ending screens)

**Production Notes**:
- Create assets in phases (prioritize Phase 1 needs first)
- Use Aseprite or similar pixel art tool
- Export as PNG (no compression for pixel-perfect quality)
- Organize by category (player/, entities/, tilesets/, items/, ui/)

---

## Testing Strategy

### Unit Testing (Per System)
Each system should have specific test criteria (see Phase 1 sections for details).

### Integration Testing (Per Phase)
- **Phase 1**: Full playthrough 2F → 5F → Happy Ending 02
- **Phase 2**: Full playthrough with Happy Ending 01 route
- **Phase 3**: Stress testing (long play sessions, edge cases)

### Playtester Feedback (Phase 3)
- Recruit 5-10 external playtesters
- Provide playtest questionnaire:
  - Was the tutorial clear?
  - Did you understand the gaze vs. flashlight mechanics?
  - Was the difficulty fair?
  - Did you encounter any bugs?
  - Which ending did you get first?
  - Overall enjoyment (1-10 scale)
- Iterate based on feedback

### Performance Benchmarks
- **4F with 60 students**: 60 FPS stable
- **Blackout transition**: < 0.5s freeze time
- **Floor loading**: < 1s load time
- **Save/load**: < 0.3s save, < 2s load

---

## Conclusion

This implementation plan provides a complete roadmap from empty Godot project to release-ready horror game. By following the phased approach:

- **Phase 1** delivers a fully playable game with Happy Ending 02 and all bad endings
- **Phase 2** adds the complex TRUE ENDING (Happy Ending 01) with NPC cooperation
- **Phase 3** polishes everything for public release

The dependency graph ensures systems are built in the correct order, and the time estimates help set realistic expectations.

**Next Steps**:
1. Set up Godot 4.x project (Section 1.1)
2. Create constants.gd with all SYSTEM_BALANCING values (Section 1.2)
3. Begin implementing systems in order (1.3 → 1.4 → ...)
4. Playtest each system before moving to the next
5. Iterate and refine based on testing

Good luck with development! 🎮
