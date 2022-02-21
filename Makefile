.PHONY: all
all: depends build

.PHONY: build
build: clean archive dmg

.PHONY: depends
depends:
	git submodule update --init --progress
	cp homebrew-mpv-iina/other/* other/

	# Make brew use our IINA FFmpeg and mpv formulas.
	cp homebrew-mpv-iina/*-iina.rb "$(shell brew --repo homebrew/core)/Formula"
	# Brew will build for the macOS version running on the local machine.
	brew install --build-from-source ffmpeg-iina mpv-iina

	rm -rf deps/include && mkdir -p deps/include
	cp -R "$(shell brew --prefix ffmpeg-iina)/include/"* "$(shell brew --prefix mpv-iina)/include/mpv" deps/include/
	/usr/bin/ruby other/change_lib_dependencies.rb "$(shell brew --prefix)" "$(shell brew --prefix mpv-iina)/lib/libmpv.dylib"

	# Generate MPVCommand.swift, MPVOption.swift and MPVProperty.swift by parsing current mpv documentation.
	/usr/bin/ruby other/parse_doc.rb
	# The script drops the generated sources in the "other" directory. Move them to the source directory.
	mv other/MPVCommand.swift other/MPVOption.swift other/MPVProperty.swift iina/

.PHONY: archive
archive:
	xcodebuild -project iina.xcodeproj -scheme iina -config Release -archivePath ./archive archive

.PHONY: dmg
dmg:
	create-dmg --app-drop-link 0 0 iina.dmg ./archive.xcarchive/Products/Applications/IINA.app

.PHONY: clean
clean:
	rm -rf archive.xcarchive iina.dmg
