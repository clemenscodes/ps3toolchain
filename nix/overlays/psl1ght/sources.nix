{pkgs}: rec {
  psl1ght = with psl1ght; {
    pname = "PSL1GHT";
    version = "e965e3d895e13f4d6118e14556e7791967060ce6";
    name = "${pname}-${version}.tar.gz";
    src = pkgs.fetchurl {
      inherit pname version;
      url = "https://github.com/ps3dev/${pname}/tarball/${version}";
      sha256 = "sha256-bLrSAZyhoglKcTzKo+zPCPSfO4TmzKTM1dNBE8rtiXY=";
    };
  };
}
