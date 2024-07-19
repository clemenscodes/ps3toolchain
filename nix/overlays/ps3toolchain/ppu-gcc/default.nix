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
    cp -r ${src} ${name}
    cp -r ${sources.newlib.src} ${sources.newlib.name}
    cp -r ${dependencies.mpc.src} ${dependencies.mpc.name}
    cp -r ${dependencies.mpfr.src} ${dependencies.mpfr.name}
    cp -r ${dependencies.gmp.src} ${dependencies.gmp.name}
    cp -r ${dependencies.isl.src} ${dependencies.isl.name}
    tar xfvJ ${name}
    tar xfvz ${sources.newlib.name}
    tar xfv ${dependencies.mpc.name}
    tar xfvj ${dependencies.mpfr.name}
    tar xfvj ${dependencies.gmp.name}
    tar xfvj ${dependencies.isl.name}
    cat ${./patches/${pname}-${version}-PS3-PPU.patch} | patch -p1 -d ${pname}-${version}
    cat ${./patches/${sources.newlib.pname}-${sources.newlib.version}-PS3.patch} | patch -p1 -d ${sources.newlib.pname}-${sources.newlib.version}
    cp ${pkgs.gnu-config}/config.guess ${pkgs.gnu-config}/config.sub ${pname}-${version}
    cd ${pname}-${version}
    ln -s ../${sources.newlib.pname}-${sources.newlib.version}/newlib newlib
    ln -s ../${sources.newlib.pname}-${sources.newlib.version}/libgloss libgloss
    ln -s ../${dependencies.mpc.pname}-${dependencies.mpc.version} ${dependencies.mpc.pname}
    ln -s ../${dependencies.mpfr.pname}-${dependencies.mpfr.version} ${dependencies.mpfr.pname}
    ln -s ../${dependencies.gmp.pname}-${dependencies.gmp.version} ${dependencies.gmp.pname}
    ln -s ../${dependencies.isl.pname}-${dependencies.isl.version} ${dependencies.isl.pname}
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
