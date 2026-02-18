# 검은 그늘 속에서 (In the Dark)

8비트 픽셀아트 호러 어드벤처 게임 기획 프로젝트

## 📖 프로젝트 개요

"괴담에 떨어져도 출근을 해야 하는구나" 원작의 **세광공업고등학교 에피소드**를 기반으로 한 8비트 레트로 호러 게임입니다.

세광공업고등학교를 배경으로, 플레이어는 전학생 김솔음이 되어 괴담에 갇힌 학교에서 5층 강당의 졸업식을 완수하는 것이 목표입니다.

## 🎮 게임 컨셉

- **장르**: 8비트 픽셀아트 호러 어드벤처 / 생존 퍼즐
- **그래픽 스타일**: 8비트 픽셀아트 (EarthBound, Undertale, Yume Nikki 스타일)
- **플랫폼**: PC (추후 모바일 확장 가능)
- **플레이 시간**: 1회 플레이 2-4시간 (멀티 엔딩)

## 🌟 핵심 메커니즘

1. **시선 메커니즘**: 학생들을 바라보는 동안만 움직임이 정지
2. **점멸 시스템**: 전등이 깜박일 때마다 적들이 순간이동
3. **명찰 수집**: 현실 귀환을 위한 생존 아이템 (과다 수집 시 위험)
4. **묵념 시스템**: NPC 사망 시 5초간 화면이 어두워지며 적들이 자유롭게 이동
5. **졸업식 완수**: 최종 목표는 5층 강당에서 졸업식을 성공적으로 끝내는 것

## 📁 프로젝트 구조

```
in-the-dark/
├── .claude/
│   └── commands/
│       ├── story-review.md      # 게임 시나리오 작가/기획자 에이전트
│       └── fact-check.md        # 원작 고증 점검 에이전트
├── references/
│   ├── 검은_그늘_속에서_나무위키.md     # 나무위키 리서치 자료
│   ├── NOVEL_TRANSCRIPT_SAEKWANG.md    # 원작 소설 (세광공고 에피소드)
│   ├── NOVEL_TRANSCRIPT_SAEKWANG_HAPPYENDING.md  # 원작 소설 (해피엔딩)
│   └── USER_JOURNEY_KIM_SOLEUM.md      # 플레이어 유저 저니
├── DOCUMENT_STRUCTURE.md               # 📚 문서 구조 가이드 (필독!)
├── SYSTEM_BALANCING.md                 # ⚖️ 모든 수치의 Source of Truth
├── GAME_DESIGN_SAEKWANG_HIGHSCHOOL.md  # 메인 게임 기획서 (통합 문서)
├── CHARACTERS_AND_ITEMS.md             # 캐릭터 및 아이템 명세서
├── LEVEL_DESIGN.md                     # 레벨 디자인 상세
├── SCENARIO_SAEKWANG_HIGHSCHOOL.md     # 상세 시나리오 및 대사
├── HAPPY_ENDING_01_DESIGN.md           # 해피엔딩 01 상세 기획 (개발 후순위)
├── README.md
└── .gitignore
```

## 📄 주요 문서

### 🎯 필독 문서 (시작 전 필수!)
- **[DOCUMENT_STRUCTURE.md](./DOCUMENT_STRUCTURE.md)** ⭐ **가장 먼저 읽으세요!**
  - 프로젝트 문서 구조 및 의존성 가이드
  - 문서 업데이트 체크리스트
  - Cross-reference 작성법
  - Source of Truth 정의

### 🎮 게임 기획서

#### Master Document (최고 권한)
- **[SYSTEM_BALANCING.md](./SYSTEM_BALANCING.md)** ⚖️ **모든 수치의 Source of Truth**
  - 플레이어/적 속도, HP, 데미지
  - 손전등 수명, 배터리 개수
  - 점멸 주기, UI 수치
  - **수치 변경은 반드시 이 문서에서!**

#### Integration Document (통합 문서)
- **[GAME_DESIGN_SAEKWANG_HIGHSCHOOL.md](./GAME_DESIGN_SAEKWANG_HIGHSCHOOL.md)** 📖 **개발자가 가장 먼저 읽을 문서**
  - 게임 개요 및 시스템
  - 맵 디자인 및 레벨 구조 (요약)
  - 멀티 엔딩 시스템 (개요)
  - 각 전문 문서로의 링크

#### Specialized Documents (전문 문서)
- **[CHARACTERS_AND_ITEMS.md](./CHARACTERS_AND_ITEMS.md)** 👥 **캐릭터/아이템 설명 전문**
  - 플레이어 및 동료 NPC 정보
  - 백일몽 주식회사 & 재난관리국 캐릭터
  - 아이템 설명 및 획득 방법
  - ⚠️ 수치는 SYSTEM_BALANCING.md 참조

- **[LEVEL_DESIGN.md](./LEVEL_DESIGN.md)** 🗺️ **맵 레이아웃 전문**
  - 층별 타일맵 구조
  - 오브젝트 배치 좌표
  - 아이템 배치 위치
  - ⚠️ 배치 개수는 SYSTEM_BALANCING.md 참조

- **[SCENARIO_SAEKWANG_HIGHSCHOOL.md](./SCENARIO_SAEKWANG_HIGHSCHOOL.md)** 🎭 **시나리오/대사 전문**
  - 주요 이벤트 상세 시나리오
  - NPC 대화 및 선택지
  - 퍼즐 및 이벤트 트리거

- **[HAPPY_ENDING_01_DESIGN.md](./HAPPY_ENDING_01_DESIGN.md)** 🌙 **해피엔딩 01 (개발 후순위)**
  - 도서관에 잠든 학교 엔딩
  - 7단계 상세 시퀀스
  - 다중 NPC 협력 시스템

### 📚 참고 자료
- **[검은_그늘_속에서_나무위키.md](./references/검은_그늘_속에서_나무위키.md)**: 나무위키 원작 설정 리서치
- **[NOVEL_TRANSCRIPT_SAEKWANG.md](./references/NOVEL_TRANSCRIPT_SAEKWANG.md)**: 원작 소설 전문
- **[NOVEL_TRANSCRIPT_SAEKWANG_HAPPYENDING.md](./references/NOVEL_TRANSCRIPT_SAEKWANG_HAPPYENDING.md)**: 원작 해피엔딩 버전
- **[USER_JOURNEY_KIM_SOLEUM.md](./references/USER_JOURNEY_KIM_SOLEUM.md)**: 플레이어 유저 저니 맵

## 🤖 Claude Code 에이전트

이 프로젝트는 Claude Code의 슬래시 커맨드 에이전트를 활용합니다:

### `/story-review`
경력 20년차 게임 시나리오 작가 및 기획자로서:
- 스토리 구조 및 논리적 일관성 분석
- 게임 구현 로직 검토 (메커닉과 스토리의 조화)
- 캐릭터 개연성 및 세계관 일관성 확인
- 플레이어 경험 관점에서의 개선점 제안

### `/fact-check`
원작 "괴담에 떨어져도 출근을 해야 하는구나" 고증 점검:
- 원작 설정과 게임 기획의 일치 여부 확인
- 세계관, 캐릭터, 메커니즘 고증 검증
- 원작 팬들이 만족할 수 있는 수준의 디테일 확인

## 🎯 개발 목표

- [ ] 게임 기획 완성도 향상
- [ ] 원작 고증 강화
- [ ] 프로토타입 개발
- [ ] 플레이테스트 및 피드백 수집
- [ ] 정식 출시

## 🔗 관련 프로젝트

이 프로젝트는 [gottawork](https://github.com/yeonheedo/gottawork) 메인 프로젝트의 서브모듈입니다.

## 📝 라이선스

TBD (추후 결정)

## 👥 기여

현재는 개인 프로젝트로 진행 중입니다.

---

**"괴담에 떨어져도 출근을 해야 하는구나"** 원작에 대한 존중과 사랑을 담아 제작하고 있습니다.
