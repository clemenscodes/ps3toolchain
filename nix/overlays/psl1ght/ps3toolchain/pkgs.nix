{pkgs}: {
  ppu-binutils = import ./ppu-binutils {inherit pkgs;};
  spu-binutils = import ./spu-binutils {inherit pkgs;};
  ppu-gcc = import ./ppu-gcc {inherit pkgs;};
  spu-gcc = import ./spu-gcc {inherit pkgs;};
  ppu-gdb = import ./ppu-gdb {inherit pkgs;};
  spu-gdb = import ./spu-gdb {inherit pkgs;};
}
