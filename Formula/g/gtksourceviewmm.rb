class Gtksourceviewmm < Formula
  desc "C++ bindings for gtksourceview"
  homepage "https://gitlab.gnome.org/GNOME/gtksourceviewmm"
  url "https://download.gnome.org/sources/gtksourceviewmm/2.10/gtksourceviewmm-2.10.3.tar.xz"
  sha256 "0000df1b582d7be2e412020c5d748f21c0e6e5074c6b2ca8529985e70479375b"
  license "LGPL-2.1-or-later"
  revision 12

  bottle do
    sha256 cellar: :any,                 arm64_sonoma:   "73d0225ed243ebac279710392bb6f286d709f9934b3f44ca691e7dc591a35e4e"
    sha256 cellar: :any,                 arm64_ventura:  "420a7b698a8d7c40b3c30f4720c0c065e3ee71cda8542a517ae8aea3a3cbccbd"
    sha256 cellar: :any,                 arm64_monterey: "2735fdddc92f3280188428fc9fa83431a700c376bcae4424bca10005dd440c76"
    sha256 cellar: :any,                 arm64_big_sur:  "2b73a79e4c0df491e43dcc3def52858679c0d0ff699c3bb8a003014a7940408b"
    sha256 cellar: :any,                 sonoma:         "7b9bd3d4532700ded7178c931719fd142c0aebae9b5ab81ddde830969ae29a61"
    sha256 cellar: :any,                 ventura:        "32ba822ec6c84be6a8848adbddfa727fae43613c710a07b9e64a2e5c579ea7f6"
    sha256 cellar: :any,                 monterey:       "337b822adee8ddec4bb8f9f045f10cdb5e624c35fd1bf58aaaa1ab860af3cd73"
    sha256 cellar: :any,                 big_sur:        "cb0781be44de07c6b920d97337eeca3650d9ffc03d99cb0ac0e9da7cf2769b0c"
    sha256 cellar: :any,                 catalina:       "d6bd00f9f409660e55085ad15802c9e9b1f5f85d8600a729da0c81e3e79cd9d2"
    sha256 cellar: :any,                 mojave:         "5c11aa110b1c22269ddc3a2ad31752c02b6522c8310db0367dd7f112b62e0b1f"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "cc5638fa500ed70f1de07180a729cee705fd3683305dabd4176f899bc7dfc17b"
  end

  # GTK 2 is EOL: https://blog.gtk.org/2020/12/16/gtk-4-0/
  disable! date: "2024-01-21", because: :unmaintained

  depends_on "pkg-config" => [:build, :test]
  depends_on "gtkmm"
  depends_on "gtksourceview"

  def install
    ENV.cxx11
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <gtksourceviewmm.h>

      int main(int argc, char *argv[]) {
        gtksourceview::init();
        return 0;
      }
    CPP
    ENV.libxml2
    command = "#{Formula["pkg-config"].opt_bin}/pkg-config --cflags --libs gtksourceviewmm-2.0"
    flags = shell_output(command).strip.split
    system ENV.cxx, "-std=c++11", "test.cpp", "-o", "test", *flags
    system "./test"
  end
end
