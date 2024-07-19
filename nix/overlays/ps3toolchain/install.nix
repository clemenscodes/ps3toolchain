{
  pkgs,
  sources,
}: {
  ppu-binutils = import ./ppu-binutils {inherit pkgs sources;};
  spu-binutils = import ./spu-binutils {inherit pkgs sources;};
  ppu-gcc = import ./ppu-gcc {inherit pkgs sources;};
  spu-gcc = import ./spu-gcc {inherit pkgs sources;};
  ppu-gdb = import ./ppu-gdb {inherit pkgs sources;};
  spu-gdb = import ./spu-gdb {inherit pkgs sources;};
}
