import AppKit
import Combine
import Foundation

/// タイマー・状態管理の中心クラス。
///
/// - 1秒ごとに `tick()` が呼ばれ、経過時間・メニューバータイトルを更新する。
/// - 座り/立ちの閾値超過時に通知を送信する。
@MainActor
final class TimerManager: ObservableObject {

    // MARK: - Published

    @Published var state: PostureState = .sitting
    @Published var sessionElapsed: TimeInterval = 0
    @Published var paused: Bool = false
    @Published var config: AppConfig
    @Published var menuBarTitle: String = "🪑 00:00"

    // MARK: - Private state

    private var sessionStart: Date = Date()
    private var pauseStart: Date?
    /// 座り警告を最後に送信した時刻。nil = まだ未送信。
    private var lastSitAlertedAt: Date?
    /// 立ち警告を最後に送信した時刻。nil = まだ未送信。
    private var lastStandAlertedAt: Date?
    private var timer: Timer?

    // MARK: - Dependencies

    private let notificationManager = NotificationManager.shared
    private let hotkeyManager = HotkeyManager()

    // MARK: - Init

    init() {
        config = Self.loadConfig()
        notificationManager.requestPermission()
        startTimer()
        setupHotkeys()
    }

    // MARK: - Hotkeys

    private func setupHotkeys() {
        hotkeyManager.setup(
            config: config.hotkeyConfig,
            onToggleState: { [weak self] in
                Task { @MainActor [weak self] in self?.toggleState() }
            },
            onTogglePause: { [weak self] in
                Task { @MainActor [weak self] in self?.togglePause() }
            }
        )
    }

    func updateHotkeyConfig(_ newConfig: HotkeyConfig) {
        config = AppConfig(
            sitAlertMinutes: config.sitAlertMinutes,
            standAlertMinutes: config.standAlertMinutes,
            repeatIntervalMinutes: config.repeatIntervalMinutes,
            hotkeyConfig: newConfig
        )
        saveConfig(config)
        hotkeyManager.registerMonitors(config: newConfig)
    }

    // MARK: - Timer

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.tick()
            }
        }
    }

    private func tick() {
        let now = Date()

        guard !paused else { return }

        sessionElapsed = now.timeIntervalSince(sessionStart)

        checkAlert(sessionElapsed: sessionElapsed)

        menuBarTitle = "\(state.icon) \(formatDuration(sessionElapsed))"
    }

    private func checkAlert(sessionElapsed: TimeInterval) {
        let now = Date()
        switch state {
        case .sitting:
            let threshold = TimeInterval(config.sitAlertMinutes * 60)
            guard config.sitAlertMinutes > 0, sessionElapsed >= threshold else { return }
            if let last = lastSitAlertedAt {
                let repeatThreshold = TimeInterval(config.repeatIntervalMinutes * 60)
                guard config.repeatIntervalMinutes > 0,
                    now.timeIntervalSince(last) >= repeatThreshold
                else { return }
                notificationManager.sendNotification(
                    title: "PostureTimer",
                    body: "さらに\(config.repeatIntervalMinutes)分経過しました。まだ座っていますか？"
                )
            } else {
                notificationManager.sendNotification(
                    title: "PostureTimer",
                    body: "\(config.sitAlertMinutes)分座り続けています。立ち上がりましょう！"
                )
            }
            lastSitAlertedAt = now
        case .standing:
            let threshold = TimeInterval(config.standAlertMinutes * 60)
            guard config.standAlertMinutes > 0, sessionElapsed >= threshold else { return }
            if let last = lastStandAlertedAt {
                let repeatThreshold = TimeInterval(config.repeatIntervalMinutes * 60)
                guard config.repeatIntervalMinutes > 0,
                    now.timeIntervalSince(last) >= repeatThreshold
                else { return }
                notificationManager.sendNotification(
                    title: "PostureTimer",
                    body: "さらに\(config.repeatIntervalMinutes)分経過しました。まだ立っていますか？"
                )
            } else {
                notificationManager.sendNotification(
                    title: "PostureTimer",
                    body: "\(config.standAlertMinutes)分立ち続けています。座りましょう！"
                )
            }
            lastStandAlertedAt = now
        }
    }

    // MARK: - Actions

    /// 座り/立ちを切り替える。一時停止中なら自動で解除する。
    func toggleState() {
        if paused { resume() }

        state = state.toggled
        sessionStart = Date()
        lastSitAlertedAt = nil
        lastStandAlertedAt = nil
    }

    /// 一時停止/再開を切り替える。
    func togglePause() {
        if paused {
            resume()
        } else {
            pauseStart = Date()
            paused = true
            menuBarTitle = "⏸"
        }
    }

    /// 終了前にアプリを終了する。
    func quit() {
        NSApplication.shared.terminate(nil)
    }

    // MARK: - Alert settings

    func updateSitAlert(minutes: Int) {
        config = AppConfig(
            sitAlertMinutes: minutes, standAlertMinutes: config.standAlertMinutes,
            repeatIntervalMinutes: config.repeatIntervalMinutes,
            hotkeyConfig: config.hotkeyConfig)
        saveConfig(config)
        lastSitAlertedAt = nil
    }

    func updateStandAlert(minutes: Int) {
        config = AppConfig(
            sitAlertMinutes: config.sitAlertMinutes, standAlertMinutes: minutes,
            repeatIntervalMinutes: config.repeatIntervalMinutes,
            hotkeyConfig: config.hotkeyConfig)
        saveConfig(config)
        lastStandAlertedAt = nil
    }

    func updateRepeatInterval(minutes: Int) {
        config = AppConfig(
            sitAlertMinutes: config.sitAlertMinutes, standAlertMinutes: config.standAlertMinutes,
            repeatIntervalMinutes: minutes,
            hotkeyConfig: config.hotkeyConfig)
        saveConfig(config)
    }

    // MARK: - Private helpers

    /// 一時停止を解除し、停止期間分だけ sessionStart を補正する。
    private func resume() {
        guard paused, let ps = pauseStart else { return }
        let pauseDuration = Date().timeIntervalSince(ps)
        sessionStart = sessionStart.addingTimeInterval(pauseDuration)
        pauseStart = nil
        paused = false
    }

    // MARK: - UserDefaults

    private static func loadConfig() -> AppConfig {
        guard
            let data = UserDefaults.standard.data(forKey: "appConfig"),
            let config = try? JSONDecoder().decode(AppConfig.self, from: data)
        else {
            return .default
        }
        return config
    }

    private func saveConfig(_ config: AppConfig) {
        guard let data = try? JSONEncoder().encode(config) else { return }
        UserDefaults.standard.set(data, forKey: "appConfig")
    }
}
