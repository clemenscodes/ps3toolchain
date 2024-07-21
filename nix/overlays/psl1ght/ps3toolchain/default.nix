{pkgs}: let
  mkUrl = pkg: "https://gcc.gnu.org/pub/gcc/infrastructure/${pkg}";
  mkTarget = prefix:
    if prefix == "ppu"
    then "powerpc64-ps3-elf"
    else "spu";
  scripts = import ../scripts {inherit pkgs;};
  shared = import ../shared.nix {inherit pkgs;};
  args = {
    inherit scripts;
    inherit (shared) nativeBuildInputs buildInputs hardeningDisable;
    inherit (pkgs) stdenv fetchurl gnu-config lib;
  };
  ppu-binutils = pkgs.callPackage ./binutils (rec {
      target = mkTarget prefix;
      prefix = "ppu";
      version = "2.42";
      sha256 = "sha256-qlSFDr2lBkxyzU7C2bBWwpQlKZFIY1DZqXqypt/frxI=";
    }
    // args);
  spu-binutils = pkgs.callPackage ./binutils (rec {
      target = mkTarget prefix;
      prefix = "spu";
      version = "2.22";
      sha256 = "sha256-bHr47RyM+bS51ub+CaPh09R5/mOYS6i5smvzVrYxPKk=";
    }
    // args);
  ppu-gcc = pkgs.callPackage ./gcc (rec {
      target = mkTarget prefix;
      prefix = "ppu";
      version = "13.2.0";
      sha256 = "1nj3qyswcgc650sl3h0480a171ixp33ca13zl90p61m689jffxg2";
      newlib = rec {
        pname = "${prefix}-newlib";
        version = "1.20.0";
        name = "${pname}-${version}.tar.gz";
        src = pkgs.fetchurl {
          inherit pname version;
          url = "ftp://sourceware.org/pub/newlib/newlib-${version}.tar.gz";
          sha256 = "14pn7y1dm8vsm9lszfgkcz3sgdgsv1lxmpf2prbqq9s4fa2b4i66";
        };
      };
      mpfr = rec {
        pname = "${prefix}-mpfr";
        version = "4.1.0";
        name = "${pname}-${version}.tar.bz2";
        src = pkgs.fetchurl {
          inherit name pname version;
          url = mkUrl "mpfr-${version}.tar.bz2";
          sha256 = "sha256-/s7S1DDdWpeAX6KJ/tP8j/KwlMAtBSh/1hM+fx8OySY=";
        };
      };
      mpc = rec {
        pname = "${prefix}-mpc";
        version = "1.2.1";
        name = "${pname}-${version}.tar.gz";
        src = pkgs.fetchurl {
          inherit name pname version;
          url = mkUrl "mpc-${version}.tar.gz";
          sha256 = "sha256-F1A9LDld/PEGtiLcFCaDwRmUMdCVNnxqrLpu7DA0BFk=";
        };
      };
      gmp = rec {
        pname = "${prefix}-gmp";
        version = "6.2.1";
        name = "${pname}-${version}.tar.bz2";
        src = pkgs.fetchurl {
          inherit name pname version;
          url = mkUrl "gmp-${version}.tar.bz2";
          sha256 = "sha256-6ukya+tBWMOG45o1aBgDG9KPMSTPkV+MWx3Ex6NrTXw=";
        };
      };
      isl = rec {
        pname = "${prefix}-isl";
        version = "0.24";
        name = "${pname}-${version}.tar.bz2";
        src = pkgs.fetchurl {
          inherit name pname version;
          url = mkUrl "isl-${version}.tar.bz2";
          sha256 = "sha256-/PeN2WVsEOuM+fvV9ZoLawE4YgX+GTSzsoegoYmBRcA=";
        };
      };
    }
    // args);
  spu-gcc = pkgs.callPackage ./gcc (rec {
      target = mkTarget prefix;
      prefix = "spu";
      version = "9.5.0";
      sha256 = "sha256-bHr47RyM+bS51ub+CaPh09R5/mOYS6i5smvzVrYxPKk=";
      newlib = rec {
        pname = "${prefix}-newlib";
        version = "1.20.0";
        name = "${pname}-${version}.tar.gz";
        src = pkgs.fetchurl {
          inherit pname version;
          url = "ftp://sourceware.org/pub/newlib/newlib-${version}.tar.gz";
          sha256 = "14pn7y1dm8vsm9lszfgkcz3sgdgsv1lxmpf2prbqq9s4fa2b4i66";
        };
      };
      mpfr = rec {
        pname = "${prefix}-mpfr";
        version = "3.1.4";
        name = "${pname}-${version}.tar.bz2";
        src = pkgs.fetchurl {
          inherit name pname version;
          url = mkUrl "mpfr-${version}.tar.bz2";
          sha256 = "sha256-0xA6gM2tJAftWB82GMS+0E4MktHPdxpl6tZizDl/d3U=";
        };
      };
      mpc = rec {
        pname = "${prefix}-mpc";
        version = "1.0.3";
        name = "${pname}-${version}.tar.gz";
        src = pkgs.fetchurl {
          inherit name pname version;
          url = mkUrl "mpc-${version}.tar.gz";
          sha256 = "sha256-YX3sxuoJiJ+wjt4zCRegCxaAm424jCnDG/u0nL+I7MM=";
        };
      };
      gmp = rec {
        pname = "${prefix}-gmp";
        version = "6.1.0";
        name = "${pname}-${version}.tar.bz2";
        src = pkgs.fetchurl {
          inherit name pname version;
          url = mkUrl "gmp-${version}.tar.bz2";
          sha256 = "sha256-SYRJqZTv66UniFwQQFmTQnmV0/hrh2jYzfjZ3Xxrc+g";
        };
      };
      isl = rec {
        pname = "${prefix}-isl";
        version = "0.18";
        name = "${pname}-${version}.tar.bz2";
        src = pkgs.fetchurl {
          inherit name pname version;
          url = mkUrl "isl-${version}.tar.bz2";
          sha256 = "sha256-a4sP1/gdCpV76zZ5yBu7NMzHVo1WgoRNiSRCSg2tyxs=";
        };
      };
    }
    // args);
  ppu-gdb = import ./ppu-gdb {inherit pkgs;};
  spu-gdb = import ./spu-gdb {inherit pkgs;};
in
  pkgs.stdenv.mkDerivation {
    name = "ps3toolchain";
    phases = "installPhase";
    inherit (shared) nativeBuildInputs buildInputs hardeningDisable;
    installPhase = ''
      mkdir -p $out
    '';
    passthru = {
      inherit
        ppu-binutils
        spu-binutils
        ppu-gcc
        spu-gcc
        ppu-gdb
        spu-gdb
        ;
    };
  }
