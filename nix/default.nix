{pkgs}: let
  sources = import ./sources.nix {inherit pkgs;};
  install = import ./install.nix {inherit pkgs sources;};
in
  with install;
    ps3toolchain
    + binutils
    + gcc
    + gdb
