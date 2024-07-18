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
        pkgs = import nixpkgs {inherit system;};
      in {
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
            export PATH="$PATH:$PS3DEV/bin:$PS3DEV/ppu/bin:$PS3DEV/spu/bin"
          '';
        };
      }
    );
}
