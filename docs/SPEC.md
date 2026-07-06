# PostureTimer 仕様

## 概要
macOS のメニューバーに常駐する着座タイマーアプリ。
長時間座り続けを防ぎ、立ち/座りのリズムを記録する。

## 動作環境
- macOS 13.0 (Ventura) 以上

## 技術スタック
- SwiftUI
- `MenuBarExtra`（macOS 13+）: メニューバー常駐 UI
- `UNUserNotificationCenter`: 通知
- `Foundation.Timer` + `ObservableObject`: 状態管理・タイマー
- Carbon Hot Keys API: グローバルホットキー
- LaunchAgent (`launchd`): ログイン時の自動起動

## 機能一覧

### 1. メニューバー常駐
- 座り/立ちアイコン（🪑 / 🧍）と経過時間をリアルタイム表示
- 一時停止中は `⏸` アイコンに切り替わる

### 2. 座り/立ちの状態切り替え
- メニュークリックで切り替え
- グローバルホットキー `⌘⌃S` でも切り替え可能

### 3. 警告通知
- 座り続け / 立ち続けを検知して macOS バナー通知を発火
- 閾値は設定画面から変更可能（デフォルト 30 分）
- 繰り返し通知: 警告後も N 分ごとに再通知（デフォルト無効）

### 4. 一時停止・再開
- 一時停止: タイマーを停止、累計に影響しない
- 再開: 一時停止前の経過時間を引き継いで継続
- グローバルホットキー `⌘⌃P` で一時停止トグル

### 5. タイマーのリセット
- メニュー「リセット」で現在のセッション経過時間を `00:00` に戻す
- 姿勢（座り/立ち）と一時停止状態は維持する
- 座り/立ち警告の発火状態もクリアされ、次回の閾値到達で再度通知される

### 6. ログイン時の自動起動
- 設定画面の「ログイン時に起動」トグルで ON/OFF
- ON にすると `~/Library/LaunchAgents/com.posturetimer.launcher.plist` を生成
- `.app` バンドル実行時は `open -a` 経由、非バンドル（開発時）は実行バイナリパスを直接指定

## ファイル構成

```
posture-timer-app/
├── PostureTimer.xcodeproj            # Xcode プロジェクト
├── Assets.xcassets/                  # アプリアイコン (AppIcon.appiconset)
├── swift/Sources/PostureTimer/
│   ├── PostureTimerApp.swift         # @main エントリポイント
│   ├── Models.swift                  # PostureState, AppConfig, フォーマッタ
│   ├── TimerManager.swift            # タイマー・状態管理 ObservableObject
│   ├── NotificationManager.swift     # UNUserNotificationCenter ラッパー
│   ├── HotkeyManager.swift           # グローバルホットキー
│   ├── LaunchAtLoginManager.swift    # LaunchAgent plist 管理
│   ├── MenuBarView.swift             # メニューバー UI
│   └── SettingsViews.swift           # 設定画面 (一般 / 通知 / ショートカット)
├── .github/workflows/                # CI / Release ワークフロー
├── docs/                             # ドキュメント
├── assets/                           # アイコン素材 (icon.png 等)
├── Makefile                          # build / install / package / icon タスク
└── CHANGELOG.md
```

## データ保存先

```
UserDefaults   # 設定（sit_alert_minutes, stand_alert_minutes, repeat_interval_minutes, hotkey_config）
```

## 主要モジュール

### `TimerManager`
タイマー・状態管理の `ObservableObject`。
- 座り/立ち状態の保持と切り替え
- 経過時間の計算（一時停止期間を除外）
- 一時停止 / 再開
- タイマーのリセット（経過時間・警告状態のクリア）

### `NotificationManager`
`UNUserNotificationCenter` のラッパー。
- 起動時に通知許可をリクエスト
- 警告通知の発火（一度きり / 繰り返し対応）

### `HotkeyManager`
Carbon Hot Keys API でグローバルホットキーを登録。
- `⌘⌃S`: 座り/立ち切り替え
- `⌘⌃P`: 一時停止トグル

### `LaunchAtLoginManager`
`~/Library/LaunchAgents/com.posturetimer.launcher.plist` の生成・削除でログイン時自動起動を制御。

### `MenuBarView` / `SettingsViews`
SwiftUI による UI。
- メニューバーは `MenuBarExtra` で常駐
- 設定画面は「一般」「通知」「ショートカット」タブで構成

## 既知の挙動

- **通知が出ない場合**: システム設定 → 通知 → PostureTimer で「通知を許可」をオンにする
- **一時停止中の挙動**: 経過時間カウントが完全に止まり、停止期間は累計に含まれない

## ロードマップ

機能要望や提案は GitHub Issues を歓迎します。
