class Openvdb < Formula
  desc "Sparse volume processing toolkit"
  homepage "http://www.openvdb.org/"
  url "https://github.com/dreamworksanimation/openvdb/archive/v4.0.0.tar.gz"
  sha256 "eaf37b8e723cfd011df350cb0ef93ffa22d927bf7cb1f72c38176fce523b3537"
  revision 1

  head "https://github.com/dreamworksanimation/openvdb.git"

  bottle do
    sha256 "07f23237480ba2dbc44174bc70c6b283aace47c38aa41f0687e8efc43b07d135" => :sierra
    sha256 "cd96c279d070522e6a697aa80c6df6a1dedfba1cbc017d90df3256ea413ad202" => :el_capitan
    sha256 "ab4d5550eeb804481176a61a3720bc131907c4506a1a006116cb8b12fce77156" => :yosemite
  end

  option "with-glfw", "Installs the command-line tool to view OpenVDB files"
  option "with-test", "Installs the unit tests for the OpenVDB library"
  option "with-logging", "Requires log4cplus"
  option "with-docs", "Installs documentation"

  deprecated_option "with-tests" => "with-test"
  deprecated_option "with-viewer" => "with-glfw"

  depends_on "openexr"
  depends_on "ilmbase"
  depends_on "tbb"
  depends_on "jemalloc" => :recommended

  if MacOS.version < :mavericks
    depends_on "boost" => "c++11"
  else
    depends_on "boost"
  end

  depends_on "glfw" => :optional
  depends_on "cppunit" if build.with? "test"
  depends_on "doxygen" if build.with? "docs"
  depends_on "log4cplus" if build.with? "logging"
  needs :cxx11

  resource "test_file" do
    url "http://www.openvdb.org/download/models/cube.vdb.zip"
    sha256 "05476e84e91c0214ad7593850e6e7c28f777aa4ff0a1d88d91168a7dd050f922"
  end

  def install
    ENV.cxx11
    # Adjust hard coded paths in Makefile
    args = [
      "DESTDIR=#{prefix}",
      "BOOST_INCL_DIR=#{Formula["boost"].opt_lib}/include",
      "BOOST_LIB_DIR=#{Formula["boost"].opt_lib}",
      "BOOST_THREAD_LIB=-lboost_thread-mt",
      "TBB_INCL_DIR=#{Formula["tbb"].opt_lib}/include",
      "TBB_LIB_DIR=#{Formula["tbb"].opt_lib}/lib",
      "EXR_INCL_DIR=#{Formula["openexr"].opt_lib}/include",
      "EXR_LIB_DIR=#{Formula["openexr"].opt_lib}/lib",
      "BLOSC_INCL_DIR=", # Blosc is not yet supported.
      "PYTHON_VERSION=",
      "NUMPY_INCL_DIR=",
    ]

    if build.with? "jemalloc"
      args << "CONCURRENT_MALLOC_LIB_DIR=#{Formula["jemalloc"].opt_lib}/lib"
    else
      args << "CONCURRENT_MALLOC_LIB="
    end

    if build.with? "glfw"
      args << "GLFW_INCL_DIR=#{Formula["glfw"].opt_lib}/include"
      args << "GLFW_LIB_DIR=#{Formula["glfw"].opt_lib}/lib"
      args << "GLFW_LIB=-lglfw"
    else
      args << "GLFW_INCL_DIR="
      args << "GLFW_LIB_DIR="
      args << "GLFW_LIB="
    end

    if build.with? "docs"
      args << "DOXYGEN=doxygen"
    else
      args << "DOXYGEN="
    end

    if build.with? "test"
      args << "CPPUNIT_INCL_DIR=#{Formula["cppunit"].opt_lib}/include"
      args << "CPPUNIT_LIB_DIR=#{Formula["cppunit"].opt_lib}/lib"
    else
      args << "CPPUNIT_INCL_DIR=" << "CPPUNIT_LIB_DIR="
    end

    if build.with? "logging"
      args << "LOG4CPLUS_INCL_DIR=#{Formula["log4cplus"].opt_lib}/include"
      args << "LOG4CPLUS_LIB_DIR=#{Formula["log4cplus"].opt_lib}/lib"
    else
      args << "LOG4CPLUS_INCL_DIR=" << "LOG4CPLUS_LIB_DIR="
    end

    ENV.append_to_cflags "-I #{buildpath}"

    cd "openvdb" do
      system "make", "install", *args
      if build.with? "test"
        system "make", "vdb_test", *args
        bin.install "vdb_test"
      end
    end
  end

  test do
    resource("test_file").stage testpath
    system "#{bin}/vdb_print", "-m", "cube.vdb"
  end
end
