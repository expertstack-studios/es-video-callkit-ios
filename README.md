# VideoCallKit

VideoCallKit is an iOS SDK from Expertstack for adding secure, interpreter-assisted video calls to an app. It handles authentication, device registration, VoIP push, CallKit, permissions, and the in-call UI. Your app only needs to initialise the SDK and place a call button.

The SDK ships as a prebuilt XCFramework. Its video engine (Vonage / OpenTok) is linked into the binary, so you don't need to add any other packages.

## Requirements

| Item | Minimum |
| --- | --- |
| iOS | 17.6 |
| Swift tools | 6.1 |
| Xcode | 27 or later |

## Installation

### Swift Package Manager

In Xcode, choose **File > Add Package Dependencies…** and enter:

```
https://github.com/expertstack-studios/es-video-callkit-ios
```

Or add it to `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/expertstack-studios/es-video-callkit-ios", from: "1.0.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "VideoCallKit", package: "es-video-callkit-ios")
        ]
    )
]
```

Stable releases use plain semantic versions (`1.2.3`). Release candidates are published as prereleases (`1.2.3-rc.N`). SwiftPM only resolves an RC if you ask for it explicitly.

## Project setup

### 1. Configuration file

Expertstack provides an encrypted `Config.dat` for each app and environment. Add it to your app target and make sure it's included in **Copy Bundle Resources**.

- The file must be named exactly `Config.dat`.
- It's encrypted against your app's bundle identifier, so it only works in the app it was issued for.

You'll also receive a **client secret**, which you pass to `VideoCall.initialize`.

### 2. Capabilities

Under **Signing & Capabilities**, enable:

- **Push Notifications**
- **Background Modes**: *Voice over IP*, *Audio, AirPlay, and Picture in Picture*, and *Remote notifications*

### 3. Info.plist privacy strings

Add these keys:

| Key | Purpose |
| --- | --- |
| `NSCameraUsageDescription` | Video during calls |
| `NSMicrophoneUsageDescription` | Audio during calls |
| `NSLocationWhenInUseUsageDescription` | Shares the caller's location with the operator, if enabled in your configuration |
| `NSLocationAlwaysAndWhenInUseUsageDescription` | As above |

## Usage

### Initialise the SDK

Call `VideoCall.initialize` once at launch, before using any other API. `AppDelegate` is the usual place. Register for VoIP pushes at the same point.

```swift
import PushKit
import UIKit
import VideoCallKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    private let voipRegistry = PKPushRegistry(queue: .main)

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [.voIP]

        do {
            try VideoCall.initialize("<CLIENT_SECRET>")
        } catch {
            // Thrown when the client secret is empty.
            print("VideoCallKit failed to initialise: \(error)")
        }
        return true
    }
}
```

For a SwiftUI app, attach the delegate with `@UIApplicationDelegateAdaptor(AppDelegate.self)`.

> Keep the client secret out of source control. Inject it at build time, for example from an `.xcconfig` into Info.plist, and read it with `Bundle.main.object(forInfoDictionaryKey:)`.

### Identify the user

If your backend has its own user or member ID, pass it to the SDK so calls are linked to that user:

```swift
VideoCall.setUserId(memberId)
```

`setUserId` only stores an ID if none is set yet. Pass `forceUpdate: true` to replace an existing one, and call `VideoCall.clearUserId()` on sign-out.

To register a new user on your backend first, get the SDK's stable device ID:

```swift
let deviceId = await VideoCall.getDeviceIdAsync()
```

### VoIP push

Forward the PushKit token and incoming pushes to the SDK:

```swift
extension AppDelegate: PKPushRegistryDelegate {
    func pushRegistry(
        _ registry: PKPushRegistry,
        didUpdate pushCredentials: PKPushCredentials,
        for type: PKPushType
    ) {
        guard type == .voIP else { return }
        Task {
            // Use `true` for production APNs builds (App Store / TestFlight)
            // and `false` for development builds.
            await VideoCall.registerVoipTokenAsync(token: pushCredentials.token, isProduction: false)
        }
    }

    func pushRegistry(
        _ registry: PKPushRegistry,
        didReceiveIncomingPushWith payload: PKPushPayload,
        for type: PKPushType,
        completion: @escaping () -> Void
    ) {
        if type == .voIP {
            VideoCall.reportNewInComingCall(payload: payload)
        }
        completion()
    }
}
```

### Request permissions

Ask for camera, microphone, and location access at a moment that suits your onboarding, such as after the user accepts your terms:

```swift
await VideoCall.requestPermissionsAsync()
```

You can also ask for each permission separately with `requestCameraPermissionAsync()`, `requestMicrophonePermissionAsync()`, and `requestLocationPermissionAsync()`.

If a permission is later missing, the SDK shows its own permission sheet when the app returns to the foreground.

### Add a call button

The SDK starts a call when the user presses and holds the button for a set time. That time comes from your configuration, and you can read it with `VideoCall.callInitiationTime`, in seconds. When the hold completes, the SDK presents the full-screen call UI.

#### Default button (SwiftUI)

```swift
import SwiftUI
import VideoCallKit

struct HomeView: View {
    @AppStorage("buttonPressFeedback") private var feedback: FeedbackType = .haptic

    var body: some View {
        VStack(spacing: 24) {
            if VideoCall.callInitiationTime > 0 {
                Text("Press and hold for \(Int(VideoCall.callInitiationTime)) seconds to connect to an interpreter.")
                    .multilineTextAlignment(.center)
            }

            VideoCall.createCallButton(
                title: "Emergency Connect",
                buttonSize: 180,
                buttonColor: .red,
                titleFont: .footnote,
                feedbackType: $feedback,   // .haptic or .vibration
                callScreenFont: .body      // font used on the call screen
            )
        }
    }
}
```

There's also a circular variant:

```swift
VideoCall.createCircularCallButton(title: "Call", buttonSize: 120, buttonColor: .blue)
```

#### Custom SwiftUI content

Wrap any view to make it a call trigger, and chain the event handlers you need:

```swift
VideoCall.createCallButton {
    Text("Call")
        .font(.title3.bold())
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, minHeight: 50)
        .background(Capsule().fill(Color.blue))
}
.onCountdown { progress, isActive in /* update your UI during the hold */ }
.onCallStart { /* hold completed, call is starting */ }
.onCallCancel { /* released before the hold completed */ }
.onCallEnd { /* user ended the call */ }
```

`onButtonPressed` and `onButtonLongPressed` run before a call starts. Use them to collect extra details, such as an origin sharable code or questionnaire answers, then call `completion` to continue:

```swift
VideoCall.createCallButton {
    Text("Call")
}
.onButtonPressed { completion in
    // completion(originSharableCode, answers)
    completion(nil, nil)
}
```

To check an origin sharable code before passing it in:

```swift
let (isValid, details) = await VideoCall.validateOriginSharableCode(originSharableCode: code)
```

#### UIKit

Any `UIView` can become a call trigger:

```swift
let button = UIButton(type: .system)
button.setTitle("Start Call", for: .normal)

VideoCall.createCallButton(button)
    .onCountdown { secondsRemaining in }
    .onCallStart { }
    .onCallCancel { }
    .onCallEnd { }
    .apply()
```

### Test calls

Pass `callMode: .test` to any `createCallButton` variant to place a test call instead of a live one. This is useful for an "after install" connectivity check:

```swift
VideoCall.createCallButton(content: {
    Text("Make a test call")
}, callMode: .test)
```

## API summary

| API | Description |
| --- | --- |
| `VideoCall.initialize(_:settings:)` | Initialises the SDK with your client secret. Throws if the secret is empty. |
| `VideoCall.setUserId(_:forceUpdate:)` | Links calls to your app's user ID. |
| `VideoCall.clearUserId()` | Clears the stored user ID. |
| `VideoCall.getDeviceIdAsync()` | Returns the SDK's persistent device ID. |
| `VideoCall.registerVoipTokenAsync(token:isProduction:)` | Registers the PushKit VoIP token. |
| `VideoCall.reportNewInComingCall(payload:)` | Forwards an incoming VoIP push. |
| `VideoCall.requestPermissionsAsync()` | Requests camera, microphone, and location access. |
| `VideoCall.callInitiationTime` | How long the user must hold the button, in seconds. |
| `VideoCall.createCallButton(...)` | Default, custom SwiftUI, and UIKit call buttons. |
| `VideoCall.createCircularCallButton(...)` | Circular call button. |
| `VideoCall.validateOriginSharableCode(originSharableCode:)` | Checks an origin sharable code. |
| `CallMode` | `.standard` (live call) or `.test`. |
| `FeedbackType` | `.haptic` or `.vibration` feedback while holding the button. |

## Troubleshooting

- **Nothing happens when the call button is held.** Check that `Config.dat` is in the app bundle and that the app's bundle identifier matches the one the file was issued for.
- **No incoming calls.** Check the Push Notifications capability, the *Voice over IP* background mode, and that `isProduction` matches the APNs environment of the build.
- **Black video or no audio.** Check that the camera and microphone privacy strings are present and that the user granted access.

## Support

For a client secret, a `Config.dat`, or help with integration, contact Expertstack.

## Phase 2 interactions (BODI Mobile)

For an app that signs in to the BODI API itself (session cookie `__Host-bodi_sid`, no client secret). Phase 1 (`initialize(clientSecret)`, `createCallButton`) is unchanged for AEI and the current BODI app.

```swift
VideoCall.configure(VideoCallConfiguration(apiBaseURL: url, client: "bodi-ios", clientVersion: "1.0.0", deviceId: installId))
VideoCall.phase2Delegate = self                 // VideoCallDelegate: waiting, connecting, connected, onHold, ended, failed
VideoCall.setHoldView { MyHoldView() }          // shown over the call screen while on hold
try await VideoCall.startInteraction(InteractionStartRequest(siteId: siteId, answers: answers))
await VideoCall.leaveCall()                     // BODI-07 while waiting, BODI-09 once connected
```

- `Phase2/InteractionAPIClient.swift`: INT-01, BODI-06 to BODI-09 and RT-02 on `/v1/...`, with `X-Client`, `X-Client-Version`, `X-Request-Id` and `Idempotency-Key`; errors as `InteractionError` (the API's `code` and `message`).
- `Phase2/RealtimeClient.swift`: RT-02 ticket, then the WebSocket; ping every 5 minutes; reconnect after 1, 2, 5, 10, 30 s; `interaction.answered`, `interaction.on_hold`, `interaction.ended`, `session.ended`.
- `Phase2/InteractionEngine.swift`: start, wait (WebSocket, BODI-06 polling as the fallback), join the video only on answer (refreshing the token with BODI-08 when under 5 minutes are left), hold (camera and microphone off), end.
- `Phase2/LiveCallVideoBridge.swift`: runs it on the existing `Call`, CallKit, call screen and Vonage session. Phase 2 connection data (`role=agent;par=…`) marks the interpreter.

- Vonage Video comes from `github.com/Vonage/vonage-video-client-sdk-swift` (2.36.0; the old `opentok/vonage-client-sdk-video` package is read-only at 2.31.1). The module is still `OpenTok`. It needs iOS 17, so VideoCallKit's deployment target is iOS 17.6.
- Testing on a device: stop Xcode Device Hub screen sharing first. While it mirrors the phone, apps get black camera frames, so the outgoing video and self-view are black.
- Tests: the `VideoCallKitTests` scheme (`xcodebuild -workspace VideoCall.xcworkspace -scheme VideoCallKitTests test`). The test target imports the SDK with `@testable import VideoCallKit`; it doesn't compile SDK sources itself.
