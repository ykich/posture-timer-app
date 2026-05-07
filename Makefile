.PHONY: build install package icon clear-icon-cache help

APP_NAME      := PostureTimer
PROJECT       := $(APP_NAME).xcodeproj
SCHEME        := $(APP_NAME)
BUILD_DIR     := build
DEBUG_APP     := $(BUILD_DIR)/Build/Products/Debug/$(APP_NAME).app
RELEASE_APP   := $(BUILD_DIR)/Build/Products/Release/$(APP_NAME).app

## ターゲット一覧を表示する
help:
	@grep -E '^##' Makefile | sed 's/## //'

## Debug ビルドを実行する (build/Build/Products/Debug/)
build:
	xcodebuild \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-configuration Debug \
		-derivedDataPath $(BUILD_DIR)/ \
		build

## Release ビルドを zip 化する (アドホック署名、配布用 / dist/ 配下に出力)
package:
	xcodebuild \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-configuration Release \
		-derivedDataPath $(BUILD_DIR)/ \
		CODE_SIGN_IDENTITY="-" \
		CODE_SIGNING_REQUIRED=NO \
		CODE_SIGNING_ALLOWED=NO \
		build
	mkdir -p dist
	ditto -c -k --keepParent $(RELEASE_APP) dist/$(APP_NAME).zip
	@echo "パッケージ作成完了: dist/$(APP_NAME).zip"

## Debug ビルドを /Applications/ へインストールする
install: build
	@if [ ! -d "$(DEBUG_APP)" ]; then \
		echo "エラー: ビルドが見つかりません: $(DEBUG_APP)"; \
		exit 1; \
	fi
	rm -rf /Applications/$(APP_NAME).app
	cp -R "$(DEBUG_APP)" /Applications/
	@echo "インストール完了: /Applications/$(APP_NAME).app"

## アイコン (iconset + icns) を再生成する
icon:
	rm -rf assets/PostureTimer.iconset
	mkdir assets/PostureTimer.iconset
	sips -z 16   16   assets/icon.png --out assets/PostureTimer.iconset/icon_16x16.png
	sips -z 32   32   assets/icon.png --out assets/PostureTimer.iconset/icon_16x16@2x.png
	sips -z 32   32   assets/icon.png --out assets/PostureTimer.iconset/icon_32x32.png
	sips -z 64   64   assets/icon.png --out assets/PostureTimer.iconset/icon_32x32@2x.png
	sips -z 128  128  assets/icon.png --out assets/PostureTimer.iconset/icon_128x128.png
	sips -z 256  256  assets/icon.png --out assets/PostureTimer.iconset/icon_128x128@2x.png
	sips -z 256  256  assets/icon.png --out assets/PostureTimer.iconset/icon_256x256.png
	sips -z 512  512  assets/icon.png --out assets/PostureTimer.iconset/icon_256x256@2x.png
	sips -z 512  512  assets/icon.png --out assets/PostureTimer.iconset/icon_512x512.png
	sips -z 1024 1024 assets/icon.png --out assets/PostureTimer.iconset/icon_512x512@2x.png
	iconutil -c icns assets/PostureTimer.iconset -o assets/PostureTimer.icns
	@echo "アイコン生成完了: assets/PostureTimer.icns"

## Finder のアイコンキャッシュをクリアする
clear-icon-cache:
	killall Finder
