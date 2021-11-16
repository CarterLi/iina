depends:
	brew install --build-from-source ffmpeg-iina
	brew install --build-from-source mpv-iina
	rm -rf deps/include/mpv
	cp -r "$(shell brew --prefix mpv-iina)/include/mpv" deps/include/
	/usr/bin/ruby other/parse_doc.rb
	/usr/bin/ruby other/change_lib_dependencies.rb "$(shell brew --prefix)" "$(shell brew --prefix mpv-iina)/lib/libmpv.dylib"

archive:
	xcodebuild -project iina.xcodeproj -scheme iina -config Release -archivePath ./archive archive

dmg:
	create-dmg iina.dmg ./archive.xcarchive/Products/Applications/IINA.app

clean:
	rm -rf archive.xcarchive iina.dmg
