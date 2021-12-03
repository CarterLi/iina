# Last check with upstream: 5ef3900b6178dee40629e3e058a587ef196b53b1
# https://github.com/Homebrew/homebrew-core/blob/master/Formula/ffmpeg.rb

class FfmpegIina < Formula
  desc "Play, record, convert, and stream audio and video"
  homepage "https://ffmpeg.org/"
  url "https://ffmpeg.org/releases/ffmpeg-4.4.1.tar.xz"
  sha256 "eadbad9e9ab30b25f5520fbfde99fae4a92a1ae3c0257a8d68569a4651e30e02"
  head "https://github.com/FFmpeg/FFmpeg.git"

  patch do
    url "https://github.com/FFmpeg/FFmpeg/commit/1d23e125b6f76e74b754560c3b6931507cacddce.patch"
    sha256 "c530212cd56b2086b4ad2d10d18509ea419f2561758859323a54a2cda5161be7"
  end

  keg_only <<EOS
it is intended to only be used for building IINA.
This formula is not recommended for daily use and has no binaraies (ffmpeg, ffplay etc.)
EOS

  depends_on "nasm" => :build
  depends_on "pkg-config" => :build
  depends_on "dav1d"
  depends_on "openssl@3"
  depends_on "xz"

  uses_from_macos "bzip2"
  uses_from_macos "zlib"

  def install

    args = %W[
      --prefix=#{prefix}
      --enable-shared
      --enable-pthreads
      --enable-version3
      --cc=#{ENV.cc}
      --host-cflags=#{ENV.cflags}
      --host-ldflags=#{ENV.ldflags}
      --enable-gpl
      --enable-openssl
      --enable-lto
      --enable-libdav1d
      --enable-videotoolbox
      --disable-debug
      --disable-doc
      --disable-libjack
      --disable-indev=jack
      --disable-programs
    ]

    system "./configure", *args
    system "make", "install"

    # Build and install additional FFmpeg tools
    system "make", "alltools"
    bin.install Dir["tools/*"].select { |f| File.executable? f }

    # Fix for Non-executables that were installed to bin/
    mv bin/"python", pkgshare/"python", force: true
  end

  test do
    # Create an example mp4 file
    mp4out = testpath/"video.mp4"
    system bin/"ffmpeg", "-filter_complex", "testsrc=rate=1:duration=1", mp4out
    assert_predicate mp4out, :exist?
  end
end
