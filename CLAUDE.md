# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 프로젝트 개요

ParkingFeeCalculatorLight는 Swift와 SwiftUI를 사용하여 개발된 iOS 앱으로, 주차 요금을 계산하는 간단한 계산기 앱입니다.

## 개발 환경 설정

- Xcode 26.0.1 이상 필요
- **iOS 18.6+ 타겟** — 프로젝트 레벨 설정값은 26.0이지만 **앱 타깃이 18.6으로 덮어쓴다.**
  최신 API를 쓰기 전에 18.6에서 가용한지 반드시 확인할 것.
- `SWIFT_VERSION = 5.0`
- SwiftUI 프레임워크 사용 · 외부 의존성 없음

## 빌드 및 실행 명령어

### Xcode를 통한 빌드
```bash
# Xcode에서 프로젝트 열기
open ParkingFeeCalculatorLight.xcodeproj

# 커맨드라인에서 빌드 (선택사항)
xcodebuild -project ParkingFeeCalculatorLight.xcodeproj -scheme ParkingFeeCalculatorLight -configuration Debug build
```

### 테스트 실행
현재 프로젝트에는 별도의 테스트 타겟이 구성되어 있지 않습니다.

## 프로젝트 구조

```
ParkingFeeCalculatorLight/
├── ParkingFeeCalculatorLight.xcodeproj/    # Xcode 프로젝트 파일
└── ParkingFeeCalculatorLight/              # 소스 코드 (Swift 12파일)
    ├── ParkingFeeCalculatorLightApp.swift  # 앱 진입점 (@main) → ContentView
    ├── Core/
    │   ├── Models.swift                    # 요금 규칙 · 주차장/운전자/차량 프로필 · 할인
    │   └── DataManager.swift               # UserDefaults 직렬화 저장소
    ├── View/
    │   ├── ContentView.swift               # 루트 TabView (주차장 / 설정) · 컬러스킴 적용
    │   ├── ParkingLotListView.swift        # 주차장 목록
    │   ├── ParkingLotEditView.swift        # 주차장 등록·편집
    │   ├── ParkingLotInfoView.swift        # 주차장 상세
    │   ├── TimerCellView.swift             # 주차 타이머 · 실시간 요금
    │   ├── SettingView.swift               # 설정
    │   └── UserProfileView.swift           # 운전자·차량 프로필(할인 자격)
    ├── ViewModel/
    │   ├── SettingViewModel.swift
    │   └── UserProfileViewModel.swift
    └── Assets.xcassets/                    # 앱 아이콘, 색상 등 리소스
```

## 코드 아키텍처

- **SwiftUI 기반**: 선언적 UI 프레임워크 사용
- **경량 MVVM**: `Core`(모델·저장) / `View` / `ViewModel` 3계층.
  ViewModel은 상태를 다루는 화면(설정·프로필)에만 두고, 단순 조회 화면은 View에서 직접 모델을 읽는다.
  **화면마다 ViewModel을 강제하지 않는다.**
- **앱 진입점**: `ParkingFeeCalculatorLightApp.swift`(@main) → `ContentView`가 루트 `TabView`(주차장 / 설정)
- **저장**: `DataManager`가 UserDefaults에 JSON으로 직렬화. 외부 의존성·서버 없음.
- **원본과의 관계**: [ParkingFeeCalculator](https://github.com/JuseongMoon/ParkingFeeCalculator)에서
  위젯·Live Activity·App Groups를 걷어낸 단일 타깃 버전. 요금 계산 로직만 빠르게 손볼 때 쓴다.

## 개발 가이드라인

### Swift 코딩 스타일
- Swift 표준 네이밍 컨벤션 준수
- SwiftUI 뷰는 struct로 구현
- 프리뷰(#Preview) 활용하여 UI 개발

### 번들 식별자
- `com.ScienceFiction.ParkingFeeCalculatorLight`

### 배포 타겟
- iPhone 및 iPad 지원 (TARGETED_DEVICE_FAMILY = "1,2")
- **iOS 18.6 이상** (앱 타깃 실제 값)

---

## 공개 저장소 규칙

이 저장소는 공개되어 있다. 커밋한 것은 되돌려도 남는다.

- **시크릿 금지** — API 키·토큰·서명 키(`*.jks`/`*.p12`)·서비스 계정 키·실제 사용자 데이터를 커밋하지 않는다.
  값은 **`Secrets.xcconfig`** 에만 두고 저장소에는 `*.example`만 올린다.
  소스·plist·manifest·주석·커밋 메시지 어디에도 값을 쓰지 않는다.
  이미 올렸다면 되돌리는 것으로 끝내지 말고 **키를 폐기·재발급**한다.
- **내부 정보 금지** — 로컬 절대경로(`/Users/…`), 저장소 밖 파일 참조, 관리자 URL,
  인프라 식별자(버킷·배포 ID·계정 번호), 개인 기기 식별자(UDID·시리얼),
  릴리스 진행 상태와 스토어 콘솔 절차는 문서에 남기지 않는다.
- **내부 문서 위치** — 가격 전략·미출시 기획·운영 절차·서버 계약은 저장소에 두지 않는다.
  로컬에 두고 gitignore 하되 **그 판단 근거를 이 문서에 적어** 다음 세션이 되돌리지 않게 한다.
  gitignore된 경로를 코드 주석이나 문서에서 참조하지 않는다 — 방문자에게는 끊어진 링크다.
- **문서 정확성** — 여기 적힌 버전·경로·명령·구조가 코드와 다르면 코드가 아니라 문서를 고친다.
  배포 타깃과 언어 버전은 프로젝트 기본값이 아니라 **앱 타깃의 실제 값**을 확인해 적는다.
- **브랜치** — 에이전트 작업 브랜치는 머지 후 지운다. 원격에 실험 브랜치를 남기지 않는다.
  **처음 push 하는 순간 그 브랜치의 문서·메모도 함께 공개된다.**
- **`main`에 force-push 하지 않는다.** 공개된 히스토리를 다시 쓰면 클론·포크한 쪽이 깨진다.
  (예외: 시크릿 제거 — 이때도 키 폐기가 먼저다.)
- **push 전 확인** — `git fetch origin && git status -sb`로 원격이 앞섰는지 보고, 앞섰으면 덮지 말고 rebase 한다.
  `git log origin/main..HEAD --stat`으로 올라갈 파일 전체를 확인해 무관한 파일을 분리하고,
  `git diff`에서 키·절대경로·기기 식별자가 없는지 본다. **`git add .` 금지.**