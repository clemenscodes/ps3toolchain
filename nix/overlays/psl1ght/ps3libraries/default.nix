{pkgs}: let
  shared = import ../shared.nix {inherit pkgs;};
  scripts = import ../scripts {inherit pkgs;};
  zlib = import ./zlib {inherit pkgs;};
in
  pkgs.stdenv.mkDerivation rec {
    pname = "ps3libraries";
    version = "psl1ght-2.30.1";
    name = "${pname}-${version}";
    src = pkgs.fetchurl {
      inherit pname version;
      url = "https://github.com/humbertodias/${pname}/tarball/${version}";
      sha256 = "sha256-P7wTjrYO7jZn9JTN+DiLwU5yzw585ISkJHfK5pV/zmg=";
    };
    inherit (shared) nativeBuildInputs buildInputs hardeningDisable;
    phases = "unpackPhase installPhase";
    unpackPhase = ''
      cp -r ${src} ${name}.tar.gz
      if [ ! -d ${pname}-${version} ]; then
        mkdir -p ${pname}-${version}
        cd ${pname}-${version}
        tar xvf ../${name}.tar.gz --strip-components=1
      fi
      cd ..
    '';
    installPhase = ''
      mkdir -p $out/build
      cp -r ${pname}-${version} $out/build
      ${scripts.symlinks}/bin/create_symlinks ${zlib} $out
    '';
    passthru = {
      inherit
        zlib
        ;
    };
  }
