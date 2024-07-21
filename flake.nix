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
        inherit (import ./nix {inherit pkgs;}) overlays;
        pkgs = import nixpkgs {
          inherit system overlays;
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
          overlays = {
            default = import ./nix/overlays/psl1ght {inherit pkgs;};
          };
        }
    );
}
