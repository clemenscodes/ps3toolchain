{pkgs}: let
  sources = import ./sources.nix {inherit pkgs;};
  install = import ./install.nix {inherit pkgs sources;};
  ps3toolchain =
    /*
    bash
    */
    ''
      mkdir -p $out/ps3 $out/build
      export PS3DEV="$out/ps3"
      export PSL1GHT="$PS3DEV"
    '';
  symlinks =
    /*
    bash
    */
    ''
      cd $PS3DEV/ppu

      if [ ! -d ppu -a ! -f ppu -a ! -h ppu -a -d powerpc64-ps3-elf ]; then
        ln -s powerpc64-ps3-elf ppu
      fi

      cd $PS3DEV/ppu/bin

      for i in `ls powerpc64-ps3-elf-* | cut -c19-`; do
        if [ ! -f ppu-$i -a ! -h ppu-$i -a -f powerpc64-ps3-elf-$i ]; then
          ln -s powerpc64-ps3-elf-$i ppu-$i
        fi
      done
    '';
in (final: prev:
    with prev; {
      ps3toolchain = with install;
        stdenv.mkDerivation {
          name = "ps3toolchain";
          nativeBuildInputs = [
            cmake
            pkg-config
            libelf
            gmp.dev
            ncurses
            ncurses.dev
            zlib
            zlib.dev
            autoconf
            automake
            bison
            flex
            bzip2
            gettext
            openssl
            libtool
            gnumake
            gnupatch
            texinfo
          ];
          buildInputs = [wget python310];
          hardeningDisable = ["format"];
          phases = "installPhase";
          installPhase =
            ps3toolchain
            + ppu-binutils
            + ppu-gcc
            + ppu-gdb
            + symlinks
            + spu-binutils
            + spu-gcc
            + spu-gdb;
        };
    })
