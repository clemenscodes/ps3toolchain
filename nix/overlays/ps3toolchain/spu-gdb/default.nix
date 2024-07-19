{
  pkgs,
  sources,
}:
with sources.spu-gdb;
/*
bash
*/
  ''
    cd $out/build
    copy_if_not_exists ${src} ${name}
    extract_if_not_exists ${name} xvf ${pname}-${version}
    apply_patch_if_not_applied ${./patches/${pname}-${version}-PS3.patch} ${pname}-${version}
    cp ${pkgs.gnu-config}/config.guess ${pkgs.gnu-config}/config.sub ${pname}-${version}
    mkdir -p ${pname}-${version}/build-spu
    cd ${pname}-${version}/build-spu
    ../configure --prefix="$PS3DEV/spu" --target="spu" \
      --disable-nls \
      --disable-sim \
      --disable-werror
    PROCS="$(nproc --all 2>&1)" || ret=$?
    if [ ! -z $ret ]; then PROCS=4; fi
    make -j $PROCS && make libdir=`pwd`/host-libs/lib install
  ''
