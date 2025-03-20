class Makensis < Formula
  desc "System to create Windows installers"
  homepage "https://nsis.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/nsis/NSIS%203/3.11/nsis-3.11-src.tar.bz2"
  sha256 "19e72062676ebdc67c11dc032ba80b979cdbffd3886c60b04bb442cdd401ff4b"
  license "Zlib"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia:  "d5198ddb8f17e70b6804b1622d67d2c754b836b7e16f8cd44b0a22a639e3e82e"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "c74338c424627cfab6d21fa5d3ce53bc39d641f10b0a3150322943e32c422b35"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "fe5df7005bbb4cf75e23485a9810b3c8e5139441db9442dc2022216a0b019d4f"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "ccbda3098670472ecc0c5fa2d1e364b49ce361fb642d3ec13b88f31a23ee8740"
    sha256 cellar: :any_skip_relocation, sonoma:         "fc8db0474581a68a3393de4494c79f738cfcf7fdbd293e7be373196139b21656"
    sha256 cellar: :any_skip_relocation, ventura:        "241bfaef69832fed9d6200be45bb05608750180702697c261a1eea6db3606a7f"
    sha256 cellar: :any_skip_relocation, monterey:       "087967b7c39a1e0c6ddb70c197bc9ccc0bcce13fa52190e0f7ec87ca8511dafd"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "5fd35ae601106c7530eb53aaf72dcb3bf3553ec52b19e33e2f6944aec8481b3f"
  end

  depends_on "mingw-w64" => :build
  depends_on "scons" => :build

  uses_from_macos "zlib"

  resource "nsis" do
    url "https://downloads.sourceforge.net/project/nsis/NSIS%203/3.11/nsis-3.11.zip"
    sha256 "c7d27f780ddb6cffb4730138cd1591e841f4b7edb155856901cdf5f214394fa1"

    livecheck do
      formula :parent
    end
  end

  def install
    if OS.linux?
      ENV.append_to_cflags "-I#{Formula["zlib"].opt_include}"
      ENV.append "LDFLAGS", "-Wl,-rpath,#{rpath}"
    end

    args = [
      "CC=#{ENV.cc}",
      "CXX=#{ENV.cxx}",
      "PREFIX=#{prefix}",
      "PREFIX_DOC=#{share}/nsis/Docs",
      "SKIPUTILS=Makensisw,NSIS Menu,zip2exe",
      # Don't strip, see https://github.com/Homebrew/homebrew/issues/28718
      "STRIP=0",
      "VERSION=#{version}",
      # Scons dependency disables superenv in brew
      "APPEND_CCFLAGS=#{ENV.cflags}",
      "APPEND_LINKFLAGS=#{ENV.ldflags}",
    ]

    system "scons", "makensis", *args
    bin.install "build/urelease/makensis/makensis"
    (share/"nsis").install resource("nsis")
  end

  test do
    # Workaround for https://sourceforge.net/p/nsis/bugs/1165/
    ENV["LANG"] = "en_GB.UTF-8"
    %w[COLLATE CTYPE MESSAGES MONETARY NUMERIC TIME].each do |lc_var|
      ENV["LC_#{lc_var}"] = "en_GB.UTF-8"
    end

    system bin/"makensis", "-VERSION"
    system bin/"makensis", "#{share}/nsis/Examples/bigtest.nsi", "-XOutfile /dev/null"
  end
end
