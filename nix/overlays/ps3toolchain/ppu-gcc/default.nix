{
  pkgs,
  sources,
}:
with sources.ppu-gcc;
/*
bash
*/
  ''
    cd $out/build
    copy_if_not_exists ${src} ${name}
    copy_if_not_exists ${sources.newlib.src} ${sources.newlib.name}
    copy_if_not_exists ${dependencies.mpc.src} ${dependencies.mpc.name}
    copy_if_not_exists ${dependencies.mpfr.src} ${dependencies.mpfr.name}
    copy_if_not_exists ${dependencies.gmp.src} ${dependencies.gmp.name}
    copy_if_not_exists ${dependencies.isl.src} ${dependencies.isl.name}
    extract_if_not_exists ${name} xfvJ ${pname}-${version}
    extract_if_not_exists ${sources.newlib.name} xfvz ${sources.newlib.pname}-${sources.newlib.version}
    extract_if_not_exists ${dependencies.mpc.name} xfv ${dependencies.mpc.pname}-${dependencies.mpc.version}
    extract_if_not_exists ${dependencies.mpfr.name} xfvj ${dependencies.mpfr.pname}-${dependencies.mpfr.version}
    extract_if_not_exists ${dependencies.gmp.name} xfvj ${dependencies.gmp.pname}-${dependencies.gmp.version}
    extract_if_not_exists ${dependencies.isl.name} xfvj ${dependencies.isl.pname}-${dependencies.isl.version}
    apply_patch_if_not_applied ${./patches/${pname}-${version}-PS3-PPU.patch} ./${pname}-${version}
    apply_patch_if_not_applied ${./patches/${sources.newlib.pname}-${sources.newlib.version}-PS3.patch} ./${sources.newlib.pname}-${sources.newlib.version}
    cp ${pkgs.gnu-config}/config.guess ${pkgs.gnu-config}/config.sub ${pname}-${version}
    cd ${pname}-${version}
    symlink_if_not_exists ../${sources.newlib.pname}-${sources.newlib.version}/newlib newlib
    symlink_if_not_exists ../${sources.newlib.pname}-${sources.newlib.version}/libgloss libgloss
    symlink_if_not_exists ../${dependencies.mpc.pname}-${dependencies.mpc.version} ${dependencies.mpc.pname}
    symlink_if_not_exists ../${dependencies.mpfr.pname}-${dependencies.mpfr.version} ${dependencies.mpfr.pname}
    symlink_if_not_exists ../${dependencies.gmp.pname}-${dependencies.gmp.version} ${dependencies.gmp.pname}
    symlink_if_not_exists ../${dependencies.isl.pname}-${dependencies.isl.version} ${dependencies.isl.pname}
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
  ''
