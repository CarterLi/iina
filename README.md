<p align="center">
<img height="256" src="https://github.com/iina/iina/raw/master/iina/Assets.xcassets/AppIcon.appiconset/1024-1.png" />
</p>

<h1 align="center">IINA+</h1>

<p align="center">IINA+ is a special build of the <b>modern</b> video player <a href="https://github.com/iina/iina">IINA</a> with additional features and bugfixes.</p>

---

## Features

* HDR playback
* Danmaku ( supports Bilibili only due to the limitation of `yt-dlp`, experimental )

## About youtube-dl

We no longer embed the outdated youtube-dl. Users must install `yt-dlp` manually for playing network resources.

```sh
$ brew install yt-dlp
```

## Build

```bash
$ cp other/*-iina.rb $(brew --repo homebrew/core)/Formula # Copy custom mpv and ffmpeg formula into homebrew repo
$ make depends # Build dependencies
$ make build # Build iina itself
```

## Binaries

* Intel (x64): Download artifacts in <https://github.com/iina-plus/iina/actions>
* Apple M1 (aarch64): Download assets in <https://github.com/iina-plus/iina/releases>
