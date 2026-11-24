import SwiftUI

@MainActor
final class SwingPhysics: ObservableObject {
    @Published private(set) var angle: Double = 0

    private var angularVelocity: Double = 0
    private var lastTimestamp = Date()
    private var timer: Timer?

    init() {
        let timer = Timer(timeInterval: 1.0 / 90.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.advance()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func applyDrag(deltaX: CGFloat) {
        let delta = Double(deltaX)
        angle = (angle + delta * 0.0082).clamped(to: -0.62...0.62)
        angularVelocity = (delta * 1.75).clamped(to: -6.5...6.5)
    }

    func release() {
        angularVelocity *= 1.18
    }

    func kick() {
        angularVelocity += angle >= 0 ? 2.7 : -2.7
    }

    private func advance() {
        let now = Date()
        let dt = min(now.timeIntervalSince(lastTimestamp), 1.0 / 24.0)
        lastTimestamp = now

        let previousVelocity = angularVelocity
        angularVelocity += (-18.5 * sin(angle) - 2.05 * angularVelocity) * dt
        angle += angularVelocity * dt

        if abs(angle) < 0.0008, abs(angularVelocity) < 0.002 {
            angle = 0
            angularVelocity = 0
        }

        if angle > 0.66 || angle < -0.66 {
            angle = angle.clamped(to: -0.66...0.66)
            angularVelocity *= -0.32
        }

        if previousVelocity.sign != angularVelocity.sign,
           abs(previousVelocity) > 1.45,
           AppState.shared.charm == .bell {
            BellSound.shared.play(enabled: AppState.shared.soundEnabled, volume: AppState.shared.soundVolume)
        }
    }
}

struct OverlayScene: View {
    @EnvironmentObject private var state: AppState
    @ObservedObject var physics: SwingPhysics
    let onMove: (CGSize) -> Void

    @State private var lastDragX: CGFloat = 0

    var body: some View {
        CharmImage(charm: state.charm)
            .scaleEffect(state.charmScale, anchor: .top)
            .rotationEffect(.radians(state.isPositionUnlocked ? 0 : physics.angle), anchor: .top)
            .frame(width: 300, height: 444, alignment: .top)
            .contentShape(Rectangle())
            .gesture(dragGesture)
            .onTapGesture {
                guard !state.isPositionUnlocked else { return }
                physics.kick()
            }
            .onReceive(NotificationCenter.default.publisher(for: .kickCharm)) { _ in
                physics.kick()
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel(accessibilityDescription)
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard !state.isPositionUnlocked else { return }
                let delta = value.translation.width - lastDragX
                lastDragX = value.translation.width
                physics.applyDrag(deltaX: delta)
            }
            .onEnded { value in
                if state.isPositionUnlocked {
                    onMove(value.translation)
                } else {
                    lastDragX = 0
                    physics.release()
                }
            }
    }

    private var accessibilityDescription: String {
        state.isPositionUnlocked
            ? "Position unlocked. Drag to move the charm on the Desktop."
            : "\(state.charm.title). Drag to swing it."
    }
}

struct CharmImage: View {
    let charm: AppState.Charm

    var body: some View {
        Image(charm.imageName, bundle: .module)
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .frame(maxWidth: 272, maxHeight: 438, alignment: .top)
            .shadow(color: .black.opacity(0.24), radius: 7, y: 6)
            .accessibilityHidden(true)
    }
}
