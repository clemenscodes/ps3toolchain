{pkgs}: rec {
  ps3libraries = with ps3libraries; {
    pname = "ps3libraries";
    version = "psl1ght-2.30.1";
    name = "${pname}-${version}.tar.gz";
    src = pkgs.fetchurl {
      inherit pname version;
      url = "https://github.com/humbertodias/${pname}/tarball/${version}";
      sha256 = "sha256-P7wTjrYO7jZn9JTN+DiLwU5yzw585ISkJHfK5pV/zmg=";
    };
  };
  zlib = with zlib; {
    pname = "zlib";
    version = "1.2.11";
    name = "${pname}-${version}.tar.gz";
    src = pkgs.fetchurl {
      inherit pname version;
      url = "https://www.zlib.net/fossils/${name}";
      sha256 = "sha256-P7wTjrYO7jZn9JTN+DiLwU5yzw585ISkJHfK5pV/zmg=";
    };
  };
}
