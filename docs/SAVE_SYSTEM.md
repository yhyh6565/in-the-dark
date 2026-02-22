# 💾 세이브 시스템 명세서
## Save System Specification - 검은 그늘 속에서

> **문서 역할**: 세이브/로드 시스템 전문 (Specialized Document)
> **문서 버전**: 1.0 (Phase A 신규)
> **최종 수정일**: 2026-02-22
> **수정자**: Claude Code

> **문서 목적**: 세이브 데이터 구조, 저장/로드 플로우, 자동/수동 저장 시스템 정의

---

## 📌 문서 의존성

### 이 문서가 의존하는 문서:
- `SYSTEM_BALANCING.md` v2.1+ - 세이브 시스템 수치 (자동 저장 간격 등)
- `CHARACTERS_AND_ITEMS.md` v1.4+ - 인벤토리 저장 데이터
- `GAME_DESIGN_SAEKWANG_HIGHSCHOOL.md` - NPC 상태, 게임 진행도

### 이 문서에 의존하는 문서:
- Godot 구현 코드 - 세이브 데이터 구조 참조

---

## 📋 목차

1. [세이브 데이터 구조](#1-세이브-데이터-구조)
2. [자동 저장 시스템](#2-자동-저장-시스템)
3. [수동 저장 시스템](#3-수동-저장-시스템)
4. [로드 시스템](#4-로드-시스템)
5. [사망 시 리스폰](#5-사망-시-리스폰)
6. [슬롯 관리](#6-슬롯-관리)

---

## 1. 세이브 데이터 구조

### 1.1 JSON 스키마

```json
{
  "save_metadata": {
    "save_slot": 1,
    "character_name": "김솔음",
    "playtime_seconds": 3245,
    "save_type": "manual",
    "timestamp": "2026-02-22T15:30:45Z",
    "game_version": "1.0.0"
  },

  "player_state": {
    "position": {
      "x": 450.5,
      "y": 320.0,
      "floor": 2
    },
    "hp": 100,
    "max_hp": 100,
    "movement_state": "walking",
    "equipped_uniform": false
  },

  "inventory": {
    "slots": [
      {"slot": 0, "item_id": "emergency_flashlight", "quantity": 1, "durability": 450},
      {"slot": 1, "item_id": "battery", "quantity": 12, "durability": null},
      {"slot": 2, "item_id": "name_tag", "quantity": 1, "durability": null, "tag_name": "최민준"},
      {"slot": 3, "item_id": "name_tag", "quantity": 1, "durability": null, "tag_name": "박서연"},
      {"slot": 4, "item_id": "coin", "quantity": 5, "durability": null},
      {"slot": 5, "item_id": null, "quantity": 0, "durability": null},
      {"slot": 6, "item_id": null, "quantity": 0, "durability": null},
      {"slot": 7, "item_id": null, "quantity": 0, "durability": null},
      {"slot": 8, "item_id": null, "quantity": 0, "durability": null},
      {"slot": 9, "item_id": null, "quantity": 0, "durability": null}
    ],
    "flashlight_equipped": true,
    "flashlight_brightness": "medium",
    "flashlight_battery_remaining": 450
  },

  "npc_states": {
    "lee_gyeol": {
      "met": true,
      "rescued": true,
      "awakened": false,
      "uniform_given": false,
      "location": "floor_3_infirmary"
    },
    "ryu_jaegwan_bronze": {
      "met": true,
      "items_received": ["유리손포", "유리구슬"],
      "quest_tags_requested": true,
      "tags_delivered": 2
    },
    "baek_saheon": {
      "met": false,
      "warning_given": false,
      "status": "alive"
    },
    "lee_jaheon": {
      "briefing_received": true
    }
  },

  "game_progress": {
    "tags_collected_total": 2,
    "students_defeated": 5,
    "teacher_triggered": false,
    "floors_visited": [1, 2, 3],
    "tutorial_completed": true,
    "endings_unlocked": [],
    "happy_ending_01_available": false
  },

  "world_state": {
    "current_floor": 2,
    "blackout_timer_floor_2": 180.5,
    "graduation_ceremony_triggered": false,
    "floor_4_students_moved": false,
    "looted_items": [
      "floor_2_classroom_1_5_desk_flashlight",
      "floor_2_classroom_1_3_locker_battery_01",
      "floor_2_hallway_battery_02"
    ],
    "opened_doors": [
      "floor_2_classroom_1_5",
      "floor_2_classroom_1_3",
      "floor_3_infirmary"
    ],
    "defeated_students": [
      "floor_2_student_03",
      "floor_2_student_07"
    ]
  },

  "statistics": {
    "deaths": 0,
    "blackouts_experienced": 3,
    "silent_prayers_survived": 1,
    "distance_walked_tiles": 1250,
    "flashlight_time_seconds": 540
  }
}
```

### 1.2 데이터 필드 설명

#### save_metadata
- `save_slot`: 저장 슬롯 번호 (1-5)
- `playtime_seconds`: 총 플레이 시간 (초 단위)
- `save_type`: "manual" 또는 "auto"
- `timestamp`: 저장 시각 (ISO 8601)
- `game_version`: 게임 버전 (호환성 체크용)

#### player_state
- `position`: 플레이어 위치 (x, y 픽셀 좌표 + 층)
- `hp`/`max_hp`: 현재/최대 HP
- `movement_state`: "walking", "running", "crouching" 등
- `equipped_uniform`: 전학생 모드 활성화 여부 (세광공고 교복 착용)

#### inventory
- `slots`: 10개 슬롯 배열 (null = 빈 슬롯)
- `item_id`: 아이템 고유 ID
- `quantity`: 개수 (중첩 가능 아이템만, 손전등/명찰 등은 1)
- `durability`: 내구도 (손전등 배터리 잔량, 초 단위)
- `tag_name`: 명찰의 경우 학생 이름

#### npc_states
- NPC별 상태 추적
- `met`: 만난 적 있는지
- `rescued`/`awakened` 등: NPC 특수 상태
- `items_received`: 받은 아이템 목록

#### game_progress
- `tags_collected_total`: 총 수집한 명찰 수 (버린 것 포함)
- `teacher_triggered`: 선생님 추격 시작 여부
- `endings_unlocked`: 달성한 엔딩 목록
- `happy_ending_01_available`: 해피엔딩 01 조건 충족 여부

#### world_state
- `blackout_timer_floor_X`: 각 층 점멸 타이머 현재 값
- `looted_items`: 이미 루팅한 아이템 ID 목록 (재생성 방지)
- `opened_doors`: 열린 문 목록
- `defeated_students`: 처치된 학생 개체 ID 목록 (재생성 방지)

#### statistics
- 플레이 통계 (엔딩 화면 표시용)

---

## 2. 자동 저장 시스템

> **출처**: SYSTEM_BALANCING.md v2.0 Section 7.1

### 2.1 자동 저장 조건

| 트리거 | 간격/조건 | 저장 위치 |
|:---|:---:|:---|
| **시간 기반** | 10분마다 | 현재 위치 그대로 |
| **층 이동** | 계단 사용 시 | 도착 층 계단 앞 |
| **안전 지대 진입** | 양호실 진입 시 | 양호실 내부 |
| **보스 전투 직전** | 5층 강당 진입 전 | 5층 강당 입구 |
| **주요 이벤트 직전** | NPC 이벤트 시작 전 | 이벤트 직전 위치 |

### 2.2 자동 저장 플로우

```
[자동 저장 트리거 발생]
  ↓
[화면 우측 하단 "저장 중..." 아이콘 표시 (1초)]
  ↓
[세이브 데이터 JSON 생성]
  ↓
[autosave.json 파일 덮어쓰기]
  ↓
[성공 시: 아이콘 페이드 아웃]
[실패 시: "저장 실패" 경고 (3초)]
```

### 2.3 자동 저장 UI

- **위치**: 화면 우측 하단
- **아이콘**: 💾 회전 애니메이션
- **텍스트**: "자동 저장 중..."
- **크기**: 64x32px
- **지속 시간**: 1초 (성공 시), 3초 (실패 시)

---

## 3. 수동 저장 시스템

> **출처**: SYSTEM_BALANCING.md v2.0 Section 7.2

### 3.1 수동 저장 조건

- **장소 제한**: 양호실(3층)에서만 가능
- **저장 슬롯**: 5개 (Slot 1-5)
- **저장 방법**: 양호실 내 책상 상호작용 → E키 → 저장 메뉴

### 3.2 저장 메뉴 UI

```
┌─────────────────────────────────────┐
│          세이브 선택                 │
├─────────────────────────────────────┤
│ [Slot 1] 2층 복도 - 15:30  (사용 중)│
│   플레이 시간: 0:54:05              │
│   명찰: 2개                         │
│                                     │
│ [Slot 2] 3층 양호실 - 16:12 (사용중)│
│   플레이 시간: 1:23:40              │
│   명찰: 0개                         │
│                                     │
│ [Slot 3] (비어있음)                 │
│                                     │
│ [Slot 4] (비어있음)                 │
│                                     │
│ [Slot 5] (비어있음)                 │
├─────────────────────────────────────┤
│ [←→] 선택  [Enter] 저장  [ESC] 취소│
└─────────────────────────────────────┘
```

### 3.3 덮어쓰기 확인

```
┌─────────────────────────────────────┐
│   기존 저장 데이터를 덮어쓰시겠습니까?│
│                                     │
│   Slot 2: 3층 양호실 - 16:12       │
│   플레이 시간: 1:23:40              │
│                                     │
│   [예]  [아니오]                    │
└─────────────────────────────────────┘
```

---

## 4. 로드 시스템

### 4.1 로드 가능 시점

| 시점 | 로드 방법 |
|:---|:---|
| **메인 메뉴** | "Continue" 버튼 → 슬롯 선택 |
| **게임 중** | ESC 메뉴 → "Load Game" → 슬롯 선택 |
| **사망 시** | 게임 오버 화면 → "Load" 선택 |

### 4.2 로드 플로우

```
[슬롯 선택]
  ↓
[세이브 파일 읽기 (save_slot_X.json)]
  ↓
[호환성 체크 (game_version)]
  ↓ 성공
[페이드 아웃 (0.5초, 검은색)]
  ↓
[씬 로드 (층 데이터)]
  ↓
[플레이어 상태 복원]
  - 위치 (x, y, floor)
  - HP, 인벤토리
  - 장착 아이템
  ↓
[NPC 상태 복원]
  - 이결 깨어남 여부
  - 청동 아이템 전달 여부
  ↓
[월드 상태 복원]
  - 루팅된 아이템 제거
  - 처치된 학생 제거
  - 열린 문 상태
  - 점멸 타이머
  ↓
[페이드 인 (0.5초)]
  ↓
[게임 재개]
```

### 4.3 호환성 체크 실패 시

```
┌─────────────────────────────────────┐
│   세이브 파일이 현재 버전과          │
│   호환되지 않습니다.                 │
│                                     │
│   파일 버전: 0.9.5                  │
│   게임 버전: 1.0.0                  │
│                                     │
│   [확인]                            │
└─────────────────────────────────────┘
```

---

## 5. 사망 시 리스폰

> **출처**: GAME_DESIGN.md Section 6

### 5.1 사망 플로우

```
[HP 0 도달 또는 즉사 공격]
  ↓
[사망 애니메이션 (2초)]
  - 캐릭터 쓰러짐
  - 화면 흔들림 (Shake)
  ↓
[화면 페이드 아웃 (1초, 빨간색 비네팅)]
  ↓
[게임 오버 UI 표시 (3초 대기)]
  ↓
[선택지 제공]
```

### 5.2 게임 오버 UI

```
┌─────────────────────────────────────┐
│                                     │
│           GAME OVER                 │
│                                     │
│     사망 원인: 학생 개체 공격       │
│                                     │
│                                     │
│   [처음부터 시작]                    │
│   [마지막 저장 지점에서 로드]        │
│   [메인 메뉴로]                      │
│                                     │
└─────────────────────────────────────┘
```

### 5.3 선택지별 동작

| 선택지 | 동작 |
|:---|:---|
| **처음부터 시작** | 새 게임 시작 (2층 1-5반 책상) |
| **마지막 저장 지점에서 로드** | 가장 최근 세이브 (자동/수동) 로드 |
| **메인 메뉴로** | 타이틀 화면으로 복귀 |

### 5.4 로드 시 복원 내용

| 항목 | 복원 내용 |
|:---|:---|
| **HP** | 100% 완전 회복 |
| **인벤토리** | 저장 시점 상태 |
| **NPC 상태** | 저장 시점 상태 (이결 깨어남 여부 등) |
| **월드 상태** | 루팅된 아이템, 처치된 학생 그대로 |
| **점멸 타이머** | 저장 시점 값 (리셋 안 됨) |

---

## 6. 슬롯 관리

### 6.1 슬롯 정보 표시

각 슬롯에 표시되는 정보:
- **위치**: "X층 지역명" (예: "2층 복도", "3층 양호실")
- **타임스탬프**: "HH:MM" 형식
- **플레이 시간**: "H:MM:SS" 형식
- **명찰 개수**: "X개"
- **썸네일**: 저장 위치 스크린샷 (선택, 구현 부하 고려)

### 6.2 슬롯 삭제

```
슬롯 선택 → [Delete] 키
  ↓
┌─────────────────────────────────────┐
│   정말 이 세이브를 삭제하시겠습니까?  │
│                                     │
│   Slot 3: 4층 복도 - 18:45         │
│   플레이 시간: 2:05:20              │
│                                     │
│   이 작업은 취소할 수 없습니다.      │
│                                     │
│   [예]  [아니오]                    │
└─────────────────────────────────────┘
  ↓ [예]
[save_slot_3.json 파일 삭제]
  ↓
[슬롯 목록 갱신]
```

### 6.3 파일 경로

- **Windows**: `%APPDATA%/GottaWork/InTheDark/saves/`
- **macOS**: `~/Library/Application Support/GottaWork/InTheDark/saves/`
- **Linux**: `~/.local/share/GottaWork/InTheDark/saves/`

### 6.4 파일 명명 규칙

- **자동 저장**: `autosave.json`
- **수동 저장**: `save_slot_1.json` ~ `save_slot_5.json`
- **백업**: `save_slot_X.json.backup` (덮어쓰기 전 자동 백업)

---

## 7. 구현 체크리스트

### Phase 1: 기본 저장/로드
- [ ] JSON 세이브 데이터 구조 구현
- [ ] 자동 저장 (10분 타이머)
- [ ] 수동 저장 (양호실)
- [ ] 로드 시스템
- [ ] 슬롯 UI (5개)

### Phase 2: 고급 기능
- [ ] 층 이동 시 자동 저장
- [ ] 호환성 체크
- [ ] 덮어쓰기 확인 UI
- [ ] 슬롯 삭제 기능

### Phase 3: 사망 시스템
- [ ] 사망 애니메이션
- [ ] 게임 오버 UI
- [ ] 리스폰 플로우
- [ ] HP/인벤토리 복원

### Phase 4: 통계 및 디버그
- [ ] 플레이 통계 수집
- [ ] 엔딩 화면 통계 표시
- [ ] 세이브 파일 검증 툴

---

## 8. 에러 핸들링

### 8.1 저장 실패

```
┌─────────────────────────────────────┐
│        저장에 실패했습니다.          │
│                                     │
│   오류: 디스크 공간 부족            │
│                                     │
│   [재시도]  [취소]                  │
└─────────────────────────────────────┘
```

### 8.2 로드 실패

```
┌─────────────────────────────────────┐
│      세이브 파일이 손상되었습니다.   │
│                                     │
│   파일: save_slot_2.json           │
│                                     │
│   백업 파일을 시도하시겠습니까?      │
│   (마지막 백업: 10분 전)            │
│                                     │
│   [백업 로드]  [포기]               │
└─────────────────────────────────────┘
```

### 8.3 자동 백업

- 수동 저장 시 덮어쓰기 전 `.backup` 파일 생성
- 최대 1개 백업 유지 (이전 백업은 삭제)
- 로드 실패 시 백업 파일 자동 제안

---

## 9. 보안 및 무결성

### 9.1 체크섬

- 세이브 파일에 SHA-256 체크섬 추가
- 로드 시 체크섬 검증
- 불일치 시 "파일 손상" 경고

```json
{
  "checksum": "a1b2c3d4e5f6...",
  "save_metadata": {...},
  ...
}
```

### 9.2 암호화 (선택)

- 치트 방지가 필요한 경우 AES-256 암호화 고려
- Phase 1에서는 미적용 (개발 편의성 우선)
- 정식 출시 시 선택적 적용

---

**문서 종료**
