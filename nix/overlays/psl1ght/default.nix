{pkgs}: let
  ps3toolchain = import ./ps3toolchain {inherit pkgs;};
  ps3libraries = import ./ps3libraries {inherit pkgs;};
  scripts = import ./scripts {inherit pkgs;};
  shared = import ./shared.nix {inherit pkgs;};
in (final: prev: {
  psl1ght = prev.stdenv.mkDerivation rec {
    pname = "PSL1GHT";
    version = "e965e3d895e13f4d6118e14556e7791967060ce6";
    name = "${pname}-${version}";
    src = prev.fetchurl {
      inherit pname version;
      url = "https://github.com/ps3dev/${pname}/tarball/${version}";
      sha256 = "sha256-bLrSAZyhoglKcTzKo+zPCPSfO4TmzKTM1dNBE8rtiXY=";
    };
    nativeBuildInputs = shared.nativeBuildInputs;
    inherit (shared) buildInputs hardeningDisable;
    phases = "unpackPhase buildPhase installPhase fixupPhase";
    unpackPhase = ''
      export PS3DEV=${placeholder "out"}
      export PSL1GHT=$PS3DEV
      export PATH="$PATH:`pwd`/ppu/bin:`pwd`/spu/bin"
      mkdir -p build
      cd build
      cp -r ${src} ${name}.tar.gz;
      if [ ! -d ${pname}-${version} ]; then
        mkdir -p ${pname}-${version}
        cd ${pname}-${version}
        tar xvf ../${name}.tar.gz --strip-components=1
      fi
      cd ../..
      ${scripts.symlinks}/bin/create_symlinks ${ps3toolchain.ppu-binutils} $PS3DEV
      ${scripts.symlinks}/bin/create_symlinks ${ps3toolchain.ppu-gcc} $PS3DEV
      ${scripts.symlinks}/bin/create_symlinks ${ps3toolchain.ppu-gdb} $PS3DEV
      ${scripts.symlinks}/bin/create_symlinks ${ps3toolchain.spu-binutils} $PS3DEV
      ${scripts.symlinks}/bin/create_symlinks ${ps3toolchain.spu-gcc} $PS3DEV
      ${scripts.symlinks}/bin/create_symlinks ${ps3toolchain.spu-gdb} $PS3DEV
      ln -s $PS3DEV/ppu/powerpc64-ps3-elf $PS3DEV/ppu/ppu
      cd $PS3DEV/ppu/bin
      for i in `ls powerpc64-ps3-elf-* | cut -c19-`; do
        ln -s $(realpath powerpc64-ps3-elf-$i) ppu-$i
      done
      cd -
    '';
    buildPhase = ''
      cd build/${pname}-${version}
      make install-ctrl
      make
    '';
    installPhase = ''
      mkdir -p $out/ppu/ppu/lib
      make install
    '';
    fixupPhase = ''
      rm $out/ppu/bin/* $out/spu/bin/*
      ${prev.rsync}/bin/rsync -rLtvh ${ps3toolchain.ppu-binutils}/ppu/bin/* $out/ppu/bin
      ${prev.rsync}/bin/rsync -rLtvh ${ps3toolchain.ppu-gcc}/ppu/bin/* $out/ppu/bin
      ${prev.rsync}/bin/rsync -rLtvh ${ps3toolchain.ppu-gdb}/ppu/bin/* $out/ppu/bin
      ${prev.rsync}/bin/rsync -rLtvh ${ps3toolchain.spu-binutils}/spu/bin/* $out/spu/bin
      ${prev.rsync}/bin/rsync -rLtvh ${ps3toolchain.spu-gcc}/spu/bin/* $out/spu/bin
      ${prev.rsync}/bin/rsync -rLtvh ${ps3toolchain.spu-gdb}/spu/bin/* $out/spu/bin
      cd $out/ppu/bin
      for i in `ls powerpc64-ps3-elf-* | cut -c19-`; do
        ln -s $(realpath powerpc64-ps3-elf-$i) ppu-$i
      done
      ${prev.rsync}/bin/rsync -rLtvh ${ps3libraries}/* $out/portlibs
    '';
    passthru = {
      inherit
        ps3toolchain
        ps3libraries
        ;
    };
  };
})
