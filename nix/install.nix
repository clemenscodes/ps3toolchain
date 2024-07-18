{
  pkgs,
  sources,
}: {
  ps3toolchain = import ./ps3toolchain;
  binutils = import ./binutils {inherit pkgs sources;};
  gcc = import ./gcc {inherit pkgs sources;};
  gdb = import ./gdb {inherit pkgs sources;};
}
