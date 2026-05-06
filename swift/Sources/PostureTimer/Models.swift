import AppKit
import Foundation

// MARK: - PostureState

enum PostureState {
    case sitting
    case standing

    var icon: String {
        switch self {
        case .sitting: return "🪑"
        case .standing: return "🧍"
        }
    }

    var label: String {
        switch self {
        case .sitting: return "座っています"
        case .standing: return "立っています"
        }
    }

    var toggleLabel: String {
        switch self {
        case .sitting: return "立ち上がる"
        case .standing: return "座る"
        }
    }

    var toggled: PostureState {
        switch self {
        case .sitting: return .standing
        case .standing: return .sitting
        }
    }
}

// MARK: - HotkeyConfig

/// グローバルショートカット設定。
struct HotkeyConfig: Codable, Equatable {
    var toggleStateEnabled: Bool
    /// NSEvent.ModifierFlags の rawValue（⌘⌃ = 1310720）
    var toggleStateModifiers: UInt
    var toggleStateKey: String
    var togglePauseEnabled: Bool
    var togglePauseModifiers: UInt
    var togglePauseKey: String

    enum CodingKeys: String, CodingKey {
        case toggleStateEnabled = "toggle_state_enabled"
        case toggleStateModifiers = "toggle_state_modifiers"
        case toggleStateKey = "toggle_state_key"
        case togglePauseEnabled = "toggle_pause_enabled"
        case togglePauseModifiers = "toggle_pause_modifiers"
        case togglePauseKey = "toggle_pause_key"
    }

    static let `default` = HotkeyConfig(
        toggleStateEnabled: true,
        toggleStateModifiers: NSEvent.ModifierFlags([.command, .control]).rawValue,
        toggleStateKey: "s",
        togglePauseEnabled: true,
        togglePauseModifiers: NSEvent.ModifierFlags([.command, .control]).rawValue,
        togglePauseKey: "p"
    )

    /// ショートカットの表示文字列（例: "⌘⌃S"）
    func shortcutLabel(modifiers: UInt, key: String) -> String {
        let flags = NSEvent.ModifierFlags(rawValue: modifiers)
        var label = ""
        if flags.contains(.control) { label += "⌃" }
        if flags.contains(.option) { label += "⌥" }
        if flags.contains(.shift) { label += "⇧" }
        if flags.contains(.command) { label += "⌘" }
        return label + key.uppercased()
    }

    var toggleStateLabel: String { shortcutLabel(modifiers: toggleStateModifiers, key: toggleStateKey) }
    var togglePauseLabel: String { shortcutLabel(modifiers: togglePauseModifiers, key: togglePauseKey) }
}

// MARK: - AppConfig

/// アプリ設定。
struct AppConfig: Codable {
    var sitAlertMinutes: Int
    var standAlertMinutes: Int
    /// 警告後の繰り返し通知間隔（分）。0 = 繰り返しなし。
    var repeatIntervalMinutes: Int
    var hotkeyConfig: HotkeyConfig

    enum CodingKeys: String, CodingKey {
        case sitAlertMinutes = "sit_alert_minutes"
        case standAlertMinutes = "stand_alert_minutes"
        case repeatIntervalMinutes = "repeat_interval_minutes"
        case hotkeyConfig = "hotkey_config"
    }

    init(
        sitAlertMinutes: Int,
        standAlertMinutes: Int,
        repeatIntervalMinutes: Int = 0,
        hotkeyConfig: HotkeyConfig = .default
    ) {
        self.sitAlertMinutes = sitAlertMinutes
        self.standAlertMinutes = standAlertMinutes
        self.repeatIntervalMinutes = repeatIntervalMinutes
        self.hotkeyConfig = hotkeyConfig
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sitAlertMinutes = try container.decode(Int.self, forKey: .sitAlertMinutes)
        standAlertMinutes = try container.decode(Int.self, forKey: .standAlertMinutes)
        repeatIntervalMinutes = try container.decodeIfPresent(Int.self, forKey: .repeatIntervalMinutes) ?? 0
        hotkeyConfig = try container.decodeIfPresent(HotkeyConfig.self, forKey: .hotkeyConfig) ?? .default
    }

    static let `default` = AppConfig(sitAlertMinutes: 30, standAlertMinutes: 30)
}

// MARK: - Formatters

/// 秒数を "hh:mm:ss" または "mm:ss" 形式にフォーマットする。
func formatDuration(_ seconds: TimeInterval) -> String {
    let total = Int(max(0, seconds))
    let h = total / 3600
    let m = (total % 3600) / 60
    let s = total % 60
    if h > 0 {
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
    return String(format: "%02d:%02d", m, s)
}
