{pkgs}: let
  ps3toolchain = import ./ps3toolchain {inherit pkgs;};
  scripts = import ./scripts {inherit pkgs;};
  sources = import ./sources.nix {inherit pkgs;};
  shared = import ./shared.nix {inherit pkgs;};
in
  with sources.psl1ght; (final: prev: {
    psl1ght = prev.stdenv.mkDerivation {
      name = "psl1ght";
      inherit (shared) buildInputs hardeningDisable;
      nativeBuildInputs = shared.nativeBuildInputs ++ [pkgs.nvidia_cg_toolkit];
      phases = "installPhase";
      installPhase =
        /*
        bash
        */
        ''
          mkdir -p $out/build
          ${scripts.symlinks}/bin/create_symlinks ${ps3toolchain.ppu-binutils} $out
          ${scripts.symlinks}/bin/create_symlinks ${ps3toolchain.ppu-gcc} $out
          ${scripts.symlinks}/bin/create_symlinks ${ps3toolchain.ppu-gdb} $out
          ${scripts.symlinks}/bin/create_symlinks ${ps3toolchain.spu-binutils} $out
          ${scripts.symlinks}/bin/create_symlinks ${ps3toolchain.spu-gcc} $out
          ${scripts.symlinks}/bin/create_symlinks ${ps3toolchain.spu-gdb} $out
          ln -s $out/ppu/powerpc64-ps3-elf $out/ppu/ppu
          cd $out/ppu/bin
          for i in `ls powerpc64-ps3-elf-* | cut -c19-`; do
            ln -s $out/ppu/bin/powerpc64-ps3-elf-$i $out/ppu/bin/ppu-$i
          done
          export PS3DEV="$out"
          export PSL1GHT="$PS3DEV"
          export PATH="$PATH:$out/ppu/bin:$out/spu/bin:$out/bin"
          cd $out/build
          cp -r ${src} ${name}
          if [ ! -d ${pname}-${version} ]; then
            mkdir -p ${pname}-${version}
            cd ${pname}-${version}
            tar xvf ../${name} --strip-components=1
          fi
          cd $out/build/${pname}-${version}
          make install-ctrl
          make
          make install
          rm $out/ppu/bin/powerpc64-ps3-elf-* $out/spu/bin/*
          ${pkgs.rsync}/bin/rsync -rLtvh ${ps3toolchain.ppu-binutils}/ppu/bin/* $out/ppu/bin
          ${pkgs.rsync}/bin/rsync -rLtvh ${ps3toolchain.ppu-gcc}/ppu/bin/* $out/ppu/bin
          ${pkgs.rsync}/bin/rsync -rLtvh ${ps3toolchain.ppu-gdb}/ppu/bin/* $out/ppu/bin
          ${pkgs.rsync}/bin/rsync -rLtvh ${ps3toolchain.spu-binutils}/spu/bin/* $out/spu/bin
          ${pkgs.rsync}/bin/rsync -rLtvh ${ps3toolchain.spu-gcc}/spu/bin/* $out/spu/bin
          ${pkgs.rsync}/bin/rsync -rLtvh ${ps3toolchain.spu-gdb}/spu/bin/* $out/spu/bin
          rm -rf $out/build
        '';
    };
  })
