{pkgs}: let
  sources = import ./sources.nix {inherit pkgs;};
in
  with sources.psl1ght; (final: prev: {
    psl1ght = prev.stdenv.mkDerivation {
      name = "psl1ght";
      nativeBuildInputs = with prev; [
        cmake
        pkg-config
        libelf
        gmp.dev
        ncurses
        ncurses.dev
        zlib
        zlib.dev
        autoconf
        automake
        bison
        flex
        bzip2
        gettext
        openssl
        libtool
        gnumake
        gnupatch
        texinfo
        nvidia_cg_toolkit
      ];
      buildInputs = with prev; [wget python310];
      hardeningDisable = ["format"];
      phases = "installPhase";
      installPhase =
        /*
        bash
        */
        ''
          mkdir -p $out
          export PS3DEV="$out"
          export PSL1GHT="$PS3DEV"
          export PATH="$PATH:${pkgs.ps3toolchain}/bin:${pkgs.ps3toolchain}/ppu/bin:${pkgs.ps3toolchain}/spu/bin"
          mkdir -p $out/build $out/ppu/ppu/lib
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
        '';
    };
  })
