# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- **タイマーのリセット機能** — メニュー「リセット」で現在のセッション経過時間を `00:00` に戻す。
  姿勢（座り/立ち）と一時停止状態は維持し、座り/立ち警告の発火状態もクリアする

## [1.1.0] - 2026-05-07

### Added
- **配布版 `.app.zip` を GitHub Release に自動添付**(タグ push で `xcodebuild` → アドホック署名 → ditto による zip 化 → リリースに添付)
- `make build` / `make package` ターゲット(Debug ビルド / Release ビルド + zip 化)
- 配布版 `.app` の post-build アドホック署名(`codesign --force --deep --sign -`)。
  リンカ最小署名のままだと Gatekeeper に「壊れている」と判定されるため、
  明示的な署名を再適用してリソース封印と Info.plist のバインドを確立

### Changed
- Xcode プロジェクト (`PostureTimer.xcodeproj`) と `Assets.xcassets` をリポジトリに統合(リポジトリ単独で再現可能なビルド環境に)
- CI / Release ワークフローを `swift build` から `xcodebuild` ベースに変更
- `make install` のビルド出力参照を DerivedData からリポジトリ内 `build/` に変更
- README にダウンロード版の初回起動手順(右クリック→開く による Gatekeeper 回避)を追記
- `docs/RUNBOOK.md` をリポジトリ統合後の手順に更新

### Removed
- `swift/Package.swift` および SwiftPM 関連ファイル(`swift/README.md`、`swift/Sources/PostureTimer/Resources/AppIcon.icns`、`swift/assets/`)。Xcode プロジェクトに一本化

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
