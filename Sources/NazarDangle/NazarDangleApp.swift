import AppKit
import SwiftUI

@main
struct NazarDangleApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var state = AppState.shared

    var body: some Scene {
        MenuBarExtra("Nazar Dangle", systemImage: "eye.circle.fill") {
            Button(state.isOverlayVisible ? "Hide from Desktop" : "Show on Desktop") {
                state.isOverlayVisible.toggle()
            }

            Button("Swing charm") {
                NotificationCenter.default.post(name: .kickCharm, object: nil)
            }

            Divider()

            Menu("Charm") {
                Picker("Charm", selection: $state.charm) {
                    ForEach(AppState.Charm.allCases) { charm in
                        Text(charm.title).tag(charm)
                    }
                }
            }

            Toggle("Unlock position — drag to move", isOn: $state.isPositionUnlocked)

            Button("Reset to right side") {
                state.resetPosition()
            }

            Toggle("Sound", isOn: $state.soundEnabled)

            Button("Settings…") {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                NSApp.activate(ignoringOtherApps: true)
            }
            .keyboardShortcut(",")

            Divider()

            Button("Quit Nazar Dangle") {
                NSApp.terminate(nil)
            }
            .keyboardShortcut("q")
        }

        Settings {
            SettingsView()
                .environmentObject(state)
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var overlayController: OverlayController?
    private let motionMonitor = MotionMonitor()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        let state = AppState.shared
        overlayController = OverlayController(state: state)
        overlayController?.show()

        state.motionAvailable = motionMonitor.isAccelerometerAvailable
        state.motionAvailabilityMessage = motionMonitor.availabilityMessage

        state.onMotionPreferenceChanged = { [weak self] enabled in
            self?.motionMonitor.setEnabled(enabled)
        }
        motionMonitor.setEnabled(state.motionEnabled)
    }
}

extension Notification.Name {
    static let kickCharm = Notification.Name("NazarDangle.kickCharm")
}
