# 📚 프로젝트 문서 구조 가이드
## Document Structure & Dependency Guide

> **목적**: 프로젝트의 모든 문서 간 관계와 역할을 명확히 정의하여 정보 동기화 문제를 방지
> **작성일**: 2026-02-18
> **버전**: 1.0

---

## 📊 문서 계층 구조

```
┌─────────────────────────────────────────────────────────────┐
│                    Master Documents                          │
│                  (Single Source of Truth)                    │
├─────────────────────────────────────────────────────────────┤
│  SYSTEM_BALANCING.md  │  모든 수치의 최종 권한              │
│  (Numbers Master)     │  - 속도, 수명, 데미지, 개수 등      │
└───────────────┬───────┴──────────────────────────────────────┘
                │
                ├──→ CHARACTERS_AND_ITEMS.md (설명 전문)
                ├──→ LEVEL_DESIGN.md (배치 전문)
                ├──→ GAME_DESIGN.md (통합 문서)
                └──→ 기타 세부 문서들

┌─────────────────────────────────────────────────────────────┐
│                   Integration Document                       │
├─────────────────────────────────────────────────────────────┤
│  GAME_DESIGN_SAEKWANG_HIGHSCHOOL.md                         │
│  - 모든 문서의 요약 및 통합                                  │
│  - 문서 간 연결 지점 명시                                    │
│  - 개발자가 첫 번째로 읽어야 할 문서                         │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                  Specialized Documents                       │
├─────────────────────────────────────────────────────────────┤
│  각 문서는 자신의 전문 영역만 담당                           │
│  수치는 SYSTEM_BALANCING.md 참조                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 📄 문서별 역할 정의

### 🎯 Tier 1: Master Documents (최고 권한)

#### 1. SYSTEM_BALANCING.md
**역할**: **모든 게임 수치의 Single Source of Truth**
- **담당 영역**:
  - 플레이어/적 속도
  - 손전등 수명, 배터리 수명
  - HP, 데미지, 쿨타임
  - 아이템 개수, 배치 개수
  - 점멸 주기, 타이머 수치
  - UI/카메라 수치

- **다른 문서와의 관계**:
  - 모든 문서는 수치 관련 정보를 이 문서에서 참조
  - 이 문서가 업데이트되면 관련 문서 동기화 필수

- **업데이트 규칙**:
  - 수치 변경 시 버전 번호 증가
  - 변경 로그 명시
  - 영향받는 문서 목록 작성

---

### 🎯 Tier 2: Integration Document (통합)

#### 2. GAME_DESIGN_SAEKWANG_HIGHSCHOOL.md
**역할**: **프로젝트 전체 개요 및 문서 통합**
- **담당 영역**:
  - 게임 개요 및 컨셉
  - 전체 게임 흐름
  - 층별 개요 (상세는 LEVEL_DESIGN 참조)
  - 엔딩 시스템 상세
  - 각 문서로의 링크 및 요약

- **다른 문서와의 관계**:
  - 개발자가 **가장 먼저 읽어야 할 문서**
  - 모든 세부 문서의 "목차" 역할
  - 수치는 SYSTEM_BALANCING 참조
  - 상세 설명은 각 전문 문서로 링크

- **업데이트 규칙**:
  - 다른 문서 업데이트 시 이 문서도 요약 수정
  - 문서 간 링크 정확성 유지

---

### 🎯 Tier 3: Specialized Documents (전문 문서)

#### 3. CHARACTERS_AND_ITEMS.md
**역할**: **캐릭터 및 아이템 설명 전문**
- **담당 영역**:
  - 캐릭터 외형, 성격, 대사 스타일
  - 아이템 비주얼, 설명, 스토리 역할
  - 획득 방법 (위치는 언급하되 개수는 SYSTEM_BALANCING 참조)
  - 상호작용 UI/UX

- **담당하지 않는 영역**:
  - ❌ 아이템 수명/성능 수치 → SYSTEM_BALANCING
  - ❌ 아이템 정확한 개수 → SYSTEM_BALANCING
  - ❌ 맵 배치 좌표 → LEVEL_DESIGN

- **의존성**:
  - `SYSTEM_BALANCING.md` v2.0+ (수치)
  - `SCENARIO_SAEKWANG_HIGHSCHOOL.md` (대사)

- **업데이트 규칙**:
  - 수치 언급 시 반드시 SYSTEM_BALANCING 참조 표시
  - 예: "배터리 수명은 SYSTEM_BALANCING.md 참조"

---

#### 4. LEVEL_DESIGN.md
**역할**: **맵 레이아웃 및 배치 전문**
- **담당 영역**:
  - 층별 맵 구조 (타일 단위)
  - 오브젝트 배치 좌표
  - 교실/복도/특수실 레이아웃
  - 층별 아이템 배치 위치 (개수는 SYSTEM_BALANCING 참조)

- **담당하지 않는 영역**:
  - ❌ 아이템 개수 → SYSTEM_BALANCING
  - ❌ 아이템 설명 → CHARACTERS_AND_ITEMS

- **의존성**:
  - `SYSTEM_BALANCING.md` v2.0+ (배치 개수)
  - `CHARACTERS_AND_ITEMS.md` (배치할 아이템 목록)

- **업데이트 규칙**:
  - 배치 개수는 SYSTEM_BALANCING과 일치 필수
  - 새 아이템 추가 시 CHARACTERS_AND_ITEMS 확인

---

#### 5. SCENARIO_SAEKWANG_HIGHSCHOOL.md
**역할**: **시나리오 및 대사 전문**
- **담당 영역**:
  - 모든 대사 및 시스템 메시지
  - 이벤트 시퀀스
  - 컷신 연출
  - 선택지 분기

- **의존성**:
  - `CHARACTERS_AND_ITEMS.md` (캐릭터 성격)
  - `ENDING_AND_BOSS_ORIGINAL_ANALYSIS.md` (엔딩 조건)

- **업데이트 규칙**:
  - 캐릭터 대사는 CHARACTERS_AND_ITEMS의 성격과 일치
  - 엔딩 조건은 ENDING_AND_BOSS 참조

---

#### 6. HAPPY_ENDING_01_DESIGN.md
**역할**: **해피엔딩 01 상세 설계 (후순위 개발)**
- **담당 영역**:
  - 해피엔딩 01 전용 이벤트 시퀀스
  - NPC 협력 시스템
  - 부적 복구 퍼즐

- **의존성**:
  - `GAME_DESIGN_SAEKWANG_HIGHSCHOOL.md` (기본 엔딩 조건)
  - `CHARACTERS_AND_ITEMS.md` (NPC 설정)
  - `SCENARIO_SAEKWANG_HIGHSCHOOL.md` (대사)

- **업데이트 규칙**:
  - 개발 우선순위: Phase 2 이후

---

### 🎯 Tier 4: Support Documents (지원 문서)

#### 7. README.md
- **역할**: 프로젝트 소개 및 문서 네비게이션
- **의존성**: 모든 문서 (링크)

---

## 🔄 문서 의존성 매트릭스

| 문서 | 의존하는 문서 | 이 문서에 의존하는 문서 |
|:---|:---|:---|
| **SYSTEM_BALANCING.md** | 없음 (Master) | 거의 모든 문서 |
| **GAME_DESIGN.md** | 모든 문서 | README.md |
| **CHARACTERS_AND_ITEMS.md** | SYSTEM_BALANCING | LEVEL_DESIGN, SCENARIO, ASSET_LIST |
| **LEVEL_DESIGN.md** | SYSTEM_BALANCING, CHARACTERS_AND_ITEMS | ASSET_LIST |
| **SCENARIO.md** | CHARACTERS_AND_ITEMS, GAME_DESIGN | 없음 |
| **HAPPY_ENDING_01.md** | GAME_DESIGN, CHARACTERS_AND_ITEMS, SCENARIO | 없음 |

---

## 📝 문서 헤더 템플릿

모든 문서는 다음 헤더를 포함해야 합니다:

```markdown
# [문서 제목]

> **문서 역할**: [이 문서가 담당하는 영역]
> **문서 버전**: [버전 번호]
> **최종 수정일**: [YYYY-MM-DD]
> **수정자**: [수정한 사람]

---

## 📌 문서 의존성

### 이 문서가 의존하는 문서:
- `SYSTEM_BALANCING.md` v2.0+ - 모든 수치 참조
- `CHARACTERS_AND_ITEMS.md` v1.1+ - 아이템 설명 참조

### 이 문서에 의존하는 문서:
- `LEVEL_DESIGN.md` - 아이템 배치 시 이 문서 참조
- `SCENARIO.md` - 대사 작성 시 이 문서 참조

### ⚠️ 업데이트 시 동기화 필요:
이 문서를 수정하면 다음 문서들도 확인/수정 필요:
- [ ] `LEVEL_DESIGN.md` - 배치 정보
- [ ] `SCENARIO.md` - 아이템 획득 대사

---

## 📋 변경 로그

### v1.1 (2026-02-18)
- 공업용 손전등 수명 60분 → 30분으로 변경
- 영향받는 문서: CHARACTERS_AND_ITEMS.md (동기화 완료)

### v1.0 (2026-02-17)
- 초기 작성
```

---

## ✅ 문서 업데이트 체크리스트

문서를 수정할 때마다 다음을 확인하세요:

### Phase 1: 수정 전 확인
- [ ] 이 정보의 Source of Truth가 맞는가?
  - 수치 → SYSTEM_BALANCING.md인가?
  - 설명 → 해당 전문 문서인가?
- [ ] 의존하는 문서를 먼저 확인했는가?

### Phase 2: 수정 작업
- [ ] 문서 버전 번호 증가
- [ ] 최종 수정일 업데이트
- [ ] 변경 로그 작성

### Phase 3: 수정 후 동기화
- [ ] "이 문서에 의존하는 문서" 목록 확인
- [ ] 각 의존 문서에서 관련 정보 검색
- [ ] 불일치 발견 시 수정
- [ ] 의존 문서의 버전도 증가

---

## 🔍 Cross-Reference 작성법

### 수치 참조 시:
```markdown
❌ 나쁜 예:
비상 손전등의 배터리 수명은 10분입니다.

✅ 좋은 예:
비상 손전등의 배터리 수명은 **10분**입니다.
(수치 출처: `SYSTEM_BALANCING.md` v2.0, 섹션 4.1)
```

### 상세 설명 참조 시:
```markdown
❌ 나쁜 예:
김솔음은 1학년 5반 학생입니다.

✅ 좋은 예:
김솔음은 1학년 5반 학생입니다.
(캐릭터 상세: `CHARACTERS_AND_ITEMS.md`, 섹션 1)
```

### 맵 위치 참조 시:
```markdown
❌ 나쁜 예:
손전등은 2층 복도에 있습니다.

✅ 좋은 예:
손전등은 2층 복도에 배치됩니다.
(정확한 좌표: `LEVEL_DESIGN.md`, 섹션 3.5)
```

---

## 🚨 동기화 실패 방지 규칙

### Rule 1: Single Source of Truth
- 같은 정보를 여러 문서에 중복 작성 금지
- 한 문서에만 작성하고, 나머지는 참조 링크

### Rule 2: Master Document 우선
- 수치는 **무조건** SYSTEM_BALANCING.md가 Master
- 다른 문서에서 수치를 수정하지 말 것

### Rule 3: 버전 번호 필수
- 모든 문서는 버전 번호 명시
- 의존성 표시 시 버전 범위 명시 (예: v2.0+)

### Rule 4: 변경 로그 작성
- 무엇을 변경했는지 명확히 기록
- 영향받는 문서 목록 작성

### Rule 5: 동기화 체크리스트
- 한 문서 수정 후 반드시 의존 문서 확인
- 체크리스트 완료 후 커밋

---

## 📊 현재 문서 상태 (2026-02-18)

| 문서 | 버전 | 헤더 적용 | 의존성 명시 | 상태 |
|:---|:---:|:---:|:---:|:---|
| SYSTEM_BALANCING.md | v2.0 | ✅ | ✅ | 최신 |
| GAME_DESIGN.md | v1.2 | ✅ | ✅ | 최신 |
| CHARACTERS_AND_ITEMS.md | v1.2 | ✅ | ✅ | 최신 |
| LEVEL_DESIGN.md | v1.1 | ✅ | ✅ | 최신 |
| SCENARIO.md | v1.1 | ✅ | ✅ | 최신 |
| HAPPY_ENDING_01.md | v1.0 | ✅ | ✅ | 최신 |

---

## 🎯 문서 정리 완료 (2026-02-18)

### 삭제된 문서 (중복/불필요)
- ❌ **ENGINE_SELECTION.md** - Godot 4 사용으로 결정, 더 이상 불필요
- ❌ **ENDING_AND_BOSS_ORIGINAL_ANALYSIS.md** - GAME_DESIGN.md에 통합됨
- ❌ **ASSET_LIST.md** - 개발 시작 시 재작성 예정
- ❌ **TUTORIAL_FLOWCHART.md** - GAME_DESIGN.md에 통합됨
- ❌ **UI_WIREFRAME.md** - 개발 시작 시 재작성 예정

### 유지된 핵심 문서 (6개)
1. **SYSTEM_BALANCING.md** (v2.0) - 모든 수치의 Master
2. **GAME_DESIGN_SAEKWANG_HIGHSCHOOL.md** (v1.1) - 통합 문서
3. **CHARACTERS_AND_ITEMS.md** (v1.2) - 캐릭터/아이템 전문
4. **LEVEL_DESIGN.md** (v1.1) - 맵 레이아웃 전문
5. **SCENARIO_SAEKWANG_HIGHSCHOOL.md** (v1.1) - 시나리오/대사 전문
6. **HAPPY_ENDING_01_DESIGN.md** (v1.0) - 해피엔딩 01 상세 (개발 후순위)

---

**문서 버전**: 1.1
**최종 수정일**: 2026-02-18
**작성자**: Claude Code (문서 구조 설계 및 정리)
