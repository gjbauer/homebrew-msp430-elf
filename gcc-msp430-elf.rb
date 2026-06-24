class GccMsp430Elf < Formula
  homepage "http://software-dl.ti.com/msp430/msp430_public_sw/mcu/msp430/MSPGCC/latest/index_FDS.html"
  on_linux do
      url "https://ftp.gnu.org/gnu/gcc/gcc-9.3.0/gcc-9.3.0.tar.xz"
      mirror "https://ftpmirror.gnu.org/gcc/gcc-9.3.0/gcc-9.3.0.tar.xz"
      sha256 "71e197867611f6054aa1119b13a0c0abac12834765fe2d81f35ac57f84f742d1"
  end
  on_macos do
      url "https://dr-download.ti.com/software-development/ide-configuration-compiler-or-debugger/MD-LlCjWuAbzH/9.3.1.2/msp430-gcc-9.3.1.11_macos.tar.bz2"
      sha256 "7d1f34a001587bfe40bc12789d1543b214e24535721d794865d99e8bafb179ef"
  end
  version "9.3.1-11"
  revision 1

  depends_on "binutils-msp430-elf"
  depends_on "headers-msp430-elf"
  
  target = "msp430-elf"

    on_linux do
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

      resource("newlib").stage do
          buildpath.install "newlib"
          buildpath.install "libgloss"
      end

      # gcc must be built outside of the source directory.
      mkdir "build" do
          system "../configure",
          "--target=#{target}",
          "--program-prefix=#{target}-",
          "--prefix=#{prefix}",
          "--enable-languages=c,c++",
          "--disable-nls",
          "--enable-inifini-array",
          "--enable-target-optspace",
          "--enable-newlib-nano-formatted-io",
          "--with-system-zlib",
          "--with-as=#{HOMEBREW_PREFIX}/bin/#{target}-as",
          "--with-ld=#{HOMEBREW_PREFIX}/bin/#{target}-ld"
          system "make"
          system "make", "install"
      end

      # Remove unnecessary files.
      info.rmtree
      man7.rmtree
    end
    
    on_macos do
        # macOS install process (extract pre-built binaries)
        # The tarball already contains the full directory structure
        prefix.install Dir["*"]
          
        # The pre-built binaries are in bin/, lib/, etc.
        # Homebrew will automatically symlink everything in bin/ to HOMEBREW_PREFIX/bin
    end

    # Create symlinks to linker scripts from headers-msp430-elf.
    ldscripts = "#{HOMEBREW_PREFIX}/lib/#{target}/lib/ldscripts"
    (prefix/target/"lib").install_symlink Dir["#{ldscripts}/*.ld"]
  end
end
