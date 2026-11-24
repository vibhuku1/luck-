import Foundation

@MainActor
final class MotionMonitor {
    var isAccelerometerAvailable: Bool {
        false
    }

    var availabilityMessage: String {
        "Native macOS does not expose the MacBook accelerometer through a public API. This app does not use private hardware APIs; drag or click the charm to swing it."
    }

    func setEnabled(_ enabled: Bool) {
        // There is no supported native-macOS sensor service to start.
    }
}
