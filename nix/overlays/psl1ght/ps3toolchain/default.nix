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
    inherit (shared) nativeBuildInputs buildInputs hardeningDisable;
    passthru = {inherit ppu-binutils spu-binutils ppu-gcc spu-gcc ppu-gdb spu-gdb;};
    name = "ps3toolchain";
    phases = "installPhase";
    installPhase = ''
      mkdir -p $out
    '';
  }
