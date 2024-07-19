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
    copy_if_not_exists ${src} ${name}
    extract_if_not_exists ${name} xvfj ${pname}-${version}
    apply_patch_if_not_applied ${./patches/${pname}-${version}-PS3-PPU.patch} ${pname}-${version}
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
