<p align="center">
<img height="256" src="https://github.com/iina/iina/raw/master/iina/Assets.xcassets/AppIcon.appiconset/1024-1.png" />
</p>

<h1 align="center">IINA+</h1>

<p align="center">IINA+ is a special build of the <b>modern</b> video player <a href="https://github.com/iina/iina">IINA</a> with additional features and bugfixes.</p>

---

## Features

* HDR playback
* Danmaku ( supports Bilibili only due to the limitation of `yt-dlp`, experimental ). I used some code from [iina-danmaku](https://github.com/xjbeta/iina-danmaku), Thanks [xjbeta](https://github.com/xjbeta)
* AppleScript. I used code from [Wevah's AppleScript support PR](https://github.com/iina/iina/pull/2857), Thanks [Wevah](https://github.com/Wevah)
* LOTS of bug fixes and performance improvements from [low-batt](https://github.com/iina-plus?type=source)

## About youtube-dl

We no longer embed the outdated youtube-dl. Users must install `yt-dlp` manually for playing network resources.

```sh
$ brew install yt-dlp
```

See [the official document](https://github.com/yt-dlp/yt-dlp#readme) for detail

## Build

Full build of IINA dependencies and IINA itself:
```bash
$ make
```

Build just the dependencies:
```bash
$ make depends
```

Build IINA itself:
```bash
$ make build
```

## Binaries

* Intel (x64): Download artifacts in <https://github.com/iina-plus/iina/actions>
* Apple M1 (aarch64): Download assets in <https://github.com/iina-plus/iina/releases>
