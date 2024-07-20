{
  pkgs,
  sources,
}:
with sources.ppu-binutils; let
  scripts = import ../../scripts {inherit pkgs;};
  shared = import ../../shared.nix {inherit pkgs;};
in
  pkgs.stdenv.mkDerivation {
    inherit (shared) nativeBuildInputs buildInputs hardeningDisable;
    name = "ppu-binutils";
    phases = "installPhase";
    installPhase =
      /*
      bash
      */
      ''
        mkdir -p $out/build $out/ps3
        export PS3DEV="$out/ps3"
        export PSL1GHT="$PS3DEV"
        cd $out/build
        ${scripts.copy}/bin/copy_if_not_exists ${src} ${name}
        ${scripts.extract}/bin/extract_if_not_exists ${name} xvfj ${pname}-${version}
        ${scripts.patch}/bin/apply_patch_if_not_applied ${./patches/${pname}-${version}-PS3-PPU.patch} ${pname}-${version}
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
        cd $out
        mv $out/ps3/* $out
        rm -rf $out/build $out/ps3
      '';
  }
