{pkgs}: let
  scripts = import ../scripts {inherit pkgs;};
  sources = import ../sources.nix {inherit pkgs;};
  toolchainPkgs = import ../pkgs.nix {inherit pkgs sources;};
  shared = import ../shared.nix {inherit pkgs;};
in (final: prev:
    with prev; {
      ps3toolchain = stdenv.mkDerivation {
        inherit (shared) nativeBuildInputs buildInputs hardeningDisable;
        name = "ps3toolchain";
        phases = "installPhase";
        installPhase = ''
          mkdir -p $out
          ${scripts.symlinks}/bin/create_symlinks ${toolchainPkgs.ppu-binutils} $out
          ${scripts.symlinks}/bin/create_symlinks ${toolchainPkgs.spu-binutils} $out
          ${scripts.symlinks}/bin/create_symlinks ${toolchainPkgs.ppu-gcc} $out
          ${scripts.symlinks}/bin/create_symlinks ${toolchainPkgs.spu-gcc} $out
          ${scripts.symlinks}/bin/create_symlinks ${toolchainPkgs.ppu-gdb} $out
          ${scripts.symlinks}/bin/create_symlinks ${toolchainPkgs.spu-gdb} $out
        '';
      };
    })
