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
        inherit (pkgs) lib;
        pkgs = import nixpkgs {
          inherit system;
          overlays = import ./nix/overlays {inherit pkgs;};
          config = {
            allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) ["nvidia-cg-toolkit"];
          };
        };
      in {
        defaultPackage = pkgs.psl1ght;
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [psl1ght];
        };
      }
    );
}
