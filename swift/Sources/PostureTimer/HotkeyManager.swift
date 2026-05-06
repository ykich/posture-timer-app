import AppKit

/// グローバル・ローカルキーボードショートカットを監視するクラス。
///
/// - グローバルモニタ: Accessibility 権限がある場合に登録。他アプリ使用中でも動作する。
/// - ローカルモニタ: 権限不要。MenuBarExtra が開いているときのみ動作する。
final class HotkeyManager {
    private var globalMonitor: Any?
    private var localMonitor: Any?
    private var onToggleState: (() -> Void)?
    private var onTogglePause: (() -> Void)?
    private var config: HotkeyConfig = .default

    /// 初期設定とモニタ登録を行う。
    func setup(
        config: HotkeyConfig,
        onToggleState: @escaping () -> Void,
        onTogglePause: @escaping () -> Void
    ) {
        self.onToggleState = onToggleState
        self.onTogglePause = onTogglePause
        registerMonitors(config: config)
    }

    /// モニタを再登録する。設定変更時に呼び出す。
    func registerMonitors(config: HotkeyConfig) {
        self.config = config
        unregisterMonitors()

        if isAccessibilityGranted {
            globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
                _ = self?.handleKeyEvent(event)
            }
        }

        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self else { return event }
            return self.handleKeyEvent(event) ? nil : event
        }
    }

    func unregisterMonitors() {
        if let monitor = globalMonitor {
            NSEvent.removeMonitor(monitor)
            globalMonitor = nil
        }
        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
            localMonitor = nil
        }
    }

    /// Accessibility 権限が付与されているかどうか。
    var isAccessibilityGranted: Bool {
        AXIsProcessTrusted()
    }

    /// システムダイアログを表示して Accessibility 権限をリクエストする。
    func requestAccessibility() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
            as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }

    // MARK: - Private

    @discardableResult
    private func handleKeyEvent(_ event: NSEvent) -> Bool {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let char = event.charactersIgnoringModifiers?.lowercased() ?? ""

        let stateModifiers = NSEvent.ModifierFlags(rawValue: config.toggleStateModifiers)
            .intersection(.deviceIndependentFlagsMask)
        if config.toggleStateEnabled,
           flags == stateModifiers,
           char == config.toggleStateKey.lowercased() {
            onToggleState?()
            return true
        }

        let pauseModifiers = NSEvent.ModifierFlags(rawValue: config.togglePauseModifiers)
            .intersection(.deviceIndependentFlagsMask)
        if config.togglePauseEnabled,
           flags == pauseModifiers,
           char == config.togglePauseKey.lowercased() {
            onTogglePause?()
            return true
        }

        return false
    }
}
