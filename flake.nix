{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };
  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        sources = {
          binutils = {
            pname = "binutils";
            version = "2.42";
            name = "${sources.binutils.pname}-${sources.binutils.version}.tar.bz2";
            src = with sources.binutils;
              pkgs.fetchurl {
                inherit pname version;
                url = "https://ftp.gnu.org/gnu/${pname}/${name}";
                sha256 = "sha256-qlSFDr2lBkxyzU7C2bBWwpQlKZFIY1DZqXqypt/frxI=";
              };
          };
          newlib = {
            pname = "newlib";
            version = "1.20.0";
            name = "${sources.newlib.pname}-${sources.binutils.version}.tar.gz";
            src = with sources.newlib;
              pkgs.fetchurl {
                inherit pname version;
                url = "ftp://sourceware.org/pub/${pname}/${name}";
                sha256 = "14pn7y1dm8vsm9lszfgkcz3sgdgsv1lxmpf2prbqq9s4fa2b4i66";
              };
          };
          gcc = {
            pname = "gcc";
            version = "13.2.0";
            name = "${sources.gcc.pname}-${sources.gcc.version}.tar.xz";
            src = with sources.gcc;
              pkgs.fetchurl {
                inherit pname version;
                url = "https://ftp.gnu.org/gnu/${pname}/${pname}-${version}/${name}";
                sha256 = "1nj3qyswcgc650sl3h0480a171ixp33ca13zl90p61m689jffxg2";
              };
          };
        };
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (self: pkgs:
              with pkgs; {
                ps3toolchain = stdenv.mkDerivation {
                  name = "ps3toolchain";
                  nativeBuildInputs = [
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
                  buildInputs = [wget python310];
                  hardeningDisable = ["format"];
                  phases = "installPhase";
                  installPhase = ''
                    mkdir -p $out/ps3 $out/build
                    export PS3DEV="$out/ps3"
                    export PSL1GHT="$PS3DEV"
                    cd $out/build
                    cp -r ${sources.binutils.src} ${sources.binutils.name}
                    tar xvfj ${sources.binutils.name}
                    cat ${./patches/${sources.binutils.pname}-${sources.binutils.version}-PS3-PPU.patch} | patch -p1 -d ${sources.binutils.pname}-${sources.binutils.version}
                    cp ${gnu-config}/config.guess ${gnu-config}/config.sub ${sources.binutils.pname}-${sources.binutils.version}
                    mkdir -p ${sources.binutils.pname}-${sources.binutils.version}/build-ppu
                    cd ${sources.binutils.pname}-${sources.binutils.version}/build-ppu
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
                    cd $out/build
                    cp -r ${sources.gcc.src} ${sources.gcc.name}
                    cp -r ${sources.newlib.src} ${sources.newlib.name}
                    tar xfvJ ${sources.gcc.name}
                    tar xfvz ${sources.newlib.name}
                    cat ${./patches/${sources.gcc.pname}-${sources.gcc.version}-PS3-PPU.patch} | patch -p1 -d ${sources.gcc.pname}-${sources.gcc.version}
                    cat ${./patches/${sources.newlib.pname}-${sources.newlib.version}-PS3.patch} | patch -p1 -d ${sources.newlib.pname}-${sources.newlib.version}
                    cd ${sources.gcc.pname}-${sources.gcc.version}
                    ln -s ../${sources.newlib.pname}-${sources.newlib.version}/newlib newlib
                    ln -s ../${sources.newlib.pname}-${sources.newlib.version}/libgloss libgloss
                  '';
                };
              })
          ];
        };
      in {
        defaultPackage = pkgs.ps3toolchain;
        devShell = pkgs.mkShell {
          hardeningDisable = ["format"];
          nativeBuildInputs = with pkgs; [
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
          buildInputs = with pkgs; [wget python310];
          shellHook = ''
            export PS3DEV="$PWD/ps3"
            export PSL1GHT="$PS3DEV"
            export PATH="$PATH:$PS3DEV/bin:$PS3DEV/ppu/bin:$PS3DEV/spu/bin:$PS3DEV/portlibs/ppu/bin"
            export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$PS3DEV/portlibs/ppu/lib/pkgconfig"
          '';
        };
      }
    );
}
