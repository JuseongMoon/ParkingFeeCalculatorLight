# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 프로젝트 개요

ParkingFeeCalculatorLight는 Swift와 SwiftUI를 사용하여 개발된 iOS 앱으로, 주차 요금을 계산하는 간단한 계산기 앱입니다.

## 개발 환경 설정

- Xcode 26.0.1 이상 필요
- iOS 26.0+ 타겟
- Swift 5.0
- SwiftUI 프레임워크 사용

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
└── ParkingFeeCalculatorLight/              # 소스 코드
    ├── ParkingFeeCalculatorLightApp.swift  # 앱 진입점 (@main)
    ├── ContentView.swift                   # 메인 UI 뷰
    └── Assets.xcassets/                    # 앱 아이콘, 색상 등 리소스
```

## 코드 아키텍처

- **SwiftUI 기반**: 선언적 UI 프레임워크 사용
- **단일 뷰 구조**: 현재는 ContentView 하나만 존재하는 심플한 구조
- **앱 진입점**: ParkingFeeCalculatorLightApp.swift에서 @main으로 앱 시작

## 개발 가이드라인

### Swift 코딩 스타일
- Swift 표준 네이밍 컨벤션 준수
- SwiftUI 뷰는 struct로 구현
- 프리뷰(#Preview) 활용하여 UI 개발

### 번들 식별자
- `com.ScienceFiction.ParkingFeeCalculatorLight`

### 배포 타겟
- iPhone 및 iPad 지원 (TARGETED_DEVICE_FAMILY = "1,2")
- iOS 26.0 이상