{
  pkgs,
  sources,
}: {
  binutils = import ./binutils {inherit pkgs sources;};
  gcc = import ./gcc {inherit pkgs sources;};
  gdb = import ./gdb {inherit pkgs sources;};
}
