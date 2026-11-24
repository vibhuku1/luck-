import AppKit
import Foundation
import ServiceManagement
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    static let shared = AppState()

    enum Anchor: String, CaseIterable, Identifiable {
        case left
        case center
        case right

        var id: String { rawValue }

        var title: String {
            switch self {
            case .left: "Left"
            case .center: "Center / notch"
            case .right: "Right"
            }
        }
    }

    enum Charm: String, CaseIterable, Identifiable {
        case bell
        case lemonChilli = "lemon-chilli"
        case nazar

        var id: String { rawValue }

        var title: String {
            switch self {
            case .bell: "Bell"
            case .lemonChilli: "Lemon & Chilli"
            case .nazar: "Nazar Battu"
            }
        }

        var imageName: String { rawValue }
    }

    @Published var charmScale: Double {
        didSet {
            charmScale = charmScale.clamped(to: 0.65...1.25)
            defaults.set(charmScale, forKey: Key.charmScale)
            onPlacementChanged?()
        }
    }

    @Published var horizontalOffset: Double {
        didSet {
            horizontalOffset = horizontalOffset.clamped(to: -2_000...2_000)
            defaults.set(horizontalOffset, forKey: Key.horizontalOffset)
            onPlacementChanged?()
        }
    }

    @Published var verticalOffset: Double {
        didSet {
            verticalOffset = verticalOffset.clamped(to: 0...2_000)
            defaults.set(verticalOffset, forKey: Key.verticalOffset)
            onPlacementChanged?()
        }
    }

    @Published var anchor: Anchor {
        didSet {
            defaults.set(anchor.rawValue, forKey: Key.anchor)
            onPlacementChanged?()
        }
    }

    @Published var soundEnabled: Bool {
        didSet { defaults.set(soundEnabled, forKey: Key.soundEnabled) }
    }

    @Published var charm: Charm {
        didSet { defaults.set(charm.rawValue, forKey: Key.charm) }
    }

    @Published var isPositionUnlocked: Bool {
        didSet { defaults.set(isPositionUnlocked, forKey: Key.isPositionUnlocked) }
    }

    @Published var soundVolume: Double {
        didSet {
            soundVolume = soundVolume.clamped(to: 0...1)
            defaults.set(soundVolume, forKey: Key.soundVolume)
        }
    }

    @Published var motionEnabled: Bool {
        didSet {
            defaults.set(motionEnabled, forKey: Key.motionEnabled)
            onMotionPreferenceChanged?(motionEnabled)
        }
    }

    @Published var launchAtLogin: Bool {
        didSet {
            defaults.set(launchAtLogin, forKey: Key.launchAtLogin)
            updateLaunchAtLogin()
        }
    }

    @Published var isOverlayVisible = true {
        didSet { onVisibilityChanged?(isOverlayVisible) }
    }

    @Published var motionAvailable = false
    @Published var motionAvailabilityMessage = "Checking this Mac’s sensors…"
    @Published private(set) var launchAtLoginMessage = ""

    var onPlacementChanged: (() -> Void)?
    var onVisibilityChanged: ((Bool) -> Void)?
    var onMotionPreferenceChanged: ((Bool) -> Void)?

    private let defaults = UserDefaults.standard

    private init() {
        charmScale = defaults.object(forKey: Key.charmScale) as? Double ?? 1
        horizontalOffset = defaults.object(forKey: Key.horizontalOffset) as? Double ?? 0
        verticalOffset = defaults.object(forKey: Key.verticalOffset) as? Double ?? 0
        anchor = Anchor(rawValue: defaults.string(forKey: Key.anchor) ?? Anchor.right.rawValue) ?? .right
        soundEnabled = defaults.object(forKey: Key.soundEnabled) as? Bool ?? true
        soundVolume = defaults.object(forKey: Key.soundVolume) as? Double ?? 0.55
        charm = Charm(rawValue: defaults.string(forKey: Key.charm) ?? Charm.nazar.rawValue) ?? .nazar
        isPositionUnlocked = defaults.object(forKey: Key.isPositionUnlocked) as? Bool ?? false
        motionEnabled = false
        launchAtLogin = defaults.object(forKey: Key.launchAtLogin) as? Bool ?? false
    }

    func playTestBell() {
        BellSound.shared.play(enabled: soundEnabled, volume: soundVolume)
    }

    func resetPosition() {
        anchor = .right
        horizontalOffset = 0
        verticalOffset = 0
    }

    private func updateLaunchAtLogin() {
        if launchAtLogin {
            do {
                try SMAppService.mainApp.register()
                launchAtLoginMessage = "Launch at Login is enabled."
            } catch {
                launchAtLoginMessage = "macOS could not enable Launch at Login: \(error.localizedDescription)"
            }
        } else {
            do {
                try SMAppService.mainApp.unregister()
                launchAtLoginMessage = "Launch at Login is disabled."
            } catch {
                launchAtLoginMessage = "macOS could not change Launch at Login: \(error.localizedDescription)"
            }
        }
    }

    private enum Key {
        static let charmScale = "charmScale"
        static let horizontalOffset = "horizontalOffset"
        static let verticalOffset = "verticalOffset"
        static let anchor = "anchor"
        static let soundEnabled = "soundEnabled"
        static let soundVolume = "soundVolume"
        static let charm = "charm"
        static let isPositionUnlocked = "isPositionUnlocked"
        static let motionEnabled = "motionEnabled"
        static let launchAtLogin = "launchAtLogin"
    }
}

@MainActor
final class BellSound {
    static let shared = BellSound()

    private var lastPlayed = Date.distantPast

    func play(enabled: Bool, volume: Double) {
        guard enabled, Date().timeIntervalSince(lastPlayed) > 0.13 else { return }
        lastPlayed = Date()

        if let sound = NSSound(named: NSSound.Name("Glass")) {
            sound.stop()
            sound.volume = Float(volume)
            sound.play()
        } else {
            NSSound.beep()
        }
    }
}

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
