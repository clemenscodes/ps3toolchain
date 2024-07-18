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
            + binutils
            + gcc
            + gdb;
        };
    })
