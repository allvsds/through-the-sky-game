# 하늘을 뚫어라 (Through The Sky)

모바일 캐주얼 게임으로, 플레이어가 다양한 벽을 뚫으며 무기를 업그레이드하고 레벨을 올리는 게임입니다.

## 설치 및 실행 방법

### 필요 소프트웨어
- Godot Engine 4.5 이상
- Ubuntu/Linux 환경에서의 설치 방법:

```bash
# Flatpak 설치 (필요한 경우)
sudo apt install flatpak

# Flathub 저장소 추가
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Godot Engine 설치
sudo flatpak install flathub org.godotengine.Godot
```

### 프로젝트 실행
1. Godot Engine 실행: `flatpak run org.godotengine.Godot`
2. 프로젝트 임포트: `through-the-sky-game` 폴더의 `project.godot` 파일 선택
3. 게임 실행: F5 키 또는 재생 버튼 클릭

## 게임 기능

### 현재 구현된 기능
- ✅ 기본 벽 파괴 시스템
- ✅ 무기 진행 시스템 (바늘 → 이쑤시개 → 꼬챙이 → 연필 → 랜스)
- ✅ 경험치 및 레벨업 시스템
- ✅ 7가지 벽 타입 (종이벽 → 강철벽)
- ✅ 기본 UI (레벨, 무기, 공격력, 경험치, 마나 표시)
- ✅ 시각적 피드백 (데미지 표시, 레벨업 효과)

### 게임 메커닉
1. **벽 파괴**: 벽을 터치/클릭하여 공격
2. **경험치 획득**: 벽 파괴 시 경험치 획득
3. **레벨업**: 경험치가 충족되면 자동 레벨업, 공격력 증가
4. **무기 업그레이드**: 5레벨마다 자동으로 다음 단계 무기로 업그레이드
5. **마나 획득**: 벽 파괴 시 랜덤으로 마나 획득

## 프로젝트 구조

```
through-the-sky-game/
├── project.godot          # Godot 프로젝트 설정 파일
├── scenes/               # 게임 씬 파일들
│   └── Main.tscn         # 메인 게임 씬
├── scripts/              # GDScript 파일들
│   ├── GameManager.gd    # 게임 로직 관리
│   └── UI.gd            # UI 관리
├── assets/              # 게임 에셋
│   ├── textures/        # 이미지 파일
│   ├── sounds/          # 사운드 파일
│   └── fonts/           # 폰트 파일
├── data/                # 게임 데이터
└── icon.svg             # 게임 아이콘
```

## 개발 로드맵

### 완료된 기능 (알파 버전)
- [x] 기본 게임 메커닉 구현
- [x] 7개 벽 타입 구현
- [x] 5개 기본 무기 세트
- [x] 레벨링 시스템

### 다음 단계 (베타 버전)
- [ ] 스킬 트리 시스템 구현
  - [ ] 일격 확률 업그레이드
  - [ ] 아이템 발견 확률 업그레이드
  - [ ] 공격력 부스터
  - [ ] 크리티컬 확률 시스템
- [ ] 유물 시스템 구현 (20종류)
- [ ] 사운드 효과 추가
- [ ] 파티클 효과 개선
- [ ] 세이브/로드 시스템

### 정식 출시 준비
- [ ] 모바일 최적화
- [ ] 터치 컨트롤 개선
- [ ] 성능 최적화
- [ ] 밸런싱 조정
- [ ] 안드로이드/iOS 빌드 설정

## 기술적 세부사항

### 사용된 Godot 기능
- Control 노드 기반 UI 시스템
- Tween을 이용한 애니메이션 효과
- Signal 시스템을 통한 이벤트 처리
- 모바일 터치 입력 지원

### 게임 밸런싱
- 초기 공격력: 1
- 레벨당 공격력 증가: 1
- 경험치 배율: 1.2배씩 증가
- 무기 업그레이드: 5레벨마다

## 참고사항
- PRD.md에서 Unity가 권장되었지만, Godot으로 개발하여 더 가벼운 개발 환경 제공
- 모든 텍스트는 한국어로 구현
- 모바일 우선 설계 (세로 화면 1080x1920)