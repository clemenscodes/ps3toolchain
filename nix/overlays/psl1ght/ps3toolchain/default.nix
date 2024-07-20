{pkgs}: let
  ppu-binutils = import ./ppu-binutils {inherit pkgs;};
  spu-binutils = import ./spu-binutils {inherit pkgs;};
  ppu-gcc = import ./ppu-gcc {inherit pkgs;};
  spu-gcc = import ./spu-gcc {inherit pkgs;};
  ppu-gdb = import ./ppu-gdb {inherit pkgs;};
  spu-gdb = import ./spu-gdb {inherit pkgs;};
  shared = import ../shared.nix {inherit pkgs;};
in
  pkgs.stdenv.mkDerivation {
    name = "ps3toolchain";
    phases = "installPhase";
    inherit (shared) nativeBuildInputs buildInputs hardeningDisable;
    installPhase = ''
      mkdir -p $out
    '';
    passthru = {
      inherit
        ppu-binutils
        spu-binutils
        ppu-gcc
        spu-gcc
        ppu-gdb
        spu-gdb
        ;
    };
  }
