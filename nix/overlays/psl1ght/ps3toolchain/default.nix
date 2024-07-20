{pkgs}: let
  sources = import ./sources.nix {inherit pkgs;};
  scripts = import ../scripts {inherit pkgs;};
  shared = import ../shared.nix {inherit pkgs;};
in
  with import ./pkgs.nix {inherit pkgs sources;};
    pkgs.stdenv.mkDerivation {
      inherit (shared) nativeBuildInputs buildInputs hardeningDisable;
      name = "ps3toolchain";
      phases = "installPhase";
      installPhase = ''
        mkdir -p $out
        ${scripts.symlinks}/bin/create_symlinks ${ppu-binutils} $out
        ${scripts.symlinks}/bin/create_symlinks ${spu-binutils} $out
        ${scripts.symlinks}/bin/create_symlinks ${ppu-gcc} $out
        ${scripts.symlinks}/bin/create_symlinks ${spu-gcc} $out
        ${scripts.symlinks}/bin/create_symlinks ${ppu-gdb} $out
        ${scripts.symlinks}/bin/create_symlinks ${spu-gdb} $out
      '';
    }
