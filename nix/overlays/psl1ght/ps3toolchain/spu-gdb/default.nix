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
    unpackPhase = ''
      export PS3DEV=${placeholder "out"}/ps3
      export PSL1GHT=$PS3DEV
      ${scripts.copy}/bin/copy_if_not_exists ${src} ${name}.tar.xz
      ${scripts.extract}/bin/extract_if_not_exists ${name}.tar.xz xvf gdb-${version}
      cp ${pkgs.gnu-config}/config.guess ${pkgs.gnu-config}/config.sub gdb-${version}
    '';
    patchPhase = ''
      ${scripts.patch}/bin/apply_patch_if_not_applied ${./patches/${pname}-${version}-PS3.patch} gdb-${version}
    '';
    configurePhase = ''
      mkdir -p gdb-${version}/build-ppu
      cd gdb-${version}/build-ppu
      ../configure --prefix="$PS3DEV/spu" --target="spu" \
        --disable-nls \
        --disable-sim \
        --disable-werror
    '';
    buildPhase = ''
      make -j $(nproc --all 2>&1)
    '';
    installPhase = ''
      mkdir -p $out/build $out/ps3
      make libdir=`pwd`/host-libs/lib install
    '';
    fixupPhase = ''
      mv $out/ps3/* $out
      rm -rf $out/build $out/ps3
    '';
  }
