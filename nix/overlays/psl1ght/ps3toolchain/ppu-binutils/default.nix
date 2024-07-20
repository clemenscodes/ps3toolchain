{pkgs}: let
  scripts = import ../../scripts {inherit pkgs;};
  shared = import ../../shared.nix {inherit pkgs;};
in
  pkgs.stdenv.mkDerivation rec {
    inherit (shared) nativeBuildInputs buildInputs hardeningDisable;
    pname = "ppu-binutils";
    version = "2.42";
    name = "${pname}-${version}-PS3";
    src = pkgs.fetchurl {
      inherit pname version;
      url = "https://ftp.gnu.org/gnu/binutils/binutils-${version}.tar.bz2";
      sha256 = "sha256-qlSFDr2lBkxyzU7C2bBWwpQlKZFIY1DZqXqypt/frxI=";
    };
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
        ${scripts.copy}/bin/copy_if_not_exists ${src} ${name}.tar.bz2
        ${scripts.extract}/bin/extract_if_not_exists ${name}.tar.bz2 xvfj binutils-${version}
        ${scripts.patch}/bin/apply_patch_if_not_applied ${./patches/${pname}-${version}-PS3.patch} binutils-${version}
        cp ${pkgs.gnu-config}/config.guess ${pkgs.gnu-config}/config.sub binutils-${version}
        mkdir -p binutils-${version}/build-ppu
        cd binutils-${version}/build-ppu
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
