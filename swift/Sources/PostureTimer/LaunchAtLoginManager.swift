import Combine
import Foundation

/// ログイン時の自動起動を LaunchAgent plist で管理するクラス。
///
/// `~/Library/LaunchAgents/com.posturetimer.launcher.plist` の有無で状態を管理する。
/// `.app` バンドル実行時は `open -a` 経由で起動し、非バンドル実行時はバイナリパスを直接指定する。
@MainActor
final class LaunchAtLoginManager: ObservableObject {

    static let shared = LaunchAtLoginManager()

    @Published private(set) var isEnabled: Bool = false

    private let plistName = "com.posturetimer.launcher.plist"
    private let plistURL: URL

    private init() {
        let launchAgentsURL = FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent("Library/LaunchAgents")
        plistURL = launchAgentsURL.appendingPathComponent(plistName)
        checkStatus()
    }

    // MARK: - Public API

    func toggle() {
        if isEnabled {
            disable()
        } else {
            enable()
        }
    }

    // MARK: - Private

    private func checkStatus() {
        isEnabled = FileManager.default.fileExists(atPath: plistURL.path)
    }

    private func enable() {
        let launchAgentsURL = plistURL.deletingLastPathComponent()
        do {
            try FileManager.default.createDirectory(
                at: launchAgentsURL,
                withIntermediateDirectories: true
            )
            let content = generatePlist()
            try content.write(to: plistURL, atomically: true, encoding: .utf8)
            isEnabled = true
        } catch {
            print("LaunchAtLoginManager: plist の書き込みに失敗しました: \(error)")
        }
    }

    private func disable() {
        do {
            try FileManager.default.removeItem(at: plistURL)
            isEnabled = false
        } catch {
            print("LaunchAtLoginManager: plist の削除に失敗しました: \(error)")
        }
    }

    private func executablePath() -> (isBundle: Bool, path: String) {
        let bundlePath = Bundle.main.bundlePath
        if bundlePath.hasSuffix(".app") {
            return (true, bundlePath)
        }
        return (false, ProcessInfo.processInfo.arguments[0])
    }

    private func generatePlist() -> String {
        let (isBundle, path) = executablePath()
        let programArguments: String
        if isBundle {
            programArguments = """
                        <string>/usr/bin/open</string>
                        <string>-a</string>
                        <string>\(path)</string>
            """
        } else {
            programArguments = """
                        <string>\(path)</string>
            """
        }
        return """
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
              "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <plist version="1.0">
            <dict>
                <key>Label</key>
                <string>com.posturetimer.launcher</string>
                <key>ProgramArguments</key>
                <array>
            \(programArguments)
                </array>
                <key>RunAtLoad</key>
                <true/>
                <key>KeepAlive</key>
                <false/>
            </dict>
            </plist>
            """
    }
}
