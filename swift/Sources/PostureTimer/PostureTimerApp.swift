import SwiftUI

@main
struct PostureTimerApp: App {
    @StateObject private var timerManager = TimerManager()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environmentObject(timerManager)
        } label: {
            Text(timerManager.menuBarTitle)
        }

        Window("PostureTimer 設定", id: "settings") {
            SettingsView()
                .environmentObject(timerManager)
        }
        .windowResizability(.contentSize)
    }
}
