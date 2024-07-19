{
  pkgs,
  sources,
}:
with sources.ppu-binutils;
/*
bash
*/
  ''
    cd $out/build
    cp -r ${src} ${name}
    tar xvfj ${name}
    cat ${./patches/${pname}-${version}-PS3-PPU.patch} | patch -p1 -d ${pname}-${version}
    cp ${pkgs.gnu-config}/config.guess ${pkgs.gnu-config}/config.sub ${pname}-${version}
    mkdir -p ${pname}-${version}/build-ppu
    cd ${pname}-${version}/build-ppu
    ../configure --prefix="$PS3DEV/ppu" --target="powerpc64-ps3-elf" \
      --disable-nls \
      --disable-shared \
      --disable-debug \
      --disable-dependency-tracking \
      --disable-werror \
      --with-gcc \
      --with-gnu-as \
      --with-gnu-ld
    make -j $(nproc --all 2>&1)
    make libdir=`pwd`/host-libs/lib install
  ''
