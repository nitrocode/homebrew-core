class Fastmod < Formula
  desc "Fast partial replacement for the codemod tool"
  homepage "https://github.com/facebookincubator/fastmod"
  url "https://github.com/facebookincubator/fastmod/archive/v0.3.0.tar.gz"
  sha256 "95925c73d06f6bd9ea9a6ca66c847e9722fe7bff5c8c3ee9a3245a37f630dfc0"

  bottle do
    cellar :any_skip_relocation
    rebuild 1
    sha256 "b8796ef40402ee2f3f1663186cf0c72a0b46e7870bdc38ed36b42797b1d8903e" => :catalina
    sha256 "3e63d95fed7192044cb1140179d6b0565f69c7187e82efb541b157c91cd27186" => :mojave
    sha256 "8047f087b7034a595a66daa17b6d5e7fb381ce8a50fe443747f5ce42714b323f" => :high_sierra
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", "--locked", "--root", prefix, "--path", "."
  end

  test do
    (testpath/"input.txt").write("Hello, World!")
    system bin/"fastmod", "-d", testpath, "--accept-all", "World", "fastmod"
    assert_equal "Hello, fastmod!", (testpath/"input.txt").read
  end
end
