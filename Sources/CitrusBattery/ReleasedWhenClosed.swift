import AppKit
import SwiftUI

/// Shows `content` only while its window is on screen. SwiftUI keeps a closed
/// window, and everything in it, alive and updating with each battery reading,
/// which kept tens of megabytes in use and redrew it every few seconds. Closed,
/// the content is let go; it's built again when the window reopens. State that
/// should outlast that (the selected page) lives in shared objects.
struct ReleasedWhenClosed<Content: View>: View {
    @ViewBuilder var content: () -> Content
    @ObservedObject private var launch = LaunchState.shared
    @ViewState private var isOnScreen = true

    var body: some View {
        ZStack {
            if isOnScreen && launch.windowsMayDraw { content() }
        }
        .background(WindowPresenceReader(isOnScreen: $isOnScreen))
    }
}

/// SwiftUI opens the main window as the app launches, before it's known whether
/// this is a login launch that starts hidden. Windows stay empty until that's
/// settled, so a window that's only going to be closed again is never built.
@MainActor
final class LaunchState: ObservableObject {
    static let shared = LaunchState()
    @Published private(set) var windowsMayDraw = false

    func allowWindowsToDraw() {
        if !windowsMayDraw { windowsMayDraw = true }
    }
}

/// Follows whether the window holding it is on screen (or minimised in the Dock).
private struct WindowPresenceReader: NSViewRepresentable {
    @Binding var isOnScreen: Bool

    func makeNSView(context: Context) -> PresenceView {
        let view = PresenceView()
        view.onChange = { isOnScreen = $0 }
        return view
    }

    func updateNSView(_ view: PresenceView, context: Context) {
        view.onChange = { isOnScreen = $0 }
    }

    final class PresenceView: NSView {
        var onChange: ((Bool) -> Void)?

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            // Selector observers are removed automatically when the view goes.
            let center = NotificationCenter.default
            center.removeObserver(self)
            guard let window else { return }
            center.addObserver(self, selector: #selector(willClose), name: NSWindow.willCloseNotification,
                               object: window)
            // Reopening brings the same window back rather than making a new one.
            for name in [NSWindow.didBecomeKeyNotification, NSWindow.didChangeOcclusionStateNotification,
                         NSWindow.didMiniaturizeNotification, NSWindow.didDeminiaturizeNotification] {
                center.addObserver(self, selector: #selector(windowStateChanged), name: name, object: window)
            }
        }

        @objc private func willClose(_ notification: Notification) {
            report(false)
        }

        @objc private func windowStateChanged(_ notification: Notification) {
            guard let window else { return }
            report(window.isVisible || window.isMiniaturized)
        }

        private func report(_ onScreen: Bool) {
            // After the current update: changing SwiftUI state from inside a
            // window notification can land mid-update.
            DispatchQueue.main.async { self.onChange?(onScreen) }
        }
    }
}

