{
  pkgs,
  sources,
}:
with sources.ppu-gdb;
/*
bash
*/
  ''
    cd $out/build
    [ ! -d ${src} ] && cp -r ${src} ${name}
    tar xfv ${name}
    cat ${./patches/${pname}-${version}-PS3.patch} | patch -p1 -d ${pname}-${version}
    cp ${pkgs.gnu-config}/config.guess ${pkgs.gnu-config}/config.sub ${pname}-${version}
    mkdir -p ${pname}-${version}/build-ppu
    cd ${pname}-${version}/build-ppu
    ../configure --prefix="$PS3DEV/ppu" --target="powerpc64-ps3-elf" \
      --disable-multilib \
      --disable-nls \
      --disable-sim \
      --disable-werror
    PROCS="$(nproc --all 2>&1)" || ret=$?
    if [ ! -z $ret ]; then PROCS=4; fi
    make -j $PROCS && make libdir=`pwd`/host-libs/lib install
  ''
