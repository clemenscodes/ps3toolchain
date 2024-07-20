{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };
  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = import ./nix/overlays {inherit pkgs;};
          config = {
            allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) ["nvidia-cg-toolkit"];
          };
        };
      in
        with pkgs; {
          defaultPackage = psl1ght;
          devShell = mkShell {
            buildInputs = [psl1ght];
            shellHook = ''
              export PS3DEV=${psl1ght}
              export PSL1GHT=$PS3DEV
              export PATH=$PATH:${psl1ght}/bin
              export PATH=$PATH:${psl1ght}/ppu/bin
              export PATH=$PATH:${psl1ght}/spu/bin
            '';
          };
        }
    );
}
