{pkgs}: let
  mkUrl = pkg: "https://gcc.gnu.org/pub/gcc/infrastructure/${pkg}";
  prefix = "ppu";
  ppu-binutils = import ../ppu-binutils {inherit pkgs;};
  scripts = import ../../scripts {inherit pkgs;};
  shared = import ../../shared.nix {inherit pkgs;};
  newlib = with newlib; {
    pname = "${prefix}-newlib";
    version = "1.20.0";
    name = "${pname}-${version}.tar.gz";
    src = pkgs.fetchurl {
      inherit pname version;
      url = "ftp://sourceware.org/pub/newlib/newlib-${version}.tar.gz";
      sha256 = "14pn7y1dm8vsm9lszfgkcz3sgdgsv1lxmpf2prbqq9s4fa2b4i66";
    };
  };
  mpfr = with mpfr; {
    pname = "${prefix}-mpfr";
    version = "4.1.0";
    name = "${pname}-${version}.tar.bz2";
    src = pkgs.fetchurl {
      inherit name pname version;
      url = mkUrl "mpfr-${version}.tar.bz2";
      sha256 = "sha256-/s7S1DDdWpeAX6KJ/tP8j/KwlMAtBSh/1hM+fx8OySY=";
    };
  };
  mpc = with mpc; {
    pname = "${prefix}-mpc";
    version = "1.2.1";
    name = "${pname}-${version}.tar.gz";
    src = pkgs.fetchurl {
      inherit name pname version;
      url = mkUrl "mpc-${version}.tar.gz";
      sha256 = "sha256-F1A9LDld/PEGtiLcFCaDwRmUMdCVNnxqrLpu7DA0BFk=";
    };
  };
  gmp = with gmp; {
    pname = "${prefix}-gmp";
    version = "6.2.1";
    name = "${pname}-${version}.tar.bz2";
    src = pkgs.fetchurl {
      inherit name pname version;
      url = mkUrl "gmp-${version}.tar.bz2";
      sha256 = "sha256-6ukya+tBWMOG45o1aBgDG9KPMSTPkV+MWx3Ex6NrTXw=";
    };
  };
  isl = with isl; {
    pname = "${prefix}-isl";
    version = "0.24";
    name = "${pname}-${version}.tar.bz2";
    src = pkgs.fetchurl {
      inherit name pname version;
      url = mkUrl "isl-${version}.tar.bz2";
      sha256 = "sha256-/PeN2WVsEOuM+fvV9ZoLawE4YgX+GTSzsoegoYmBRcA=";
    };
  };
in
  pkgs.stdenv.mkDerivation rec {
    inherit (shared) nativeBuildInputs buildInputs hardeningDisable;
    pname = "${prefix}-gcc";
    version = "13.2.0";
    name = "${pname}-${version}-PS3";
    src = pkgs.fetchurl {
      inherit pname version;
      url = "https://ftp.gnu.org/gnu/gcc/gcc-${version}/gcc-${version}.tar.xz";
      sha256 = "1nj3qyswcgc650sl3h0480a171ixp33ca13zl90p61m689jffxg2";
    };
    phases = "installPhase";
    installPhase =
      /*
      bash
      */
      ''
        mkdir -p $out/build $out/ps3
        export PS3DEV="$out/ps3"
        export PSL1GHT="$PS3DEV"
        ${scripts.symlinks}/bin/create_symlinks ${ppu-binutils} $PS3DEV
        cd $out/build
        ${scripts.copy}/bin/copy_if_not_exists ${src} ${name}.tar.xz
        ${scripts.copy}/bin/copy_if_not_exists ${newlib.src} ${newlib.name}.tar.gz
        ${scripts.copy}/bin/copy_if_not_exists ${mpc.src} ${mpc.name}.tar.gz
        ${scripts.copy}/bin/copy_if_not_exists ${mpfr.src} ${mpfr.name}.tar.bz2
        ${scripts.copy}/bin/copy_if_not_exists ${gmp.src} ${gmp.name}.tar.bz2
        ${scripts.copy}/bin/copy_if_not_exists ${isl.src} ${isl.name}.tar.bz2
        ${scripts.extract}/bin/extract_if_not_exists ${name}.tar.xz xfvJ gcc-${version}
        ${scripts.extract}/bin/extract_if_not_exists ${newlib.name}.tar.gz xfvz newlib-${newlib.version}
        ${scripts.extract}/bin/extract_if_not_exists ${mpc.name}.tar.gz xfv mpc-${mpc.version}
        ${scripts.extract}/bin/extract_if_not_exists ${mpfr.name}.tar.bz2 xfvj mpfr-${mpfr.version}
        ${scripts.extract}/bin/extract_if_not_exists ${gmp.name}.tar.bz2 xfvj gmp-${gmp.version}
        ${scripts.extract}/bin/extract_if_not_exists ${isl.name}.tar.bz2 xfvj isl-${isl.version}
        ${scripts.patch}/bin/apply_patch_if_not_applied ${./patches/${pname}-${version}-PS3.patch} ./gcc-${version}
        ${scripts.patch}/bin/apply_patch_if_not_applied ${./patches/${newlib.pname}-${newlib.version}-PS3.patch} ./newlib-${newlib.version}
        cp ${pkgs.gnu-config}/config.guess ${pkgs.gnu-config}/config.sub gcc-${version}
        cd gcc-${version}
        ${scripts.symlink}/bin/symlink_if_not_exists ../newlib-${newlib.version}/newlib newlib
        ${scripts.symlink}/bin/symlink_if_not_exists ../newlib-${newlib.version}/libgloss libgloss
        ${scripts.symlink}/bin/symlink_if_not_exists ../mpc-${mpc.version} mpc
        ${scripts.symlink}/bin/symlink_if_not_exists ../mpfr-${mpfr.version} mpfr
        ${scripts.symlink}/bin/symlink_if_not_exists ../gmp-${gmp.version} gmp
        ${scripts.symlink}/bin/symlink_if_not_exists ../isl-${isl.version} isl
        mkdir build-ppu
        cd build-ppu
        ../configure --prefix="$PS3DEV/ppu" --target="powerpc64-ps3-elf" \
          --with-cpu="cell" \
          --with-newlib \
          --with-system-zlib \
          --enable-languages="c,c++" \
          --enable-long-double-128 \
          --enable-lto \
          --enable-threads \
          --enable-newlib-multithread \
          --enable-newlib-hw-fp \
          --disable-dependency-tracking \
          --disable-libcc1 \
          --disable-multilib \
          --disable-nls \
          --disable-shared \
          --disable-win32-registry
        PROCS="$(nproc --all 2>&1)" || ret=$?
        if [ ! -z $ret ]; then PROCS=4; fi
        make -j $PROCS all && make install
        cd $out
        mv $out/ps3/* $out
        rm -rf $out/ps3 $out/build
      '';
  }
