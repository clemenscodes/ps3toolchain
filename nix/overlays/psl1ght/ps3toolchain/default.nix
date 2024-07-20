{pkgs}: let
  shared = import ../shared.nix {inherit pkgs;};
in
  with import ./pkgs.nix {inherit pkgs;};
    pkgs.stdenv.mkDerivation {
      inherit (shared) nativeBuildInputs buildInputs hardeningDisable;
      passthru = {inherit ppu-binutils spu-binutils ppu-gcc spu-gcc ppu-gdb spu-gdb;};
      name = "ps3toolchain";
      phases = "installPhase";
      installPhase = ''
        mkdir -p $out
      '';
    }
