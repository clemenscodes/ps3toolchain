{
  pkgs,
  sources,
}:
with sources.ppu-gdb; let
  scripts = import ../scripts {inherit pkgs;};
  shared = import ../shared.nix {inherit pkgs;};
in
  pkgs.stdenv.mkDerivation {
    inherit (shared) nativeBuildInputs buildInputs hardeningDisable;
    name = "spu-gdb";
    phases = "installPhase";
    installPhase =
      /*
      bash
      */
      ''
        mkdir -p $out/build $out/ps3
        cd $out/build
        export PS3DEV="$out/ps3"
        export PSL1GHT="$PS3DEV"
        ${scripts.copy}/bin/copy_if_not_exists ${src} ${name}
        ${scripts.extract}/bin/extract_if_not_exists ${name} xvf ${pname}-${version}
        ${scripts.patch}/bin/apply_patch_if_not_applied ${./patches/${pname}-${version}-PS3.patch} ${pname}-${version}
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
        cd $out
        mv $out/ps3/* $out
        rm -rf $out/ps3 $out/build
      '';
  }
