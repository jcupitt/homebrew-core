class Vipsdisp < Formula
  desc "Image viewer"
  homepage "https://github.com/jcupitt/vipsdisp"
  url "https://github.com/jcupitt/vipsdisp/archive/refs/tags/v2.5.1.tar.gz"
  sha256 "1315c45f76caa12c5efd878278141ebbaaa635ca1f8ad3dbf0031a41d7aace6b"
  license "MIT"

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build

  depends_on "gtk4"
  depends_on "hicolor-icon-theme"
  depends_on "vips"

  def install
    # ensure that we don't run the meson post install script
    ENV["DESTDIR"] = "/"

    mkdir "build" do
      system "meson", *std_meson_args, ".."
      system "ninja"
      system "ninja", "install"
    end
  end

  def post_install
    system "#{Formula["glib"].opt_bin}/glib-compile-schemas", "#{HOMEBREW_PREFIX}/share/glib-2.0/schemas"
    system "#{Formula["gtk4"].opt_bin}/gtk4-update-icon-cache", "-f", "-t", "#{HOMEBREW_PREFIX}/share/icons/hicolor"
  end

  test do
    system bin/"vipsdisp", "--help"
  end
end
