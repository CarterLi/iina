#!/usr/bin/env ruby

require "fileutils"

include FileUtils::Verbose

$compile_deps = !$*.find_index("--no-deps")
$only_setup = $*.find_index("--setup-env")
$patch_python = $*.find_index("--patch-python")

arch = %x[arch].chomp
$homebrew_patch = if arch == "arm64"
                    "homebrew_arm.patch"
                  else
                    "homebrew_x86.patch"
                  end
$current_dir = "#{`pwd`.chomp}"
$homebrew_path = "#{`brew --repository`.chomp}/"

# system "brew tap iina/mpv-iina"

def install(package)
  system "brew reinstall #{package} --build-from-source"
end

def fetch(package)
  system "brew fetch -s #{package}"
end

def setup_rb(package)
  system "sd 'def install' 'def install\n\tENV[\"CFLAGS\"] = \"-mmacosx-version-min=10.11\"\n\tENV[\"LDFLAGS\"] = \"-mmacosx-version-min=10.11\"\n\tENV[\"CXXFLAGS\"] = \"-mmacosx-version-min=10.11\"\n' $(brew edit --print-path #{package})"
end

def setup_env
  ENV["HOMEBREW_NO_AUTO_UPDATE"] = "1"
  ENV["HOMEBREW_NO_INSTALL_UPGRADE"] = "1"
  FileUtils.cd $homebrew_path
  system "git reset --hard HEAD"
  print "Applying Homebrew patch (MACOSX_DEPLOYMENT_TARGET & oldest CPU)\n"
  system "git apply #{$current_dir}/#{$homebrew_patch}"
end

def patch_python
  file_path = "#{`brew --prefix python`.chomp}/Frameworks/Python.framework/Versions/3.9/lib/python3.9/distutils/spawn.py"
  lines = File.readlines(file_path)
  lines.filter! { |line| !line.end_with?("raise DistutilsPlatformError(my_msg)\n") }
  File.open(file_path, 'w') { |file| file.write lines.join }
end

def reset
  return if $only_setup
  FileUtils.cd $homebrew_path
  system "git reset --hard HEAD"
end

begin
  if $patch_python
    patch_python
    return
  end
  setup_env
  return if $only_setup
  if arch != "arm64" 
    pkgs = ["rubberband", "libpng", "luajit-openresty", "glib"]
    pkgs.each do |dep|
      setup_rb dep
    end
    print "#{pkgs} rb files prepared\n"
  end

  deps = "#{`brew deps mpv-iina -n`}".split("\n")
  total = deps.length + 1

  deps.each do |dep|
    fetch dep
  end
  fetch "mpv-iina"
  print "\n#{total} fetched\n"

  if $compile_deps
    print "#{total} packages to be compiled\n"

    deps.each do |dep|
      print "\nCompiling #{dep}\n"
      install dep
      total -= 1
      print "------------------------\n"
      print "#{dep} has been compiled\n"
      print "#{total} remained\n"
      print "------------------------\n"
      if dep.start_with?("python")
        patch_python
      end
    end
  end

  install "mpv-iina"

ensure
  reset
end
