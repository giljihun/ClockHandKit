[English](README.md) · **한국어**

# ClockHandKit

ClockHandKit은 iOS 홈 화면 위젯에
**실시간 시계 바늘 애니메이션**을 구현하도록 도와주는 Swift 패키지입니다.

Apple은 같은 효과를 시스템 시계 위젯에서 사용하지만, 서드파티 개발자에게는
공개 API로 제공하지 않습니다. ClockHandKit은 WidgetKit의 비공개
`_ClockHandRotationEffect` modifier를 직접 사용합니다.

> [!CAUTION]
> ClockHandKit은 WidgetKit의 비공개 API를 사용합니다.
> 이 API는 예고 없이 바뀔 수 있으며,
> 이를 사용하는 앱은 App Review를 통과하지 못할 수 있습니다.

## 회전으로 만드는 프레임 애니메이션

여러 애니메이션 프레임을 원형 원판에 배치합니다. ClockHandKit이 원판을
회전시키면 고정된 창을 통해 프레임이 차례로 보입니다.

![고정된 창을 통과하며 프레임 원판을 회전시키는 ClockHandRotationEffect](Documentation/clockhand-frame-animation.gif)

ClockHandKit은 회전만 담당합니다. 프레임 원판과 고정된 창은 앱에서
구성합니다.

## 사용법

```swift
import SwiftUI
import ClockHandKit

Image(systemName: "arrow.up")
    .clockHandRotationEffect(period: .secondHand)
```

지원하는 회전 주기는 다음과 같습니다.

| 값 | 회전 주기 |
| --- | ---: |
| `.hourHand` | 43,200초 |
| `.minuteHand` | 3,600초 |
| `.secondHand` | 60초 |
| `.custom(seconds)` | 전달한 초 단위 값 |

타임존과 회전 기준점도 지정할 수 있습니다.

```swift
hand.clockHandRotationEffect(
    period: .minuteHand,
    in: TimeZone(identifier: "Asia/Seoul")!,
    anchor: .bottom
)
```

## 예제

### 재생 속도

**`period`는 프레임 한 장의 시간이 아니라 원판이 360° 회전하는 시간**입니다.

```text
period = 전체 프레임 슬롯 수 / 목표 FPS
```

위 GIF는 프레임 `1`부터 `4`까지를 두 번 반복한 8개 슬롯을 사용합니다. 회전
주기를 8초로 설정하면 1초마다 다음 슬롯이 나타나고, 4프레임 애니메이션은
4초마다 반복됩니다.

```swift
.clockHandRotationEffect(period: .custom(8))
```

120프레임을 원판에 한 번 배치했을 때의 값은 다음과 같습니다.

| 목표 재생 속도 | 프레임 간격 | `period` |
| ---: | ---: | ---: |
| 12 FPS | 83.33 ms | 10초 |
| 24 FPS | 41.67 ms | 5초 |
| 30 FPS | 33.33 ms | 4초 |
| 60 FPS | 16.67 ms | 2초 |

같은 120프레임을 원판에 두 번 배치한다면 `period`도 두 배로 설정합니다. 표의
값은 목표 재생 속도이며 실제 렌더링 주기는 WidgetKit이 결정합니다.

<!-- 추후 별도 예제 저장소와 실제 기기 재생 샘플 링크를 추가합니다. -->

## ClockHandKit을 만든 이유

[ClockHandRotationKit](https://github.com/octree/ClockHandRotationKit)은
WidgetKit의 비공개 시계 바늘 효과를 서드파티 위젯에서 사용할 수 있게 만든
패키지입니다.

iOS 26.1부터 기존 진입점의 동작은 링크 SDK와 실행 OS의 조합에 따라 달라집니다.

| 링크 SDK | 실행 OS | 결과 |
| --- | --- | --- |
| iOS 26.0 SDK | iOS 26.1 | 회전 효과 적용 |
| iOS 26.1 SDK | iOS 26.0.x | 회전 효과 적용 |
| iOS 26.1 SDK | iOS 26.1 | 회전하지 않음 |

**마지막 조합에서만 문제가 발생합니다.**

코드는 정상적으로 빌드되지만,
WidgetKit은 회전 modifier가 없는 원본 View를 반환합니다.

이는 **WidgetKit 런타임 제한**입니다.
Swift 버전이나 JSON 형식 변경이 원인이 아닙니다.

ClockHandKit은 제한된 진입점을 호출하지 않고 내부 modifier를 직접 구성해
적용합니다.

관련 자료:

- [최초 iOS 26.1 호환성 리포트](https://github.com/octree/ClockHandRotationKit/issues/11)
- [WidgetKit 바이너리 diff](https://github.com/blacktop/ipsw-diffs/blob/809573f26c4185c71fc786fb9adadab06c50ad0f/26_1_23B5044l__vs_26_1_23B5059e/DYLIBS/WidgetKit.md#L280-L304)

## 동작 방식

1. `WidgetKit._ClockHandRotationEffect` 타입을 런타임에 찾습니다.
2. 확인된 Codable 구조를 사용해 modifier를 생성합니다.
3. 생성한 값을 SwiftUI `ViewModifier`로 적용합니다.

중간 단계가 실패하면 원본 View를 그대로 반환합니다.
실패 내용은 `OSLog`에 기록합니다.

## 요구 사항

- iOS 16 이상
- Swift tools 6.2
- Xcode 26.1 이상
- SwiftUI 및 WidgetKit

## 테스트 환경

### ClockHandKit

| 범위 | 테스트 환경 |
| --- | --- |
| 패키지 빌드 | Xcode 26.1, 26.4, 26.5 |
| 예제 앱 및 두 Widget Extension | Xcode 26.5 |
| 런타임 modifier 브리지 | iOS 26.1 및 iOS 26.5 Simulator |

### ClockHandRotationKit 호환성 매트릭스

원인 분석 과정에서는 ClockHandRotationKit만 의존하는 최소 구성의 consumer를
다음 조합으로 컴파일하고 링크했습니다.

이는 바이너리 컴파일·링크 테스트이며, 위젯의 end-to-end 런타임 테스트는
아닙니다.

| 구분 | 테스트 값 |
| --- | --- |
| 릴리스 | 1.0.0, 1.0.1, 1.1.0 |
| Xcode | 26.0.1 (17A400), 26.1.1 (17B100), 26.5 (17F42) |
| 빌드 타깃 | iOS arm64, Simulator arm64, Simulator x86_64 |
| 구성 | Debug, Release |

`3개 릴리스 × 3개 Xcode 버전 × 3개 타깃 × 2개 구성 = 54개`

**54개 consumer 빌드 조합 모두에서 컴파일과 링크에 성공했습니다.**

이를 통해 원인이 컴파일 또는 링크 실패가 아닌 런타임 동작임을 확인했습니다.

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

새 코드에는 typed API를 권장합니다.

```swift
.clockHandRotationEffect(period: .secondHand)
```

ClockHandRotationKit은 iOS 14 이상을 선언하지만,
ClockHandKit은 iOS 16 이상이 필요합니다.

두 모듈의 extension method가 충돌할 수 있습니다.
같은 타깃에 두 모듈을 함께 import하지 마세요.

## 한계와 진단

- **비공개 API 안정성:** WidgetKit의 타입 이름과 Codable 구조는 변경될 수
  있습니다.
- **Fail-open 동작:** 런타임 브리지가 실패하면 위젯은 표시되지만 회전 효과는
  적용되지 않습니다.

런타임 실패는 subsystem `com.clockhandkit`, category `runtime-bridge`로
기록됩니다.

```shell
log stream --predicate 'subsystem == "com.clockhandkit"'
```

## 기여하기

Issue 또는 Pull Request를 열기 전에
[한국어 기여 가이드](CONTRIBUTING.ko.md)를 읽어 주세요.

## 감사의 말

ClockHandKit은 최초 구현과 API 형태를 제시한
[octree/ClockHandRotationKit](https://github.com/octree/ClockHandRotationKit)에서
영감을 받았습니다.

## 라이선스

ClockHandKit은 [MIT License](LICENSE)로 제공됩니다.
