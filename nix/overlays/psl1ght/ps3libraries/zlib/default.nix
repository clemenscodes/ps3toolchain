{pkgs}: let
  shared = import ../../shared.nix {inherit pkgs;};
in
  pkgs.stdenv.mkDerivation rec {
    pname = "zlib";
    version = "1.2.11";
    name = "${pname}-${version}";
    src = pkgs.fetchurl {
      inherit pname version;
      url = "https://www.zlib.net/fossils/${name}.tar.gz";
      sha256 = "sha256-w+Xp/dUATctUL+2l7k8P8HRGKLr47S3V1m+MoRl8saE=";
    };
    inherit (shared) nativeBuildInputs buildInputs hardeningDisable;
    phases = "installPhase";
    installPhase =
      /*
      bash
      */
      ''
        mkdir -p $out/zlib
        cp -r $src $out/zlib
      '';
  }
