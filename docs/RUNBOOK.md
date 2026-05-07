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

## ソースからのビルド

リポジトリをクローン後、Xcode プロジェクトを直接開く。

```bash
git clone https://github.com/ykich/posture-timer-app.git
cd posture-timer-app
open PostureTimer.xcodeproj
```

### Xcode GUI でビルド・実行

```text
Cmd + B   # ビルドのみ
Cmd + R   # ビルド + 実行
```

### コマンドラインからのビルド

```bash
make build       # Debug ビルド (build/Build/Products/Debug/PostureTimer.app)
make package     # Release ビルド + zip 化 (dist/PostureTimer.zip)
```

### `/Applications/` へのインストール

```bash
make install
```

`make install` は内部で `make build` を実行してから `/Applications/` にコピーする。

---

## ダウンロード版の初回起動について

GitHub Releases から取得した配布版 `.app` は Apple Developer Program での公証 (notarization) を
行っていない (アドホック署名のみ)。そのため、ダウンロード時に macOS が付与する
`com.apple.quarantine` 属性により Gatekeeper の警告が表示される。

macOS のバージョンにより表示は異なる:

- **macOS Sequoia (15) 以降**:

  > "PostureTimer.app" は開いていません
  > Apple は、"PostureTimer.app" に Mac に損害を与えたり、プライバシーを侵害する可能性のあるマルウェアが含まれていないことを検証できませんでした。

  → 「ゴミ箱に入れる」「完了」のボタンしか出ず、ダイアログから直接「開く」を選べない。

- **macOS Sonoma (14) 以前**:

  > "PostureTimer.app" は壊れているため開けません。

  → 同様にダイアログから直接「開く」を選べない (Apple Silicon Mac では特にこの傾向)。

起動するには下記いずれかの方法で許可する。一度許可すれば、次回以降は通常のダブルクリックで起動できる。

### 方法 A: システム設定から許可する (GUI 操作・推奨)

1. アプリを一度ダブルクリックして警告ダイアログを表示させる
2. ダイアログの **「完了」** をクリック
3. **システム設定 → プライバシーとセキュリティ** を開く
4. 画面を一番下までスクロールすると「"PostureTimer.app" は開発元が確認できないためブロックされました」のメッセージと **「このまま開く」** ボタンがある
5. **「このまま開く」** をクリック → 管理者パスワード入力 → 「開く」を選択

### 方法 B: ターミナルで隔離属性を削除する (上級者向け)

ダブルクリックする前に、ターミナルで以下を実行する:

```bash
xattr -cr /Applications/PostureTimer.app
```

`com.apple.quarantine` 属性が削除され、警告ダイアログを経ずにダブルクリックで起動できる。

### 補助手段: 右クリック → 開く

Intel Mac の旧 macOS など環境によっては、アイコンを右クリック → 「開く」 → ダイアログで「開く」を選択することで起動できる場合がある。
ただし macOS Sequoia 以降や Apple Silicon Mac では、警告ダイアログから「開く」を選べない仕様になっているため上記方法 A または B を使うこと。

---

## アプリアイコン

アプリアイコンは `Assets.xcassets/AppIcon.appiconset/` に格納されている。
Xcode プロジェクトの **TARGETS > Build Settings > Asset Catalog Compiler** の
`Primary App Icon Set Name` で `AppIcon` を参照している。

### アイコン画像の差し替え

`assets/icon.png` を新しい画像に差し替えた後、以下のコマンドで `Assets.xcassets` 用の
各サイズ画像と `assets/PostureTimer.icns` を再生成する。

```bash
make icon
```

> `icon.png` は 1024×1024 以上を推奨。
> 生成された `assets/PostureTimer.iconset/*.png` を `Assets.xcassets/AppIcon.appiconset/` に
> 適切に配置する必要がある(Xcode の Assets エディタからドラッグ&ドロップが簡単)。

### Finder のアイコンキャッシュをクリア

アイコンが古いまま表示される場合:

```bash
make clear-icon-cache
```

---

## リリース (GitHub Release の作成)

`v*` タグをプッシュすると GitHub Actions が自動でビルド・パッケージング・ドラフトリリースの作成を行う。

### 手順

1. `CHANGELOG.md` に新バージョンのエントリを追加(`[X.Y.Z] - YYYY-MM-DD` 形式)
2. 変更をコミットして main にマージ
3. タグを作成・プッシュ

```bash
git tag v1.1.0
git push origin v1.1.0
```

4. GitHub Actions が完了するとドラフトリリースが作成される
5. リリースページで内容を確認のうえ、ドラフトを公開する

```bash
gh release edit v1.1.0 --draft=false --latest
```

### 自動添付されるアセット

- `dist/PostureTimer-vX.Y.Z.zip` — アドホック署名済みの `.app` バンドル(zip)

> CI 環境ではコード署名と公証は行わない(個人開発前提)。
> 配布先のユーザーには README に記載した「右クリック → 開く」の手順を案内する。
