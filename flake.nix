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
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (self: pkgs:
              with pkgs; {
                ps3toolchain = stdenv.mkDerivation {
                  inherit nativeBuildInputs buildInputs hardeningDisable;
                  name = "ps3toolchain";
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
                    cp -r ${sources.gcc.dependencies.mpc.src} ${sources.gcc.dependencies.mpc.name}
                    cp -r ${sources.gcc.dependencies.mpfr.src} ${sources.gcc.dependencies.mpfr.name}
                    cp -r ${sources.gcc.dependencies.gmp.src} ${sources.gcc.dependencies.gmp.name}
                    cp -r ${sources.gcc.dependencies.isl.src} ${sources.gcc.dependencies.isl.name}
                    tar xfvJ ${sources.gcc.name}
                    tar xfvz ${sources.newlib.name}
                    tar xfv ${sources.gcc.dependencies.mpc.name}
                    tar xfvj ${sources.gcc.dependencies.mpfr.name}
                    tar xfvj ${sources.gcc.dependencies.gmp.name}
                    tar xfvj ${sources.gcc.dependencies.isl.name}
                    cat ${./patches/${sources.gcc.pname}-${sources.gcc.version}-PS3-PPU.patch} | patch -p1 -d ${sources.gcc.pname}-${sources.gcc.version}
                    cat ${./patches/${sources.newlib.pname}-${sources.newlib.version}-PS3.patch} | patch -p1 -d ${sources.newlib.pname}-${sources.newlib.version}
                    cd ${sources.gcc.pname}-${sources.gcc.version}
                    ln -s ../${sources.newlib.pname}-${sources.newlib.version}/newlib newlib
                    ln -s ../${sources.newlib.pname}-${sources.newlib.version}/libgloss libgloss
                    ln -s ../${sources.gcc.dependencies.mpc.pname}-${sources.gcc.dependencies.mpc.version} ${sources.gcc.dependencies.mpc.pname}
                    ln -s ../${sources.gcc.dependencies.mpfr.pname}-${sources.gcc.dependencies.mpfr.version} ${sources.gcc.dependencies.mpfr.pname}
                    ln -s ../${sources.gcc.dependencies.gmp.pname}-${sources.gcc.dependencies.gmp.version} ${sources.gcc.dependencies.gmp.pname}
                    ln -s ../${sources.gcc.dependencies.isl.pname}-${sources.gcc.dependencies.isl.version} ${sources.gcc.dependencies.isl.pname}
                    mkdir build-ppu
                    cd build-ppu
                    ../configure --prefix="$PS3DEV/ppu" --target="powerpc64-ps3-elf" \
                      --with-cpu="cell" \
                      --with-newlib \
                      --with-system-zlib \
                      --enable-languages="c,c++" \
                      --enable-long-double-128 \
                      --enable-lto \
                      --enable-threads \
                      --enable-newlib-multithread \
                      --enable-newlib-hw-fp \
                      --disable-dependency-tracking \
                      --disable-libcc1 \
                      --disable-multilib \
                      --disable-nls \
                      --disable-shared \
                      --disable-win32-registry
                    PROCS="$(nproc --all 2>&1)" || ret=$?
                    if [ ! -z $ret ]; then PROCS=4; fi
                    make -j $PROCS all && make install
                  '';
                };
              })
          ];
        };
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
        hardeningDisable = ["format"];
        sources = import ./sources.nix {inherit pkgs;};
      in {
        defaultPackage = pkgs.ps3toolchain;
        devShell = pkgs.mkShell {
          inherit nativeBuildInputs buildInputs hardeningDisable;
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
