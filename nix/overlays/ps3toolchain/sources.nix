{pkgs}: rec {
  binutils = with binutils; {
    pname = "binutils";
    version = "2.42";
    name = "${pname}-${version}.tar.bz2";
    src = pkgs.fetchurl {
      inherit pname version;
      url = "https://ftp.gnu.org/gnu/${pname}/${name}";
      sha256 = "sha256-qlSFDr2lBkxyzU7C2bBWwpQlKZFIY1DZqXqypt/frxI=";
    };
  };
  newlib = with newlib; {
    pname = "newlib";
    version = "1.20.0";
    name = "${pname}-${version}.tar.gz";
    src = pkgs.fetchurl {
      inherit pname version;
      url = "ftp://sourceware.org/pub/${pname}/${name}";
      sha256 = "14pn7y1dm8vsm9lszfgkcz3sgdgsv1lxmpf2prbqq9s4fa2b4i66";
    };
  };
  gcc = with gcc; {
    pname = "gcc";
    version = "13.2.0";
    name = "${pname}-${version}.tar.xz";
    src = pkgs.fetchurl {
      inherit pname version;
      url = "https://ftp.gnu.org/gnu/${pname}/${pname}-${version}/${name}";
      sha256 = "1nj3qyswcgc650sl3h0480a171ixp33ca13zl90p61m689jffxg2";
    };
    dependencies = with dependencies; let
      mkUrl = pkg: "https://gcc.gnu.org/pub/gcc/infrastructure/${pkg}";
    in {
      mpfr = {
        pname = "mpfr";
        version = "4.1.0";
        name = "${mpfr.pname}-${mpfr.version}.tar.bz2";
        src = pkgs.fetchurl {
          inherit (mpfr) pname version;
          url = mkUrl mpfr.name;
          sha256 = "sha256-/s7S1DDdWpeAX6KJ/tP8j/KwlMAtBSh/1hM+fx8OySY=";
        };
      };
      mpc = {
        pname = "mpc";
        version = "1.2.1";
        name = "${mpc.pname}-${mpc.version}.tar.gz";
        src = pkgs.fetchurl {
          inherit (mpc) pname version;
          url = mkUrl mpc.name;
          sha256 = "sha256-F1A9LDld/PEGtiLcFCaDwRmUMdCVNnxqrLpu7DA0BFk=";
        };
      };
      gmp = {
        pname = "gmp";
        version = "6.2.1";
        name = "${gmp.pname}-${gmp.version}.tar.bz2";
        src = pkgs.fetchurl {
          inherit (gmp) pname version;
          url = mkUrl gmp.name;
          sha256 = "sha256-6ukya+tBWMOG45o1aBgDG9KPMSTPkV+MWx3Ex6NrTXw=";
        };
      };
      isl = {
        pname = "isl";
        version = "0.24";
        name = "${isl.pname}-${isl.version}.tar.bz2";
        src = pkgs.fetchurl {
          inherit (isl) pname version;
          url = mkUrl isl.name;
          sha256 = "sha256-/PeN2WVsEOuM+fvV9ZoLawE4YgX+GTSzsoegoYmBRcA=";
        };
      };
    };
  };
  gdb = with gdb; {
    pname = "gdb";
    version = "8.3.1";
    name = "${pname}-${version}.tar.xz";
    src = pkgs.fetchurl {
      inherit pname version;
      url = "https://ftp.gnu.org/gnu/${pname}/${name}";
      sha256 = "sha256-HlW0183KezS+EvTOrmUWI6pzsv1kAVIxP59mpxSXV8Q=";
    };
  };
}
