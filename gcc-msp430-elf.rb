class GccMsp430Elf < Formula
  homepage "http://software-dl.ti.com/msp430/msp430_public_sw/mcu/msp430/MSPGCC/latest/index_FDS.html"
  url "https://ftp.gnu.org/gnu/gcc/gcc-9.3.0/gcc-9.3.0.tar.xz"
  mirror "https://ftpmirror.gnu.org/gcc/gcc-9.3.0/gcc-9.3.0.tar.xz"
  sha256 "71e197867611f6054aa1119b13a0c0abac12834765fe2d81f35ac57f84f742d1"
  version "9.3.1-11"
  revision 4

  depends_on "binutils-msp430-elf"
  depends_on "headers-msp430-elf"
  depends_on "gmp"
  depends_on "mpfr"
  depends_on "libmpc"
  depends_on "isl"
  depends_on "texinfo" => :build

  patch :p0 do
    url "https://software-dl.ti.com/msp430/msp430_public_sw/mcu/msp430/MSPGCC/9_3_1_2/export/msp430-gcc-9.3.1.11-source-patches.tar.bz2"
    sha256 "ec6472b034e11e8cfdeb3934b218e5bafbb7a03f3afc0e76536bd9c42653525b"
    apply "gcc-9.3.0.patch"
  end

  resource "newlib" do
    url "ftp://sourceware.org/pub/newlib/newlib-2.4.0.tar.gz"
    sha256 "545b3d235e350d2c61491df8b9f775b1b972f191380db8f52ec0b1c829c52706"

    patch :p0 do
      url "https://software-dl.ti.com/msp430/msp430_public_sw/mcu/msp430/MSPGCC/9_3_1_2/export/msp430-gcc-9.3.1.11-source-patches.tar.bz2"
      sha256 "ec6472b034e11e8cfdeb3934b218e5bafbb7a03f3afc0e76536bd9c42653525b"
      apply "newlib-2_4_0.patch"
    end
  end

  def install
    target = "msp430-elf"

    # Stage newlib resources into the GCC source directory
    resource("newlib").stage do
      (buildpath/"newlib").install Dir["newlib/*"]
      (buildpath/"libgloss").install Dir["libgloss/*"]
    end

    # Get paths to dependencies
    binutils_prefix = Formula["binutils-msp430-elf"].opt_prefix
    headers_prefix = Formula["headers-msp430-elf"].opt_prefix

    # Set compiler environment variables
    ENV["CC"] = "clang"
    ENV["CXX"] = "clang++"
    ENV["AR"] = "ar"
    ENV["RANLIB"] = "ranlib"

    # Create a separate build directory
    mkdir "build" do
      # Configure GCC
      system "../configure",
        "--target=#{target}",
        "--program-prefix=#{target}-",
        "--prefix=#{prefix}",
        "--enable-languages=c,c++",
        "--disable-nls",
        "--disable-shared",
        "--disable-threads",
        "--disable-libssp",
        "--disable-libgomp",
        "--disable-libquadmath",
        "--disable-libatomic",
        "--disable-libstdcxx-pch",
        "--disable-libstdcxx-verbose",
        "--enable-initfini-array",
        "--enable-target-optspace",
        "--enable-newlib-nano-formatted-io",
        "--with-system-zlib",
        "--with-gmp=#{Formula["gmp"].opt_prefix}",
        "--with-mpfr=#{Formula["mpfr"].opt_prefix}",
        "--with-mpc=#{Formula["libmpc"].opt_prefix}",
        "--with-isl=#{Formula["isl"].opt_prefix}",
        "--with-as=#{binutils_prefix}/bin/#{target}-as",
        "--with-ld=#{binutils_prefix}/bin/#{target}-ld",
        "--with-headers=#{headers_prefix}/include/#{target}",
        "--with-newlib",
        "--with-build-time-tools=#{binutils_prefix}/bin",
        "--enable-multilib",
        "--build=aarch64-unknown-linux-gnu",
        "--host=aarch64-unknown-linux-gnu"

      # Build with verbose output
      system "make", "-j#{ENV.make_jobs}", "all"
      system "make", "install"
    end

    # Remove unnecessary files
    info.rmtree if info.exist?
    man7.rmtree if man7.exist?

    # Create symlinks to linker scripts from headers-msp430-elf
    ldscripts = "#{headers_prefix}/lib/#{target}/ldscripts"
    target_lib_dir = prefix/target/"lib"
    target_lib_dir.mkpath unless target_lib_dir.exist?
    
    if Dir.exist?(ldscripts)
      Dir["#{ldscripts}/*.ld"].each do |ldscript|
        target_lib_dir.install_symlink ldscript
      end
    end
  end
end
