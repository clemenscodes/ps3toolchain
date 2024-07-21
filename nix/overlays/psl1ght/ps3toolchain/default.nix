{pkgs}: let
  scripts = import ../scripts {inherit pkgs;};

  shared = import ../shared.nix {inherit pkgs;};

  args = {
    inherit scripts;
    inherit (shared) nativeBuildInputs buildInputs hardeningDisable;
    inherit (pkgs) stdenv fetchurl gnu-config lib;
  };

  callPackage = pkgs.lib.callPackageWith (pkgs // args);

  isPPU = prefix: prefix == "ppu";

  mkUrl = pkg: "https://gcc.gnu.org/pub/gcc/infrastructure/${pkg}";

  mkTarget = prefix:
    if isPPU prefix
    then "powerpc64-ps3-elf"
    else "spu";

  fetch = {
    pname,
    version,
    ext,
    sha256,
    url ? mkUrl "${pname}-${version}.${ext}",
  }: rec {
    inherit pname version;
    name = "${pname}-${version}.${ext}";
    src = pkgs.fetchurl {inherit url sha256 pname version name;};
  };

  mkBinutils = {
    prefix,
    version,
    sha256,
  }:
    callPackage ./binutils {
      target = mkTarget prefix;
      inherit prefix version sha256;
    };

  mkGcc = {
    prefix,
    version,
    sha256,
    binutils,
  }:
    callPackage ./gcc {
      target = mkTarget prefix;
      inherit prefix version sha256 binutils;
      inherit (mkComponents prefix) newlib mpfr mpc gmp isl;
    };

  mkComponents = prefix: {
    newlib = fetch {
      pname = "${prefix}-newlib";
      version = "1.20.0";
      ext = "tar.gz";
      sha256 = "14pn7y1dm8vsm9lszfgkcz3sgdgsv1lxmpf2prbqq9s4fa2b4i66";
      url = "ftp://sourceware.org/pub/newlib/";
    };
    mpfr = fetch {
      pname = "${prefix}-mpfr";
      version =
        if isPPU prefix
        then "4.1.0"
        else "3.1.4";
      ext = "tar.bz2";
      sha256 =
        if isPPU prefix
        then "sha256-/s7S1DDdWpeAX6KJ/tP8j/KwlMAtBSh/1hM+fx8OySY="
        else "sha256-0xA6gM2tJAftWB82GMS+0E4MktHPdxpl6tZizDl/d3U=";
    };
    mpc = fetch {
      pname = "${prefix}-mpc";
      version =
        if isPPU prefix
        then "1.2.1"
        else "1.0.3";
      ext = "tar.gz";
      sha256 =
        if isPPU prefix
        then "sha256-F1A9LDld/PEGtiLcFCaDwRmUMdCVNnxqrLpu7DA0BFk="
        else "sha256-YX3sxuoJiJ+wjt4zCRegCxaAm424jCnDG/u0nL+I7MM=";
    };
    gmp = fetch {
      pname = "${prefix}-gmp";
      version =
        if isPPU prefix
        then "6.2.1"
        else "6.1.0";
      ext = "tar.bz2";
      sha256 =
        if isPPU prefix
        then "sha256-6ukya+tBWMOG45o1aBgDG9KPMSTPkV+MWx3Ex6NrTXw="
        else "sha256-SYRJqZTv66UniFwQQFmTQnmV0/hrh2jYzfjZ3Xxrc+g";
    };
    isl = fetch {
      pname = "${prefix}-isl";
      version =
        if isPPU prefix
        then "0.24"
        else "0.18";
      ext = "tar.bz2";
      sha256 =
        if isPPU prefix
        then "sha256-/PeN2WVsEOuM+fvV9ZoLawE4YgX+GTSzsoegoYmBRcA="
        else "sha256-a4sP1/gdCpV76zZ5yBu7NMzHVo1WgoRNiSRCSg2tyxs=";
    };
  };

  mkGdb = {
    prefix,
    version,
    sha256,
  }:
    callPackage ./gdb {
      target = mkTarget prefix;
      inherit prefix version sha256;
    };

  ppu-binutils = mkBinutils {
    prefix = "ppu";
    version = "2.42";
    sha256 = "sha256-qlSFDr2lBkxyzU7C2bBWwpQlKZFIY1DZqXqypt/frxI=";
  };

  spu-binutils = mkBinutils {
    prefix = "spu";
    version = "2.22";
    sha256 = "sha256-bHr47RyM+bS51ub+CaPh09R5/mOYS6i5smvzVrYxPKk=";
  };

  ppu-gcc = mkGcc {
    prefix = "ppu";
    version = "13.2.0";
    sha256 = "1nj3qyswcgc650sl3h0480a171ixp33ca13zl90p61m689jffxg2";
    binutils = ppu-binutils;
  };

  spu-gcc = mkGcc {
    prefix = "spu";
    version = "9.5.0";
    sha256 = "sha256-J3afZO8dTNXivoaCwMk/mIeYPmz9GpJ85aCikVqVz48=";
    binutils = spu-binutils;
  };

  ppu-gdb = mkGdb {
    prefix = "ppu";
    version = "8.3.1";
    sha256 = "sha256-HlW0183KezS+EvTOrmUWI6pzsv1kAVIxP59mpxSXV8Q=";
  };

  spu-gdb = mkGdb {
    prefix = "spu";
    version = "8.3.1";
    sha256 = "sha256-HlW0183KezS+EvTOrmUWI6pzsv1kAVIxP59mpxSXV8Q=";
  };
in
  pkgs.stdenv.mkDerivation {
    name = "ps3toolchain";
    phases = "installPhase";
    inherit (shared) nativeBuildInputs buildInputs hardeningDisable;
    installPhase = ''
      mkdir -p $out
    '';
    passthru = {
      inherit ppu-binutils spu-binutils ppu-gcc spu-gcc ppu-gdb spu-gdb;
    };
  }
