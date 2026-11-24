import AppKit
import SwiftUI

@MainActor
final class OverlayController {
    private let state: AppState
    private let physics = SwingPhysics()
    private var panel: NSPanel?
    private var workspaceObservers: [NSObjectProtocol] = []

    init(state: AppState) {
        self.state = state
        state.onPlacementChanged = { [weak self] in self?.reposition() }
        state.onVisibilityChanged = { [weak self] visible in
            if visible {
                self?.show()
            } else {
                self?.panel?.orderOut(nil)
            }
        }

        let workspaceCenter = NSWorkspace.shared.notificationCenter
        workspaceObservers = [
            workspaceCenter.addObserver(
                forName: NSWorkspace.didActivateApplicationNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.updateDesktopVisibility()
                }
            },
            workspaceCenter.addObserver(
                forName: NSWorkspace.activeSpaceDidChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.updateDesktopVisibility()
                }
            }
        ]
    }

    func show() {
        if panel == nil {
            let panel = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: 336, height: 458),
                styleMask: [.borderless, .nonactivatingPanel],
                backing: .buffered,
                defer: false
            )
            panel.isOpaque = false
            panel.backgroundColor = .clear
            panel.hasShadow = false
            panel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopIconWindow)))
            panel.collectionBehavior = [.moveToActiveSpace, .stationary, .ignoresCycle]
            panel.hidesOnDeactivate = false
            panel.isMovableByWindowBackground = false
            panel.becomesKeyOnlyIfNeeded = true
            panel.contentView = NSHostingView(rootView: AnyView(
                OverlayScene(physics: physics) { [weak self] translation in
                    self?.move(by: translation)
                }
                    .environmentObject(state)
            ))
            self.panel = panel
        }

        reposition()
        updateDesktopVisibility()
    }

    private func move(by translation: CGSize) {
        state.horizontalOffset += Double(translation.width)
        state.verticalOffset += Double(translation.height)
    }

    private func updateDesktopVisibility() {
        guard state.isOverlayVisible, isDesktopActive else {
            panel?.orderOut(nil)
            return
        }
        reposition()
        panel?.orderFrontRegardless()
    }

    private var isDesktopActive: Bool {
        guard let frontmost = NSWorkspace.shared.frontmostApplication?.bundleIdentifier else {
            return true
        }
        return frontmost == "com.apple.finder" || frontmost == Bundle.main.bundleIdentifier
    }

    private func reposition() {
        guard let panel, let screen = NSScreen.main else { return }
        let panelSize = panel.frame.size
        let screenFrame = screen.frame
        let initialX: CGFloat

        switch state.anchor {
        case .left:
            initialX = screenFrame.minX + 38
        case .center:
            initialX = screenFrame.midX - panelSize.width / 2
        case .right:
            initialX = screenFrame.maxX - panelSize.width - 38
        }

        let desiredX = initialX + state.horizontalOffset
        let x = desiredX.clamped(to: screenFrame.minX...screenFrame.maxX - panelSize.width)
        let desiredY = screenFrame.maxY - panelSize.height - state.verticalOffset
        let y = desiredY.clamped(to: screenFrame.minY...screenFrame.maxY - panelSize.height)
        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }
}
