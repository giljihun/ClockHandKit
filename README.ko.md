<p align="center">
  <img src="Documentation/clockhandkit-logo.png" alt="ClockHandKit" width="260">
</p>

<h1 align="center">ClockHandKit</h1>

<p align="center">
  <em>iOS 홈 화면 위젯을 위한 시간 기반 연속 애니메이션.</em>
</p>

<p align="center">
  <a href="https://github.com/giljihun/ClockHandKit/stargazers"><img src="https://img.shields.io/github/stars/giljihun/ClockHandKit?style=flat-square&amp;color=111111&amp;label=stars" alt="GitHub stars"></a>
  <a href="https://github.com/giljihun/ClockHandKit/releases/latest"><img src="https://img.shields.io/github/v/release/giljihun/ClockHandKit?style=flat-square&amp;color=111111&amp;label=release" alt="Latest release"></a>
  <a href="Package.swift"><img src="https://img.shields.io/badge/Swift-6.2-111111?style=flat-square&amp;logo=swift&amp;logoColor=white" alt="Swift 6.2"></a>
  <a href="Package.swift"><img src="https://img.shields.io/badge/iOS-16%2B-111111?style=flat-square&amp;logo=apple&amp;logoColor=white" alt="iOS 16 이상"></a>
  <a href="Package.swift"><img src="https://img.shields.io/badge/Xcode-26.1%2B-111111?style=flat-square&amp;logo=xcode&amp;logoColor=white" alt="Xcode 26.1 이상"></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/giljihun/ClockHandKit?style=flat-square&amp;color=111111&amp;label=license" alt="MIT License"></a>
</p>

<p align="center">
  <sub><a href="README.md">English</a> · <strong>한국어</strong></sub>
</p>

---

iOS 26.1 이후에도 위젯의 시계바늘이 계속 돌아가게 해줍니다.

<p align="center">
  <img src="Documentation/clockhandkit-demo.gif" alt="실기기에서 ClockHandKit과 ClockHandRotationKit을 나란히 실행한 모습" width="560">
</p>

<p align="center">
  <sub><strong>왼쪽</strong>: ClockHandKit · <strong>오른쪽</strong>: 기존 ClockHandRotationKit을 iOS 26.1 이후에 썼을 때<br>아이폰에서 실제 시간 그대로 녹화</sub>
</p>

## 설치

Swift Package Manager로 추가합니다.

```swift
.package(url: "https://github.com/giljihun/ClockHandKit.git", from: "0.1.2")
```

Xcode에서는 **File › Add Package Dependencies…** 를 열고 위 주소를 넣으면 됩니다.
`ClockHandKit`은 **위젯 익스텐션** 타깃에 추가하세요.

## 사용법

### 시계바늘

```swift
import SwiftUI
import ClockHandKit

ZStack {
    hourHand.clockHandRotationEffect(period: .hourHand)
    minuteHand.clockHandRotationEffect(period: .minuteHand)
    secondHand.clockHandRotationEffect(period: .secondHand)
}
```

시간대는 `in`, 회전 중심은 `anchor`로 정합니다.

```swift
secondHand.clockHandRotationEffect(period: .secondHand, in: .gmt, anchor: .bottom)
```

### 프레임 애니메이션

이 효과는 새 타임라인을 기다리지 않고 현재 시각에 맞춰 뷰를 돌립니다.
원판 둘레에 프레임을 놓고, 고정된 창으로 한 칸씩만 보이게 하면 원판이 돌면서 프레임이 차례로 재생됩니다.

<img src="Documentation/clockhand-frame-animation.gif" alt="회전 원판으로 만드는 프레임 애니메이션" width="600">

```swift
// 앱에서 만든 8칸짜리 프레임 원판
frameWheel
    .clockHandRotationEffect(period: .custom(8))
```

`period`는 프레임 한 장의 시간이 아니라 원판이 한 바퀴(360°) 도는 시간입니다.

```text
period = 전체 프레임 칸 수 / 목표 FPS
```

120프레임을 원판에 한 번 배치할 때:

| 목표 재생 속도 | `period` |
| ---: | ---: |
| 12 FPS | 10초 |
| 24 FPS | 5초 |
| 30 FPS | 4초 |
| 60 FPS | 2초 |

목표치일 뿐이고, 실제로 얼마나 자주 그릴지는 WidgetKit과 기기가 정합니다.

### 예제

`Examples/ClockHandExample`에 시계 위젯이 들어 있는 예제 앱이 있습니다.

## ClockHandRotationKit에서 옮겨오기

import만 바꾸면 됩니다.

```diff
-import ClockHandRotationKit
+import ClockHandKit
```

`.clockHandRotationEffect(period: 60)` 같은 기존 호출은 그대로 동작합니다.
새로 쓰는 코드라면 `.clockHandRotationEffect(period: .secondHand)`처럼 쓰는 편이 읽기 쉽습니다.

ClockHandKit은 iOS 16 이상이 필요합니다. 두 모듈을 한 타깃에 같이 import하면 extension 메서드가 충돌할 수 있으니 하나만 쓰세요.

## 왜 ClockHandKit인가

iOS 26.1부터 WidgetKit이 Xcode 26.1 이상으로 빌드한 서드파티 앱에는 회전을 적용하지 않게 바뀌었습니다. ClockHandRotationKit을 쓴 앱은 빌드는 되지만 바늘이 멈춰 있게 됩니다.

ClockHandKit은 같은 효과를 다른 경로로 적용하고, 이후 WidgetKit 변경에도 계속 맞춰갑니다. 자세한 내용과 검증 결과는 [릴리스 노트](https://github.com/giljihun/ClockHandKit/releases)에 있습니다.

## 감사의 말 ❤️

ClockHandKit은 제가 공동 작업자로 참여했던 [octree/ClockHandRotationKit](https://github.com/octree/ClockHandRotationKit)에서 출발했습니다.

최초 구현과 API를 공개해 주신 **octree님께 진심으로 감사드립니다.** ❤️

## 라이선스

ClockHandKit은 [MIT License](LICENSE)로 제공됩니다.
