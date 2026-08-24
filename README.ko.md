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

> [!CAUTION]
> ClockHandKit은 WidgetKit의 비공개 API를 사용합니다.
> 이 API는 예고 없이 바뀔 수 있습니다.
> 이를 사용하는 앱은 App Review를 통과하지 못할 수 있습니다.

Apple은 같은 효과를 시스템 시계 위젯에서 사용합니다.
하지만 이 효과를 공개 API로 제공하지 않습니다.

**ClockHandKit**은 WidgetKit의 비공개 modifier인
`_ClockHandRotationEffect`를 직접 사용합니다.

## 원리

일반적인 WidgetKit 위젯은 시스템이 정한 시점마다 **정적인 타임라인 스냅샷**을 갱신합니다.

[공개 API로 제공되는 위젯 애니메이션][widget-animations]은 위젯 데이터가 바뀔 때 실행됩니다.
이 애니메이션은 최대 2초 동안 동작하는 짧은 전환 효과입니다.

일반적인 타임라인 방식만으로는 프레임이 계속 이어지는 연속 애니메이션을 만들 수 없습니다.

`ClockHandRotationEffect`는 다르게 동작합니다.
새 타임라인 스냅샷을 기다리지 않습니다.
WidgetKit 내부에서 현재 시간에 맞춰 View를 회전시킵니다.

여러 애니메이션 프레임을 원형 원판에 배치합니다.
한 프레임만 보이도록 창을 고정합니다.
원판이 회전하면 프레임이 차례로 나타나 애니메이션처럼 보입니다.

<img src="Documentation/clockhand-frame-animation.gif" alt="회전 원판으로 만드는 프레임 애니메이션" width="600">

**ClockHandKit은 이 회전 효과를 서드파티 위젯에 적용합니다.**
프레임 원판과 고정된 창은 앱에서 구성합니다.

## 사용법과 예제

위 GIF는 8개 슬롯을 사용합니다.
프레임 `1`부터 `4`까지를 두 번 배치했습니다.

다음 코드는 앱에서 만든 프레임 원판을 8초마다 한 바퀴 회전시킵니다.

```swift
import SwiftUI
import ClockHandKit

// 앱에서 만든 8개 프레임 슬롯의 원판
frameWheel
    .clockHandRotationEffect(period: .custom(8))
```

8개 슬롯은 8초 동안 한 바퀴 회전합니다.
1초마다 다음 슬롯이 나타납니다.
4프레임 애니메이션은 4초마다 반복됩니다.

`period`는 프레임 한 장의 시간이 아닙니다.
**원판이 360° 회전하는 데 걸리는 시간**입니다.

```text
period = 전체 프레임 슬롯 수 / 목표 FPS
```

120프레임을 원판에 한 번 배치한다면 다음 값을 사용할 수 있습니다.

| 목표 재생 속도 | `period` |
| ---: | ---: |
| 12 FPS | 10초 |
| 24 FPS | 5초 |
| 30 FPS | 4초 |
| 60 FPS | 2초 |

실제 시계 바늘에는 `.hourHand`, `.minuteHand`, `.secondHand`를 사용합니다.
프레임 애니메이션에는 `.custom(seconds)`를 사용합니다.

타임존은 `in`으로 지정합니다.
회전 기준점은 `anchor`로 지정합니다.

표의 값은 목표 재생 속도입니다.
실제 렌더링 주기는 WidgetKit과 기기가 결정합니다.

<!-- 추후 별도 예제 저장소와 실제 기기 재생 샘플 링크를 추가합니다. -->

## ClockHandKit을 만든 이유

[ClockHandRotationKit][clockhand-rotation-kit]을 사용하는 앱은 Xcode 26.0.1로 빌드했을 때 정상적으로 동작했습니다.
이 빌드는 검증한 iOS 26.1 이상 환경에서도 동작했습니다.

문제는 다음 두 조건을 모두 충족할 때만 발생했습니다.

- 서드파티 앱을 **Xcode 26.1 이상**으로 빌드
- **iOS 26.1 이상**에서 실행

앱의 **컴파일과 링크는 정상적으로 완료**됐습니다.
하지만 실행 시 **회전 효과가 적용되지 않았습니다**.

원인을 추적한 결과 WidgetKit이 런타임 제한을 추가한 사실을 확인했습니다.
이 제한은 링크 SDK와 앱의 번들 식별자를 확인합니다.
조건에 걸린 서드파티 앱에는 modifier를 적용하지 않고 원본 View를 반환합니다.

이는 Swift 버전이나 JSON payload 형식의 변화가 아닙니다.
**WidgetKit의 런타임 제한**입니다.

ClockHandKit은 제한된 진입점을 사용하지 않습니다.
내부 modifier를 직접 구성해 적용합니다.

### 검증

- **ClockHandKit 패키지 빌드**
  - Xcode 26.1, 26.4, 26.5
- **예제 앱과 두 Widget Extension**
  - Xcode 26.5
- **런타임 modifier 브리지**
  - iOS 26.1, iOS 26.5 Simulator
- **기존 진입점 교차 검증**
  - `SDK 26.0 → iOS 26.1`: 동작
  - `SDK 26.1 → iOS 26.0`: 동작
  - `SDK 26.1 → iOS 26.1`, 서드파티 앱: 실패
- **ClockHandRotationKit 컴파일·링크 매트릭스**
  - 릴리스: 1.0.0, 1.0.1, 1.1.0
  - Xcode: 26.0.1, 26.1.1, 26.5
  - 타깃: iOS arm64, Simulator arm64, Simulator x86_64
  - 구성: Debug, Release
  - 결과: **54개 조합 모두 컴파일 및 링크 성공**

54개 조합은 모두 정상적으로 빌드됐습니다.
따라서 문제는 컴파일이나 링크가 아닌 런타임 동작에 있습니다.

관련 자료:

- [최초 iOS 26.1 호환성 리포트][compatibility-report]
- [WidgetKit 바이너리 diff][widgetkit-binary-diff]

## ClockHandRotationKit에서 이전하기

import를 다음과 같이 바꿉니다.

```diff
-import ClockHandRotationKit
+import ClockHandKit
```

소스 호환 이전을 위해 `TimeInterval` 오버로드를 제공합니다.

```swift
.clockHandRotationEffect(period: 60)
```

새 코드에는 타입 기반 API를 권장합니다.

```swift
.clockHandRotationEffect(period: .secondHand)
```

ClockHandRotationKit은 iOS 14 이상을 선언합니다.
ClockHandKit은 iOS 16 이상이 필요합니다.

두 모듈의 extension method가 충돌할 수 있습니다.
같은 타깃에 두 모듈을 함께 import하지 마세요.

## 감사의 말 ❤️

ClockHandKit은 제가 공동 작업자로 참여했던
[octree/ClockHandRotationKit][clockhand-rotation-kit]에서 영감을 받았습니다.

최초 구현과 API를 공개해 주신 **octree님께 진심으로 감사드립니다.**
ClockHandKit은 이 작업에서 출발했습니다. ❤️

## 라이선스

ClockHandKit은 [MIT License](LICENSE)로 제공됩니다.

[widget-animations]: https://developer.apple.com/documentation/widgetkit/animating-data-updates-in-widgets-and-live-activities
[clockhand-rotation-kit]: https://github.com/octree/ClockHandRotationKit
[compatibility-report]: https://github.com/octree/ClockHandRotationKit/issues/11
[widgetkit-binary-diff]: https://github.com/blacktop/ipsw-diffs/blob/809573f26c4185c71fc786fb9adadab06c50ad0f/26_1_23B5044l__vs_26_1_23B5059e/DYLIBS/WidgetKit.md#L280-L304
