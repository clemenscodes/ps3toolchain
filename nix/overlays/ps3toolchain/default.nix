{pkgs}: let
  sources = import ../sources.nix {inherit pkgs;};
  toolchainPkgs = import ../pkgs.nix {inherit pkgs sources;};
  shared = import ../shared.nix {inherit pkgs;};
in (final: prev:
    with prev; {
      ps3toolchain = stdenv.mkDerivation {
        inherit (shared) nativeBuildInputs buildInputs hardeningDisable;
        name = "ps3toolchain";
        phases = "installPhase";
        buildPackages = with toolchainPkgs; [
          ppu-binutils
          ppu-gcc
          ppu-gdb
          spu-binutils
          spu-gcc
          spu-gdb
        ];
        installPhase = ''
          mkdir -p $out/build
          # cd $PS3DEV/ppu
          # if [ ! -d ppu -a ! -f ppu -a ! -h ppu -a -d powerpc64-ps3-elf ]; then
          #   ln -s powerpc64-ps3-elf ppu
          # fi
          # cd $PS3DEV/ppu/bin
          # for i in `ls powerpc64-ps3-elf-* | cut -c19-`; do
          #   if [ ! -f ppu-$i -a ! -h ppu-$i -a -f powerpc64-ps3-elf-$i ]; then
          #     ln -s powerpc64-ps3-elf-$i ppu-$i
          #   fi
          # done
          # mv $out/ps3/* $out
          # rm -rf $out/build $out/ps3
        '';
      };
    })
