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
          mkdir -p $out/build $out/ppu/ppu/lib
          export PS3DEV="$out"
          export PSL1GHT="$PS3DEV"
          export PATH="$PATH:${ps3toolchain}/ppu/bin:${ps3toolchain}/spu/bin"
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
          rm -rf $out/build
          ${scripts.symlinks}/bin/create_symlinks ${ps3toolchain} $out
        '';
    };
  })
