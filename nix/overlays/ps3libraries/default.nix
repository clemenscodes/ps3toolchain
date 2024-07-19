{pkgs}: let
  sources = import ./sources.nix {inherit pkgs;};
  install = import ./install.nix {inherit pkgs sources;};
in
  with sources.ps3libraries; (final: prev: {
    ps3libraries = with install;
      prev.stdenv.mkDerivation {
        name = "ps3libraries";
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
            export PATH="$PATH:${pkgs.ps3toolchain}/bin:${pkgs.ps3toolchain}/ppu/bin:${pkgs.ps3toolchain}/spu/bin:${pkgs.psl1ght}/bin:${pkgs.psl1ght}/ppu/bin:${pkgs.psl1ght}/spu/bin"
            mkdir -p $out/build $out/ppu/ppu/lib
            cd $out/build
            cp -r ${src} ${name}
            if [ ! -d ${pname}-${version} ]; then
              mkdir -p ${pname}-${version}
              cd ${pname}-${version}
              tar xvf ../${name} --strip-components=1
            fi
            cd $out/build/${pname}-${version}
          '';
      };
  })
