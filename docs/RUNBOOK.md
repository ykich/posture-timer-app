# ビルド・運用ガイド

## 前提条件

- macOS 13.0 (Ventura) 以上
- Xcode 15 以上

---

## 通知許可について

PostureTimer は初回起動時に macOS の通知許可ダイアログを表示する。

- **初回起動時**: 「許可」を選択すること
- **許可し忘れた場合**: システム設定 → 通知 → PostureTimer → 「通知を許可」をオンにする

---

## Swift 版のビルド

Swift 版ソースは `swift/` ディレクトリに格納されている。
`swift build` ではアプリバンドル（.app）を生成できないため、Xcode でのビルドが必要。

### Xcode プロジェクト初期セットアップ（初回のみ）

1. Xcode を起動 → File > New > Project > macOS > App
2. 以下を設定:
   - Product Name: `PostureTimer`
   - Interface: SwiftUI
   - Language: Swift
3. 自動生成された `ContentView.swift` 等を削除
4. `swift/Sources/PostureTimer/` 以下の全 `.swift` ファイルを**参照として**追加（下記参照）
5. ターゲット設定:
   - General > Supported Destinations に「Mac」を追加（iOS は削除）
   - Deployment Target: macOS 13.0
   - Signing: Automatically manage signing（Team に Apple ID を設定）
6. `Info.plist` に `LSUIElement = YES` を追加（Dock アイコン非表示）

#### ソースファイルの参照追加

ファイルをコピーせず参照として追加することで、リポジトリの編集が即座に Xcode に反映される。

1. Xcode のメニュー **File > Add Files to "PostureTimer"...** を開く
2. `swift/Sources/PostureTimer/` 内のすべての `.swift` ファイルを選択
3. Action: 「Reference files in place」を選択する
4. **Add** をクリック

> すでにコピーしてしまった場合は、プロジェクトナビゲーターで該当ファイルを Delete →
> 「Remove Reference」を選んだあと、上記手順で再追加する。

### アプリアイコンの設定

通知や Finder に表示されるアイコンを設定する。

#### 1. アイコン画像を用意する

1024×1024 px の PNG を1枚用意する。`assets/icon.png` を流用可能。

#### 2. Assets.xcassets に AppIcon を追加する

1. Xcode のプロジェクトナビゲーターで `Assets.xcassets` を選択
   - 存在しない場合は **File > New > File > Asset Catalog** で作成
2. 左下の **「+」** → **App Icons and Launch Images > New macOS App Icon** を選択
3. `Mac 512pt 2x`（1024×1024）欄に PNG をドラッグ＆ドロップ

#### 3. Build Settings を確認する

**TARGETS > Build Settings > Asset Catalog Compiler** の
`Primary App Icon Set Name` が `AppIcon` になっていることを確認する。

### ビルド・実行

```bash
# Xcode GUI でビルド
Cmd + B   # ビルドのみ
Cmd + R   # ビルド + 実行
```

### Applications へのインストール

```bash
make install
```

> Xcode でビルド（Cmd+B）済みであることが前提。ビルドが見つからない場合はエラーが表示される。

---

## アイコンの作り直し

`assets/icon.png` を変更した後、以下のコマンドで iconset と icns を再生成する。

```bash
make icon
```

> `icon.png` は 1024x1024 以上を推奨。

---

## Finder のアイコンキャッシュをクリア

アイコンが古いまま表示される場合：

```bash
make clear-icon-cache
```

---

## リリース（GitHub Release の作成）

`v*` タグをプッシュすると GitHub Actions が自動でリリースを作成する。

### 手順

1. `CHANGELOG.md` の `[Unreleased]` セクションに変更内容を記載済みであることを確認
2. `CHANGELOG.md` の `[Unreleased]` を新バージョンに書き換え（日付を追記）
3. コミットしてタグを作成・プッシュ

```bash
git tag v1.1.0
git push origin v1.1.0
```
