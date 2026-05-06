# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [1.0.0] - 2026-05-06

Initial public release.

### Added
- メニューバー常駐表示（座り 🪑 / 立ち 🧍 / 一時停止 ⏸ アイコンと経過時間）
- 座り / 立ち状態切り替え（メニュークリックまたはグローバルホットキー）
- 一時停止 / 再開機能
- 座り続け / 立ち続け警告通知（繰り返し再通知の間隔設定対応、`UNUserNotificationCenter`）
- カスタマイズ可能なグローバルホットキー（既定 `⌘⌃S`: 状態切替 / `⌘⌃P`: 一時停止）
- ログイン時自動起動（LaunchAgent plist 連携）
- 設定画面（一般 / 通知 / ショートカット タブ）
- GitHub Actions による CI / Release ワークフロー
- `Makefile` による開発用タスクの一元管理（`make install` / `make icon` / `make clear-icon-cache`）
