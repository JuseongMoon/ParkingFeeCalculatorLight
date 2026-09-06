# ParkingFeeCalculatorLight

[ParkingFeeCalculator](https://github.com/JuseongMoon/ParkingFeeCalculator)에서
위젯과 Live Activity를 걷어내고 **요금 계산과 주차장 관리만 남긴** 경량 버전입니다.

- 플랫폼: iOS 18.6+ (SwiftUI)
- 외부 의존성 없음

## 왜 따로 만들었나

원본은 WidgetKit 확장, App Groups, ActivityKit이 얽혀 있어
실제 기기가 있어야 제대로 동작합니다. 요금 계산 로직만 빠르게 손보거나
UI를 실험할 때는 그 구성이 부담이었습니다.

Light 버전은 **단일 타겟**이라 시뮬레이터에서 바로 돌아가고,
계산 로직 변경의 영향 범위가 좁습니다.

## 구조

```
ParkingFeeCalculatorLight/
├── Core/        DataManager · Models (요금 규칙, 주차장 프로필)
├── View/        주차장 목록·등록·편집, 타이머 셀, 설정
└── ViewModel/   설정 · 사용자 프로필
```

MVVM으로 구성했고, 데이터는 `DataManager`가 UserDefaults에 직렬화해 보관합니다.

## 실행 방법

```bash
git clone https://github.com/JuseongMoon/ParkingFeeCalculatorLight.git
cd ParkingFeeCalculatorLight
open ParkingFeeCalculatorLight.xcodeproj
```

## 라이선스

MIT License. 자세한 내용은 [LICENSE](LICENSE)를 참고하세요.
