class Openmsx < Formula
  desc "MSX emulator"
  homepage "https://openmsx.org/"
  url "https://github.com/openMSX/openMSX/releases/download/RELEASE_20_0/openmsx-20.0.tar.gz"
  sha256 "4c645e5a063e00919fa04720d39f62fb8dcb6321276637b16b5788dea5cd1ebf"
  license "GPL-2.0-or-later"
  head "https://github.com/openMSX/openMSX.git", branch: "master"

  livecheck do
    url :stable
    regex(/RELEASE[._-]v?(\d+(?:[._]\d+)+)/i)
    strategy :github_latest do |json, regex|
      match = json["tag_name"]&.match(regex)
      next if match.blank?

      match[1].tr("_", ".")
    end
  end

  bottle do
    sha256 cellar: :any,                 arm64_sequoia: "79b26f0bc081f8b8974e162246116bffdcbd0b6221fdab1e2e1dec4e4a845ebe"
    sha256 cellar: :any,                 arm64_sonoma:  "b591ec9b4206114bc22294ec7efcab63064fda6232b49aea074bf151907581b4"
    sha256 cellar: :any,                 arm64_ventura: "2244a38af42b9cbf7cdf6f5a2a52b54bf37bc9557de622d461dccc7b9920ddb5"
    sha256 cellar: :any,                 sonoma:        "67024fa6b9d9568053cb3c712d89f1bf336e5e39e1d21335e7ea36652524a598"
    sha256 cellar: :any,                 ventura:       "b25732b1cd38a2354146f923b7737fa47f9a217fcf3bcb254bab35e1b065282a"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "9760971e0edbb18c0aa386bd5a3fcacb2b99bad467aaf66b52184c809e5c77dd"
  end

  depends_on "freetype"
  depends_on "glew"
  depends_on "libogg"
  depends_on "libpng"
  depends_on "libvorbis"
  depends_on "sdl2"
  depends_on "sdl2_ttf"
  depends_on "theora"

  uses_from_macos "python" => :build
  uses_from_macos "zlib"

  on_ventura :or_older do
    depends_on "llvm" => :build

    fails_with :clang do
      cause "Requires C++20"
    end
  end

  on_linux do
    depends_on "alsa-lib"
    depends_on "mesa"
    depends_on "tcl-tk@8"
  end

  fails_with :gcc do
    version "7"
    cause "Requires C++20"
  end

  def install
    ENV.llvm_clang if OS.mac? && MacOS.version <= :ventura

    # Hardcode prefix
    inreplace "build/custom.mk", "/opt/openMSX", prefix
    inreplace "build/probe.py", "platform == 'darwin'", "platform == 'linux'" if OS.linux?
    inreplace "build/probe.py", "/usr/local", HOMEBREW_PREFIX

    # Help finding Tcl (https://github.com/openMSX/openMSX/issues/1082)
    ENV["TCL_CONFIG"] = OS.mac? ? MacOS.sdk_path/"System/Library/Frameworks/Tcl.framework" : Formula["tcl-tk@8"].lib

    system "./configure"
    system "make", "CXX=#{ENV.cxx}"

    if OS.mac?
      prefix.install Dir["derived/**/openMSX.app"]
      bin.write_exec_script "#{prefix}/openMSX.app/Contents/MacOS/openmsx"
    else
      system "make", "install"
    end
  end

  test do
    system bin/"openmsx", "-testconfig"
  end
end
