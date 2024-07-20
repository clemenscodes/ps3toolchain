{pkgs}: let
  mkUrl = pkg: "https://gcc.gnu.org/pub/gcc/infrastructure/${pkg}";
  prefix = "spu";
  spu-binutils = import ../spu-binutils {inherit pkgs;};
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
    version = "3.1.4";
    name = "${pname}-${version}.tar.bz2";
    src = pkgs.fetchurl {
      inherit name pname version;
      url = mkUrl "mpfr-${version}.tar.bz2";
      sha256 = "sha256-0xA6gM2tJAftWB82GMS+0E4MktHPdxpl6tZizDl/d3U=";
    };
  };
  mpc = with mpc; {
    pname = "${prefix}-mpc";
    version = "1.0.3";
    name = "${pname}-${version}.tar.gz";
    src = pkgs.fetchurl {
      inherit name pname version;
      url = mkUrl "mpc-${version}.tar.gz";
      sha256 = "sha256-YX3sxuoJiJ+wjt4zCRegCxaAm424jCnDG/u0nL+I7MM=";
    };
  };
  gmp = with gmp; {
    pname = "${prefix}-gmp";
    version = "6.1.0";
    name = "${pname}-${version}.tar.bz2";
    src = pkgs.fetchurl {
      inherit name pname version;
      url = mkUrl "gmp-${version}.tar.bz2";
      sha256 = "sha256-SYRJqZTv66UniFwQQFmTQnmV0/hrh2jYzfjZ3Xxrc+g";
    };
  };
  isl = with isl; {
    pname = "${prefix}-isl";
    version = "0.18";
    name = "${pname}-${version}.tar.bz2";
    src = pkgs.fetchurl {
      inherit name pname version;
      url = mkUrl "isl-${version}.tar.bz2";
      sha256 = "sha256-a4sP1/gdCpV76zZ5yBu7NMzHVo1WgoRNiSRCSg2tyxs=";
    };
  };
in
  pkgs.stdenv.mkDerivation rec {
    inherit (shared) nativeBuildInputs buildInputs hardeningDisable;
    pname = "${prefix}-gcc";
    version = "9.5.0";
    name = "${pname}-${version}-PS3";
    src = pkgs.fetchurl {
      inherit pname version;
      url = "https://ftp.gnu.org/gnu/gcc/gcc-${version}/gcc-${version}.tar.xz";
      sha256 = "sha256-J3afZO8dTNXivoaCwMk/mIeYPmz9GpJ85aCikVqVz48=";
    };
    unpackPhase = ''
      export PS3DEV=${placeholder "out"}/ps3
      export PSL1GHT=$PS3DEV
      ${scripts.copy}/bin/copy_if_not_exists ${src} ${name}.tar.xz
      ${scripts.extract}/bin/extract_if_not_exists ${name}.tar.xz xvf gcc-${version}
      cp ${pkgs.gnu-config}/config.guess ${pkgs.gnu-config}/config.sub gcc-${version}
      ${scripts.symlinks}/bin/create_symlinks ${spu-binutils} $PS3DEV
      ${scripts.copy}/bin/copy_if_not_exists ${src} ${name}.tar.xz
      ${scripts.copy}/bin/copy_if_not_exists ${newlib.src} ${newlib.name}.tar.gz
      ${scripts.copy}/bin/copy_if_not_exists ${mpc.src} ${mpc.name}.tar.gz
      ${scripts.copy}/bin/copy_if_not_exists ${mpfr.src} ${mpfr.name}.tar.bz2
      ${scripts.copy}/bin/copy_if_not_exists ${gmp.src} ${gmp.name}.tar.bz2
      ${scripts.copy}/bin/copy_if_not_exists ${isl.src} ${isl.name}.tar.bz2
      ${scripts.extract}/bin/extract_if_not_exists ${name}.tar.xz xfv gcc-${version}
      ${scripts.extract}/bin/extract_if_not_exists ${newlib.name}.tar.gz xfvz newlib-${newlib.version}
      ${scripts.extract}/bin/extract_if_not_exists ${mpc.name}.tar.gz xfv mpc-${mpc.version}
      ${scripts.extract}/bin/extract_if_not_exists ${mpfr.name}.tar.bz2 xfvj mpfr-${mpfr.version}
      ${scripts.extract}/bin/extract_if_not_exists ${gmp.name}.tar.bz2 xfvj gmp-${gmp.version}
      ${scripts.extract}/bin/extract_if_not_exists ${isl.name}.tar.bz2 xfvj isl-${isl.version}
      cp ${pkgs.gnu-config}/config.guess ${pkgs.gnu-config}/config.sub gcc-${version}
      cd gcc-${version}
      ${scripts.symlink}/bin/symlink_if_not_exists ../newlib-${newlib.version}/newlib newlib
      ${scripts.symlink}/bin/symlink_if_not_exists ../newlib-${newlib.version}/libgloss libgloss
      ${scripts.symlink}/bin/symlink_if_not_exists ../mpc-${mpc.version} mpc
      ${scripts.symlink}/bin/symlink_if_not_exists ../mpfr-${mpfr.version} mpfr
      ${scripts.symlink}/bin/symlink_if_not_exists ../gmp-${gmp.version} gmp
      ${scripts.symlink}/bin/symlink_if_not_exists ../isl-${isl.version} isl
    '';
    patchPhase = ''
      ${scripts.patch}/bin/apply_patch_if_not_applied ${./patches/${pname}-${version}-PS3.patch} .
      ${scripts.patch}/bin/apply_patch_if_not_applied ${./patches/${newlib.pname}-${newlib.version}-PS3.patch} ../newlib-${newlib.version}
    '';
    configurePhase = ''
      mkdir build-spu
      cd build-spu
      unset CFLAGS CXXFLAGS LDFLAGS
      CFLAGS_FOR_TARGET="-Os -fpic -ffast-math -ftree-vectorize -funroll-loops -fschedule-insns -mdual-nops -mwarn-reloc" \
      ../configure --prefix="$PS3DEV/spu" --target="spu" \
        --enable-languages="c,c++" \
        --enable-lto \
        --enable-threads \
        --enable-newlib-multithread \
        --enable-newlib-hw-fp \
        --enable-obsolete \
        --disable-dependency-tracking \
        --disable-libcc1 \
        --disable-libssp \
        --disable-multilib \
        --disable-nls \
        --disable-shared \
        --disable-win32-registry
    '';
    buildPhase = ''
      make -j $PROCS all
    '';
    installPhase = ''
      mkdir -p $out/build $out/ps3
      make install
    '';
    fixupPhase = ''
      mv $out/ps3/* $out
      rm -rf $out/build $out/ps3
    '';
  }
