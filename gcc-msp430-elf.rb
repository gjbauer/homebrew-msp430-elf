class GccMsp430Elf < Formula
  desc "MSP430 GCC cross-compiler"
  homepage "https://www.ti.com/tool/MSP430-GCC-OPENSOURCE"
  
  # Use the latest TI MSP430 GCC release (13.x series)
  url "https://dr-download.ti.com/software-development/ide-configuration-compiler-or-debugger/MD-QnB99YsJRt/13.2.0.0/msp430-gcc-13.2.0.0_source.tar.bz2"
  version "13.2.0.0"

  depends_on "binutils-msp430-elf"
  depends_on "headers-msp430-elf"
  depends_on "gmp" => :build if OS.mac?
  depends_on "mpfr" => :build if OS.mac?
  depends_on "libmpc" => :build if OS.mac?
  depends_on "isl" => :build if OS.mac?
  depends_on "gcc" => :build if OS.mac?
  
  def install
    target = "msp430-elf"
    
    # Configure with modern options
    on_macos do
      system "./configure",
        "--target=#{target}",
        "--prefix=#{prefix}",
        "--enable-languages=c,c++",
        "--disable-bootstrap",
        "--with-gmp=#{Formula["gmp"].opt_prefix}",
        "--with-mpfr=#{Formula["mpfr"].opt_prefix}",
        "--with-mpc=#{Formula["libmpc"].opt_prefix}"
    end
    on_linux do
      system "./configure",
        "--target=#{target}",
        "--prefix=#{prefix}",
        "--enable-languages=c,c++",
        "--disable-bootstrap"
    end
    
    system "make", "-j#{ENV.make_jobs}"
    system "make", "install"
  end
  
  test do
    system "#{bin}/msp430-elf-gcc", "--version"
  end
end
