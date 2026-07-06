import AppKit
import SwiftUI

/// メニューバーポップオーバーの SwiftUI ビュー。
///
/// MenuBarExtra の `.window` スタイルで表示される。
struct MenuBarView: View {
  @EnvironmentObject var timerManager: TimerManager
  @Environment(\.openWindow) private var openWindow

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      statusSection
      Divider()
      sessionSection
      Divider()
      actionSection
      Divider()
      settingsSection
      Divider()
      Button("終了") { timerManager.quit() }
        .buttonStyle(MenuButtonStyle())
    }
    .frame(width: 240)
  }

  // MARK: - Sections

  private var statusSection: some View {
    Text(statusLabel)
      .font(.caption)
      .foregroundColor(.secondary)
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
  }

  private var sessionSection: some View {
    VStack(alignment: .leading, spacing: 2) {
      menuLabel(sittingSessionLabel)
      menuLabel(standingSessionLabel)
    }
    .padding(.vertical, 4)
  }

  private var actionSection: some View {
    VStack(alignment: .leading, spacing: 0) {
      Button(timerManager.state.toggleLabel) {
        timerManager.toggleState()
      }
      .buttonStyle(MenuButtonStyle())

      Button("リセット") {
        timerManager.reset()
      }
      .buttonStyle(MenuButtonStyle())

      Button(timerManager.paused ? "再開" : "一時停止") {
        timerManager.togglePause()
      }
      .buttonStyle(MenuButtonStyle())
    }
  }

  private var settingsSection: some View {
    VStack(alignment: .leading, spacing: 0) {
      Button("⚙️ 設定（座り: \(alertLabel(timerManager.config.sitAlertMinutes)) / 立ち: \(alertLabel(timerManager.config.standAlertMinutes))）") {
        NSApp.activate(ignoringOtherApps: true)
        openWindow(id: "settings")
      }
      .buttonStyle(MenuButtonStyle())
    }
  }

  // MARK: - Computed labels

  private var statusLabel: String {
    if timerManager.paused { return "⏸ 一時停止中" }
    return "● \(timerManager.state.label)"
  }

  private var sittingSessionLabel: String {
    if timerManager.paused { return "🪑 座り: --" }
    if timerManager.state == .sitting {
      return "🪑 座り: \(formatDuration(timerManager.sessionElapsed))"
    }
    return "🪑 座り: --:--"
  }

  private var standingSessionLabel: String {
    if timerManager.paused { return "🧍 立ち: --" }
    if timerManager.state == .standing {
      return "🧍 立ち: \(formatDuration(timerManager.sessionElapsed))"
    }
    return "🧍 立ち: --:--"
  }

  // MARK: - Helpers

  private func menuLabel(_ text: String) -> some View {
    Text(text)
      .font(.system(.body, design: .monospaced))
      .padding(.horizontal, 12)
      .padding(.vertical, 2)
  }

  private func alertLabel(_ minutes: Int) -> String {
    minutes > 0 ? "\(minutes)分後" : "無効"
  }
}

// MARK: - MenuButtonStyle

/// メニュー項目風のボタンスタイル。
private struct MenuButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
      .background(configuration.isPressed ? Color.accentColor.opacity(0.15) : Color.clear)
      .contentShape(Rectangle())
  }
}
