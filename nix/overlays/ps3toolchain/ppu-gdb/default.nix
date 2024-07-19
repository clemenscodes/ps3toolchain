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
    copy_if_not_exists ${src} ${name}
    extract_if_not_exists ${name} xvf ${pname}-${version}
    apply_patch_if_not_applied ${./patches/${pname}-${version}-PS3.patch} ${pname}-${version}
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
