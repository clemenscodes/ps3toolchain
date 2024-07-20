{
  pkgs,
  sources,
}:
with sources.spu-gcc; let
  scripts = import ../scripts {inherit pkgs;};
  shared = import ../shared.nix {inherit pkgs;};
  spu-binutils = import ../spu-binutils {inherit pkgs sources;};
in
  pkgs.stdenv.mkDerivation {
    inherit (shared) nativeBuildInputs buildInputs hardeningDisable;
    name = "spu-gcc";
    phases = "installPhase";
    installPhase =
      /*
      bash
      */
      ''
        mkdir -p $out/build $out/ps3
        export PS3DEV="$out/ps3"
        export PSL1GHT="$PS3DEV"
        ${scripts.symlinks}/bin/create_symlinks ${spu-binutils} $PS3DEV
        cd $out/build
        ${scripts.copy}/bin/copy_if_not_exists ${src} ${name}
        ${scripts.copy}/bin/copy_if_not_exists ${sources.newlib.src} ${sources.newlib.name}
        ${scripts.copy}/bin/copy_if_not_exists ${dependencies.mpc.src} ${dependencies.mpc.name}
        ${scripts.copy}/bin/copy_if_not_exists ${dependencies.mpfr.src} ${dependencies.mpfr.name}
        ${scripts.copy}/bin/copy_if_not_exists ${dependencies.gmp.src} ${dependencies.gmp.name}
        ${scripts.copy}/bin/copy_if_not_exists ${dependencies.isl.src} ${dependencies.isl.name}
        ${scripts.extract}/bin/extract_if_not_exists ${name} xfvJ ${pname}-${version}
        ${scripts.extract}/bin/extract_if_not_exists ${sources.newlib.name} xfvz ${sources.newlib.pname}-${sources.newlib.version}
        ${scripts.extract}/bin/extract_if_not_exists ${dependencies.mpc.name} xfv ${dependencies.mpc.pname}-${dependencies.mpc.version}
        ${scripts.extract}/bin/extract_if_not_exists ${dependencies.mpfr.name} xfvj ${dependencies.mpfr.pname}-${dependencies.mpfr.version}
        ${scripts.extract}/bin/extract_if_not_exists ${dependencies.gmp.name} xfvj ${dependencies.gmp.pname}-${dependencies.gmp.version}
        ${scripts.extract}/bin/extract_if_not_exists ${dependencies.isl.name} xfvj ${dependencies.isl.pname}-${dependencies.isl.version}
        ${scripts.patch}/bin/apply_patch_if_not_applied ${./patches/${pname}-${version}-PS3-SPU.patch} ./${pname}-${version}
        ${scripts.patch}/bin/apply_patch_if_not_applied ${./patches/${sources.newlib.pname}-${sources.newlib.version}-PS3.patch} ./${sources.newlib.pname}-${sources.newlib.version}
        cp ${pkgs.gnu-config}/config.guess ${pkgs.gnu-config}/config.sub ${pname}-${version}
        cd ${pname}-${version}
        ${scripts.symlink}/bin/symlink_if_not_exists ../${sources.newlib.pname}-${sources.newlib.version}/newlib newlib
        ${scripts.symlink}/bin/symlink_if_not_exists ../${sources.newlib.pname}-${sources.newlib.version}/libgloss libgloss
        ${scripts.symlink}/bin/symlink_if_not_exists ../${dependencies.mpc.pname}-${dependencies.mpc.version} ${dependencies.mpc.pname}
        ${scripts.symlink}/bin/symlink_if_not_exists ../${dependencies.mpfr.pname}-${dependencies.mpfr.version} ${dependencies.mpfr.pname}
        ${scripts.symlink}/bin/symlink_if_not_exists ../${dependencies.gmp.pname}-${dependencies.gmp.version} ${dependencies.gmp.pname}
        ${scripts.symlink}/bin/symlink_if_not_exists ../${dependencies.isl.pname}-${dependencies.isl.version} ${dependencies.isl.pname}
        mkdir -p build-spu
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
        PROCS="$(nproc --all 2>&1)" || ret=$?
        if [ ! -z $ret ]; then PROCS=4; fi
        make -j $PROCS all && make install
        cd $out
        mv $out/ps3/* $out
        rm -rf $out/ps3 $out/build
      '';
  }
