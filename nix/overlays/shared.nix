{pkgs}: {
  nativeBuildInputs = with pkgs; [
    cmake
    pkg-config
    libelf
    gmp.dev
    ncurses
    ncurses.dev
    zlib
    zlib.dev
    autoconf
    automake
    bison
    flex
    bzip2
    gettext
    openssl
    libtool
    gnumake
    gnupatch
    texinfo
  ];
  buildInputs = with pkgs; [wget python310];
  hardeningDisable = ["format"];
}
