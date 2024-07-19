{
  pkgs,
  sources,
}:
with sources.spu-binutils;
/*
bash
*/
  ''
    cd $out/build
    [ ! -d ${name} ] && cp -r ${src} ${name}
    tar xvfj ${name}
    cat ${./patches/${pname}-${version}-PS3-SPU.patch} | patch -p1 -d ${pname}-${version}
    cp ${pkgs.gnu-config}/config.guess ${pkgs.gnu-config}/config.sub ${pname}-${version}
    mkdir -p ${pname}-${version}/build-spu
    cd ${pname}-${version}/build-spu
    ../configure --prefix="$PS3DEV/spu" --target="spu" \
      --disable-nls \
      --disable-shared \
      --disable-debug \
      --disable-dependency-tracking \
      --disable-werror \
      --with-gcc \
      --with-gnu-as \
      --with-gnu-ld \
    --enable-lto
    make -j $(nproc --all 2>&1)
    make libdir=`pwd`/host-libs/lib install
  ''
