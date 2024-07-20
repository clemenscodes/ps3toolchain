{pkgs}: let
  scripts = import ../../scripts {inherit pkgs;};
  shared = import ../../shared.nix {inherit pkgs;};
in
  pkgs.stdenv.mkDerivation rec {
    inherit (shared) nativeBuildInputs buildInputs hardeningDisable;
    pname = "spu-gdb";
    version = "8.3.1";
    name = "${pname}-${version}-PS3";
    src = pkgs.fetchurl {
      inherit pname version;
      url = "https://ftp.gnu.org/gnu/gdb/gdb-${version}.tar.xz";
      sha256 = "sha256-HlW0183KezS+EvTOrmUWI6pzsv1kAVIxP59mpxSXV8Q=";
    };
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
        ${scripts.copy}/bin/copy_if_not_exists ${src} ${name}.tar.xz
        ${scripts.extract}/bin/extract_if_not_exists ${name}.tar.xz xvf gdb-${version}
        ${scripts.patch}/bin/apply_patch_if_not_applied ${./patches/gdb-${version}-PS3.patch} gdb-${version}
        cp ${pkgs.gnu-config}/config.guess ${pkgs.gnu-config}/config.sub gdb-${version}
        mkdir -p gdb-${version}/build-spu
        cd gdb-${version}/build-spu
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
