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
                  installPhase = import ./nix {inherit pkgs;};
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
