{
  pkgs,
  sources,
}: {
  zlib = import ./zlib {inherit pkgs sources;};
}
