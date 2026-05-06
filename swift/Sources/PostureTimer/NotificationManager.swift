import Foundation
import UserNotifications

/// UNUserNotificationCenter を使った通知の許可要求・送信を担当するシングルトン。
final class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    /// 通知許可をシステムに要求する。初回起動時のみダイアログが表示される。
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound]
        ) { _, _ in }
    }

    /// macOS バナー通知を送信する。
    ///
    /// - Parameters:
    ///   - title: 通知タイトル。
    ///   - body: 通知本文。
    func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }
}
