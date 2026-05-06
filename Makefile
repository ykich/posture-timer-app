.PHONY: install icon clear-icon-cache help

DERIVED_DATA := $(HOME)/Library/Developer/Xcode/DerivedData
APP_NAME     := PostureTimer
DEBUG_APP    := $(shell echo $(DERIVED_DATA)/$(APP_NAME)-*/Build/Products/Debug/$(APP_NAME).app)

## ターゲット一覧を表示する
help:
	@grep -E '^##' Makefile | sed 's/## //'

## Debug ビルドを /Applications/ へインストールする
install:
	@if [ ! -d "$(DEBUG_APP)" ]; then \
		echo "エラー: ビルドが見つかりません。先に Xcode でビルドしてください (Cmd+B)"; \
		exit 1; \
	fi
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
