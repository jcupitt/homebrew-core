class Primecount < Formula
  desc "Fast prime counting function program and C/C++ library"
  homepage "https://github.com/kimwalisch/primecount"
  url "https://github.com/kimwalisch/primecount/archive/refs/tags/v7.16.tar.gz"
  sha256 "437cde8198fbfed3a16510786d99edb22da2766f0f0376450690d55a74ea5cf3"
  license "BSD-2-Clause"

  bottle do
    sha256 cellar: :any,                 arm64_sequoia: "406b6a839c6edad4fee9430108e5d79e37d6db5cc719715f0407fed8916b159b"
    sha256 cellar: :any,                 arm64_sonoma:  "264457b902ac21e616509f9a33ed58e3feea73d2ae444ad065bcd765afae1a40"
    sha256 cellar: :any,                 arm64_ventura: "ed3dfd79edc41fa41be840a98237fe94495dda976ccb90d7a53207e2b8f590a1"
    sha256 cellar: :any,                 sonoma:        "91faa21de46dd2acc82b8eb74c294fe9110b9483ea2856165a27a387851baada"
    sha256 cellar: :any,                 ventura:       "7e3debfc6fedb1d420dd7058796d069ea30aa1cadf925f6d17b2d657683cfbc6"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "b970dbda21ebdb145cee32d8b21da94598dec53590b7198a135443bd97707f17"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "d7ae0746641bc8daa469371549a5c7ef3e4013e9f539a25728d32e9209712471"
  end

  depends_on "cmake" => :build
  depends_on "primesieve"

  on_macos do
    depends_on "libomp"
  end

  def install
    system "cmake", "-S", ".", "-B", "build", "-DBUILD_SHARED_LIBS=ON",
                                              "-DBUILD_LIBPRIMESIEVE=OFF",
                                              "-DCMAKE_INSTALL_RPATH=#{rpath}",
                                              *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    assert_equal "37607912018\n", shell_output("#{bin}/primecount 1e12")
  end
end
