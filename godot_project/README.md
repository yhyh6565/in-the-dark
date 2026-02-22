# In the Dark (검은 그늘 속에서)
**Godot 4.x Implementation**

## Current Phase: Phase 1.8 - Flashlight System ✅

### Implemented Features

#### Phase 1.2: Constants & Global Systems ✅
- ✅ Constants system (all SYSTEM_BALANCING.md values)
- ✅ GameManager (global state management)
- ✅ EventBus (global event system)
- ✅ SaveManager (skeleton)
- ✅ AudioManager (skeleton)

#### Phase 1.3: Player Character ✅
- ✅ Player movement system
  - Walk: 6.0 tiles/s (96 px/s)
  - Run: 9.0 tiles/s (144 px/s)
  - Crouch: 3.0 tiles/s (48 px/s)
- ✅ 8-directional movement (diagonal normalized)
- ✅ HP system (max 100)
- ✅ Camera2D with 2.0x zoom
- ✅ Placeholder sprites (14×14px blue square)

#### Phase 1.4: Tileset & 2F Map ✅
- ✅ Placeholder tileset (16×16 tiles)
  - Floor, Wall, Door, Desk, Chair, Window, Stairs
  - Physics layers for wall collision
- ✅ 2F Map Layout (60×50 tiles)
  - ㅁ-shaped corridor system
  - 8 classrooms (1-1 through 1-8)
  - Central courtyard (impassable)
  - 3 staircases (SW, SE, North-center)
- ✅ Spawn point at Class 1-5
- ✅ Camera limits (prevents out-of-bounds view)
- ✅ Wall collision (player cannot walk through walls)

#### Phase 1.5: Student Entity AI (Patrol State) ✅
- ✅ AI State Machine architecture
  - AIStateBase (interface for all states)
  - State handler system
- ✅ PatrolState implementation
  - Random waypoint selection
  - Movement at 2.0 tiles/s (32 px/s)
  - Wait 2-5 seconds at each waypoint
- ✅ Student Entity (StudentAI)
  - HP system (100 max)
  - Damage/death handling
  - Floor isolation (students stay on assigned floor)
- ✅ Distance-based optimization (Sleeping state at 30+ tiles)
- ✅ NavigationRegion2D for pathfinding
- ✅ Student spawner (15-20 students on 2F)
- ✅ Placeholder sprites (14×14 gray ovals)

#### Phase 1.6: Gaze System ✅
- ✅ GazeSystem component
  - Dotted line from player to mouse cursor
  - Raycast up to 25 tiles max distance
  - Stops at walls (cannot penetrate)
- ✅ Front/Back detection
  - Student forward direction calculated from velocity
  - Front: angle < 90° triggers chase
  - Back: angle ≥ 90° has no effect
- ✅ ChaseState implementation
  - Chase at 6.0 tiles/s (same as player walk speed)
  - Permanent chase until out of sight 5+ seconds
  - Attack on contact (50 damage)
  - Visual change (gray → red sprite)
- ✅ Gaze trigger system
  - First 3 times: Show Korean message
  - 4+ times: Visual effect only
- ✅ Line of sight tracking
  - Chase ends if out of sight for 5 seconds AND 15+ tiles away

#### Phase 1.8: Flashlight System ✅
- ✅ FlashlightSystem component
  - Integrated with player controller
  - Light2D visual representation
  - Points toward mouse cursor
- ✅ 3 brightness levels
  - Off → Weak → Medium → Strong → Off (F key cycling)
  - Weak: 45° cone, 10 tiles range, 1.0x drain
  - Medium: 60° cone, 15 tiles range, 1.5x drain
  - Strong: 75° cone, 20 tiles range, 2.0x drain
- ✅ Battery system
  - Emergency flashlight: 600s (10 minutes)
  - Drain rate based on brightness level
  - Battery percentage tracking
  - Battery depletion detection
- ✅ Frozen state for students
  - Students freeze when in flashlight cone
  - All movement stops (velocity = Vector2.ZERO)
  - Blue tint visual feedback
  - Resumes previous state (Patrol/Chase) when light moves away
- ✅ Line of sight detection
  - Raycast checks for walls between flashlight and students
  - Only freezes students with clear line of sight
- ✅ EventBus integration
  - flashlight_turned_on/off signals
  - flashlight_battery_changed signal
  - flashlight_battery_depleted signal
  - student_frozen/unfrozen signals

---

## How to Test

### Opening the Project
1. Open Godot 4.x editor
2. Click "Import" and select `project.godot` in this directory
3. Wait for assets to import
4. Press F5 to run

### Controls
- **WASD**: Move (8 directions)
- **Shift (hold)**: Run (9.0 tiles/s)
- **Ctrl (hold)**: Crouch (3.0 tiles/s)
- **F**: Cycle flashlight brightness (Off → Weak → Medium → Strong → Off)
- **ESC**: Print debug info to console

### Expected Behavior
- Player (blue square with white dot) spawns in Class 1-5
- **White dotted line extends from player to mouse cursor** (gaze line)
- **15-20 students (gray ovals) patrol around the 2F map**
- Students move at 32 px/s (2.0 tiles/s) when patrolling
- **When you look at a student's front (moving direction):**
  - Student turns RED (chasing)
  - Student chases at 96 px/s (6.0 tiles/s - same as player walk)
  - System message appears (first 3 times)
  - Chase is permanent until you break line of sight for 5+ seconds
- **When you look at a student's back:**
  - Nothing happens (strategic flanking possible)
- **Getting touched by chasing student:**
  - Takes 50 damage (2 hits = death)
- **Flashlight system (F key to cycle):**
  - Press F to cycle: Off → Weak → Medium → Strong → Off
  - Light cone points toward mouse cursor
  - Students freeze when in the light beam (blue tint)
  - Frozen students stop all movement
  - Students resume previous state when light moves away
  - Battery drains based on brightness (600s total at Weak)
  - Battery info shown in debug console (ESC)
- Player should move smoothly within the 2F map
- Walking: 96 pixels/second (same speed as chasing students!)
- Running: 144 pixels/second (can escape chasers)
- Crouching: 48 pixels/second (too slow, will be caught)
- Camera should follow player smoothly
- **Player cannot walk through walls**
- **Students cannot walk through walls**
- Camera stays within map bounds

### Verification
1. Open console (Output tab in editor)
2. Look for "Spawning X students on floor 2F..." message
3. **Test gaze line:**
   - Move mouse around - white dotted line should follow
   - Line stops at walls (max 25 tiles)
   - Line turns yellow when hitting something
   - Line turns RED when hitting a student
4. **Test chase trigger:**
   - Move mouse to look at a MOVING student's front
   - Student should turn red and start chasing
   - System message should appear (first 3 times)
   - Try looking at student's back - no effect!
5. **Test chase mechanics:**
   - Run away (Shift) - you're faster, can escape
   - Try walking - same speed as chaser (intense!)
   - Try crouching - too slow, you'll be caught
6. **Test damage:**
   - Let chasing student touch you
   - Should take 50 damage (check HP in console)
   - 2 hits = death
7. **Test chase release:**
   - Break line of sight (hide behind wall)
   - Wait 5+ seconds while far away (15+ tiles)
   - Student should return to gray (patrol)
8. **Test flashlight system:**
   - Press F to turn on flashlight (Weak mode)
   - Light cone should appear pointing toward mouse
   - Press F again to cycle: Weak → Medium → Strong → Off
   - Check console (ESC) to see battery level and brightness
9. **Test frozen state:**
   - Turn on flashlight (any brightness)
   - Point light at a patrolling student
   - Student should freeze (blue tint, stops moving)
   - Move flashlight away - student resumes patrol
10. **Test flashlight vs. chase:**
    - Trigger a student to chase you (look at front)
    - Turn on flashlight and point at chasing student
    - Student should freeze (turns blue, stops chasing)
    - Move light away - student resumes chase
    - Strategic use: freeze chasers to escape!
11. **Test battery drain:**
    - Turn on Strong mode
    - Watch battery drain in console (2x drain rate)
    - Compare with Weak mode (1x drain rate)
    - Battery should last 600s on Weak, 300s on Strong

---

## Project Structure

```
godot_project/
├── scenes/
│   ├── main/
│   │   └── test_world.tscn    (Current test scene)
│   └── player/
│       └── player.tscn         (Player character)
├── scripts/
│   ├── autoload/
│   │   ├── constants.gd
│   │   ├── game_manager.gd
│   │   ├── event_bus.gd
│   │   ├── save_manager.gd
│   │   └── audio_manager.gd
│   └── player/
│       ├── player_controller.gd
│       └── player_movement.gd
└── assets/
    └── sprites/
        └── player/
            └── player_placeholder_with_dot.png
```

---

## Next Steps

### Phase 1.7: Student AI (Chase State) - COMPLETE ✅
_Already implemented alongside Phase 1.6_

### Phase 1.8: Flashlight System - COMPLETE ✅
_Just completed!_

### Phase 1.9: Interaction System (8 hours)
- [ ] Create interaction system component
- [ ] Implement door interaction
  - E key to open/close doors
  - Door lock mechanics (66% silent, 34% noisy)
  - Noise attracts students within 20 tiles
- [ ] Implement item pickup system
  - E key to pick up items
  - Range check (1 tile from player)
  - Visual feedback (highlight on proximity)
- [ ] Create InteractionPrompt UI
  - Shows "[E] Open Door" / "[E] Pick Up X"
  - Appears when near interactable
- [ ] Test interaction with doors and items

---

## Development Notes

### Known Issues
- No actual sprites yet (using placeholder colored squares)
- No animations (will be added after sprite creation)
- No collision testing yet (will be added with 2F map)

### Performance Target
- 60 FPS stable
- Player movement should feel responsive
- No input lag

---

## Documentation Reference
- `docs/IMPLEMENTATION_PLAN.md` - Full implementation roadmap
- `docs/SYSTEM_BALANCING.md` - All numerical values
- `docs/GAME_DESIGN_SAEKWANG_HIGHSCHOOL.md` - Complete game design

---

**Last Updated**: 2026-02-22
**Phase**: 1.8 - Flashlight System
**Status**: ✅ Complete
