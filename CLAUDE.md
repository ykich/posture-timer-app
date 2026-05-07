# CLAUDE.md

このファイルは、このリポジトリで作業する際の Claude Code に関するガイダンスを提供します。

---

## プロジェクト概要

macOS のメニューバーに常駐する着座タイマーアプリ。SwiftUI + `MenuBarExtra` による macOS ネイティブ実装。

詳細は `docs/SPEC.md` を参照してください。

## ⛔ 絶対に守るルール

- **絶対に** `main` ブランチへ直接プッシュしないこと — 常に Pull Request を作成してください
- Pull Requestは、ISSUEと紐づけること。ない場合はPull Request作成前にISSUEを作成すること
- 機能を追加・更新する場合は、新しいISSUEを作成すること
- 機能を追加・更新する場合は、新しいブランチを作成すること
- 機能を追加・更新したら`docs/`のドキュメントも更新すること

### ブランチ命名規則

```
feat/<issue番号>-<name>   # 新機能
fix/<issue番号>-<name>    # バグ修正
refactor/<issue番号>-<name> # リファクタリング
docs/<issue番号>-<name>   # ドキュメントのみの変更
```

例: `feat/42-un-notification`, `fix/17-menu-bar-crash`

### コミット前チェック

コミット前に必ず以下を実行してビルドエラーがないことを確認すること:

```bash
make build
# または Xcode で Cmd+B
```

---

## Swift コーディング規約

- SwiftUI + `MenuBarExtra` を使用
- `@MainActor` で UI 更新を保証
- イミュータブルな値型（`struct`）を優先
- ファイルは機能単位で分割（`Models.swift`, `TimerManager.swift` など）

---

## 関連ドキュメント一覧

| ファイル | 説明 |
| --- | --- |
| docs/SPEC.md | アプリ仕様・機能構想の引き継ぎコンテキスト |
| docs/RUNBOOK.md | ビルド・運用ガイド(Xcode セットアップ、起動手順、リリース手順) |
| docs/SIT_STAND_RESEARCH.md | 座り・立ちのバランスに関する研究まとめ(タイマー間隔の根拠) |
| CHANGELOG.md | 変更履歴(Keep a Changelog 形式) |
