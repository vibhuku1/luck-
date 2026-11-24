import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        Form {
            Section("Desktop-only display") {
                Text("The charm appears only on the Desktop. It automatically hides when you open or switch to another app, browser, or full-screen window.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Charm") {
                Picker("Design", selection: $state.charm) {
                    ForEach(AppState.Charm.allCases) { charm in
                        Text(charm.title).tag(charm)
                    }
                }

                Toggle("Unlock position — drag to move", isOn: $state.isPositionUnlocked)

                Picker("Starting side", selection: $state.anchor) {
                    ForEach(AppState.Anchor.allCases) { anchor in
                        Text(anchor.title).tag(anchor)
                    }
                }

                Slider(value: $state.horizontalOffset, in: -1_000...1_000, step: 1) {
                    Text("Left / right position")
                } minimumValueLabel: {
                    Text("←")
                } maximumValueLabel: {
                    Text("→")
                }

                Slider(value: $state.verticalOffset, in: 0...1_000, step: 1) {
                    Text("Lower from top")
                }

                Slider(value: $state.charmScale, in: 0.65...1.25, step: 0.01) {
                    Text("Charm size")
                }

                Button("Reset to right side") {
                    state.resetPosition()
                }
            }

            if state.charm == .bell {
                Section("Bell sound") {
                    Toggle("Play sound while swinging", isOn: $state.soundEnabled)
                    HStack {
                        Slider(value: $state.soundVolume, in: 0...1)
                            .disabled(!state.soundEnabled)
                        Button("Test bell") {
                            state.playTestBell()
                        }
                        .disabled(!state.soundEnabled)
                    }
                }
            }

            Section("Motion") {
                Toggle("Nudge from Mac movement when available", isOn: $state.motionEnabled)
                    .disabled(!state.motionAvailable)
                Text(state.motionAvailabilityMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Startup") {
                Toggle("Launch at Login", isOn: $state.launchAtLogin)
                if !state.launchAtLoginMessage.isEmpty {
                    Text(state.launchAtLoginMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .formStyle(.grouped)
        .padding(20)
        .frame(width: 510)
    }
}
