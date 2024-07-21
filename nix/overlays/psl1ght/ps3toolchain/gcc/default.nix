{
  prefix,
  target,
  version,
  sha256,
  binutils,
  newlib,
  mpfr,
  mpc,
  gmp,
  isl,
  scripts,
  stdenv,
  fetchurl,
  gnu-config,
  nativeBuildInputs,
  buildInputs,
  hardeningDisable,
  lib,
}:
stdenv.mkDerivation rec {
  inherit version nativeBuildInputs buildInputs hardeningDisable;
  pname = "${prefix}-gcc";
  name = "${pname}-${version}-PS3";
  src = fetchurl {
    inherit pname version sha256;
    url = "https://ftp.gnu.org/gnu/gcc/gcc-${version}/gcc-${version}.tar.xz";
  };
  unpackPhase = ''
    export PS3DEV=${placeholder "out"}/ps3
    export PSL1GHT=$PS3DEV
    ${scripts.copy}/bin/copy_if_not_exists ${src} ${name}.tar.xz
    ${scripts.extract}/bin/extract_if_not_exists ${name}.tar.xz xvf gcc-${version}
    cp ${gnu-config}/config.guess ${gnu-config}/config.sub gcc-${version}
    ${scripts.symlinks}/bin/create_symlinks ${binutils} $PS3DEV
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
    cp ${gnu-config}/config.guess ${gnu-config}/config.sub gcc-${version}
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
  configureFlags =
    [
      "--prefix=$PS3DEV/${prefix}"
      "--target=${target}"
      "--with-cpu=cell"
      "--with-newlib"
      "--with-system-zlib"
      "--enable-languages=c,c++"
      "--enable-long-double-128"
      "--enable-lto"
      "--enable-threads"
      "--enable-newlib-multithread"
      "--enable-newlib-hw-fp"
      "--disable-dependency-tracking"
      "--disable-libcc1"
      "--disable-multilib"
      "--disable-nls"
      "--disable-shared"
      "--disable-win32-registry"
    ]
    ++ lib.optional (prefix == "spu") [
      "--enable-obsolete"
    ];
  configurePhase = let
    spuFlags =
      /*
      bash
      */
      ''
        unset CFLAGS CXXFLAGS LDFLAGS
        CFLAGS_FOR_TARGET="-Os -fpic -ffast-math -ftree-vectorize -funroll-loops -fschedule-insns -mdual-nops -mwarn-reloc"
      '';
  in
    /*
    bash
    */
    ''
      mkdir build-${prefix}
      cd build-${prefix}
      ${
        if prefix != "ppu"
        then "${spuFlags}"
        else ""
      }
      ../configure $configureFlags
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
