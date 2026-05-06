import AppKit
import SwiftUI

// MARK: - SettingsTab

private enum SettingsTab: CaseIterable {
    case general, alert, shortcut

    var label: String {
        switch self {
        case .general: return "一般"
        case .alert: return "通知"
        case .shortcut: return "ショートカット"
        }
    }

    var systemImage: String {
        switch self {
        case .general: return "gearshape.fill"
        case .alert: return "bell.fill"
        case .shortcut: return "keyboard.fill"
        }
    }
}

// MARK: - SettingsView

struct SettingsView: View {
    @EnvironmentObject var timerManager: TimerManager
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var launchManager = LaunchAtLoginManager.shared

    @State private var selectedTab: SettingsTab = .general
    @State private var hoveredTab: SettingsTab?

    // 通知タブ
    @State private var sitInput = ""
    @State private var standInput = ""
    @State private var repeatInput = ""

    // ショートカットタブ
    @State private var hotkeyConfig: HotkeyConfig = .default

    var body: some View {
        VStack(spacing: 0) {
            tabBar

            Divider()

            Group {
                switch selectedTab {
                case .general: generalTab
                case .alert: alertTab
                case .shortcut: shortcutTab
                }
            }
            .frame(minHeight: 260)

            Divider()

            HStack {
                Spacer()
                Button("キャンセル") { dismiss() }
                    .keyboardShortcut(.escape, modifiers: [])
                Button("保存") { save() }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.return, modifiers: [])
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
        .frame(width: 420)
        .onAppear {
            sitInput = String(timerManager.config.sitAlertMinutes)
            standInput = String(timerManager.config.standAlertMinutes)
            repeatInput = String(timerManager.config.repeatIntervalMinutes)

            hotkeyConfig = timerManager.config.hotkeyConfig

            NSApp.activate(ignoringOtherApps: true)
        }
    }

    // MARK: - タブバー

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(SettingsTab.allCases, id: \.self) { tab in
                tabBarButton(tab)
            }
        }
        .background(Color(NSColor.windowBackgroundColor))
    }

    private func tabBarButton(_ tab: SettingsTab) -> some View {
        let isSelected = selectedTab == tab
        let isHovered = hoveredTab == tab
        return Button(action: { selectedTab = tab }) {
            VStack(spacing: 5) {
                Image(systemName: tab.systemImage)
                    .font(.title2)
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                Text(tab.label)
                    .font(.caption)
                    .foregroundStyle(isSelected ? Color.primary : Color.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
            .background(tabBackground(isSelected: isSelected, isHovered: isHovered))
            .overlay(
                Rectangle()
                    .frame(height: 2)
                    .foregroundStyle(isSelected ? Color.accentColor : Color.clear),
                alignment: .bottom
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            hoveredTab = hovering ? tab : (hoveredTab == tab ? nil : hoveredTab)
            if hovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }

    private func tabBackground(isSelected: Bool, isHovered: Bool) -> Color {
        if isSelected { return Color.accentColor.opacity(0.10) }
        if isHovered { return Color.gray.opacity(0.08) }
        return Color.clear
    }

    // MARK: - 一般タブ

    private var generalTab: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("ログイン時に起動")
                        .fontWeight(.medium)
                    Text("macOS にログインしたときにアプリを自動で起動します")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
                Spacer()
                Toggle("", isOn: Binding(
                    get: { launchManager.isEnabled },
                    set: { _ in launchManager.toggle() }
                ))
                .labelsHidden()
            }
            Spacer()
        }
        .padding(20)
    }

    // MARK: - 通知タブ

    private var alertTab: some View {
        VStack(alignment: .leading, spacing: 20) {
            alertRow(label: "座り警告", description: "座り続け警告の時間（分）", input: $sitInput)
            alertRow(label: "立ち警告", description: "立ち続け警告の時間（分）", input: $standInput)
            Divider()
            alertRow(label: "繰り返し間隔", description: "警告後に再通知する間隔（分）", input: $repeatInput)
            Text("0で無効（警告は1回のみ）")
                .foregroundStyle(.secondary)
                .font(.caption)
            Spacer()
        }
        .padding(20)
    }

    private func alertRow(label: String, description: String, input: Binding<String>) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .fontWeight(.medium)
                Text(description)
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
            Spacer()
            TextField("分", text: input)
                .textFieldStyle(.roundedBorder)
                .frame(width: 60)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - ショートカットタブ

    private var shortcutTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                shortcutRow(
                    label: "座り/立ち切替",
                    enabled: $hotkeyConfig.toggleStateEnabled,
                    modifiers: $hotkeyConfig.toggleStateModifiers,
                    key: $hotkeyConfig.toggleStateKey
                )
                Divider()
                shortcutRow(
                    label: "一時停止/再開",
                    enabled: $hotkeyConfig.togglePauseEnabled,
                    modifiers: $hotkeyConfig.togglePauseModifiers,
                    key: $hotkeyConfig.togglePauseKey
                )
                Divider()
                accessibilitySection
                Spacer()
            }
            .padding(20)
        }
    }

    private func shortcutRow(
        label: String,
        enabled: Binding<Bool>,
        modifiers: Binding<UInt>,
        key: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(label).fontWeight(.medium)
                Spacer()
                Toggle("", isOn: enabled).labelsHidden()
            }
            if enabled.wrappedValue {
                HStack(spacing: 6) {
                    modifierToggle("⌃", flag: .control, modifiers: modifiers)
                    modifierToggle("⌥", flag: .option, modifiers: modifiers)
                    modifierToggle("⇧", flag: .shift, modifiers: modifiers)
                    modifierToggle("⌘", flag: .command, modifiers: modifiers)
                    Text("+").foregroundStyle(.secondary)
                    TextField("キー", text: key)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 44)
                        .multilineTextAlignment(.center)
                        .onChange(of: key.wrappedValue) { newValue in
                            let normalized = String(newValue.suffix(1)).lowercased()
                            if key.wrappedValue != normalized {
                                key.wrappedValue = normalized
                            }
                        }
                    Spacer()
                    Text(HotkeyConfig.default.shortcutLabel(modifiers: modifiers.wrappedValue, key: key.wrappedValue))
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func modifierToggle(
        _ symbol: String,
        flag: NSEvent.ModifierFlags,
        modifiers: Binding<UInt>
    ) -> some View {
        let isActive = NSEvent.ModifierFlags(rawValue: modifiers.wrappedValue).contains(flag)
        return Button(symbol) {
            var flags = NSEvent.ModifierFlags(rawValue: modifiers.wrappedValue)
            if isActive { flags.remove(flag) } else { flags.insert(flag) }
            modifiers.wrappedValue = flags.rawValue
        }
        .buttonStyle(.bordered)
        .tint(isActive ? .accentColor : .secondary)
        .font(.system(.body, design: .monospaced))
    }

    private var accessibilitySection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: AXIsProcessTrusted() ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                    .foregroundStyle(AXIsProcessTrusted() ? .green : .orange)
                Text(AXIsProcessTrusted() ? "アクセシビリティ権限: 承認済み" : "アクセシビリティ権限: 未承認")
                    .font(.caption)
            }
            if !AXIsProcessTrusted() {
                Text("グローバルショートカットはアクセシビリティ権限が必要です。権限がない場合、メニューが開いているときのみ動作します。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Button("システム設定でアクセシビリティを開く") {
                    NSWorkspace.shared.open(
                        URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
                    )
                }
                .font(.caption)
                .buttonStyle(.bordered)
            }
        }
    }

    // MARK: - 保存

    private func save() {
        if let sit = Int(sitInput), sit >= 0 {
            timerManager.updateSitAlert(minutes: sit)
        }
        if let stand = Int(standInput), stand >= 0 {
            timerManager.updateStandAlert(minutes: stand)
        }
        if let repeat_ = Int(repeatInput), repeat_ >= 0 {
            timerManager.updateRepeatInterval(minutes: repeat_)
        }
        timerManager.updateHotkeyConfig(hotkeyConfig)
        dismiss()
    }
}

