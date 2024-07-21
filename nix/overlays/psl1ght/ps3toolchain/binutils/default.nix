{
  prefix,
  target,
  stdenv,
  fetchurl,
  gnu-config,
  scripts,
  nativeBuildInputs,
  buildInputs,
  hardeningDisable,
  lib,
  version,
  sha256,
}:
stdenv.mkDerivation rec {
  inherit nativeBuildInputs buildInputs hardeningDisable;
  inherit version;
  pname = "${prefix}-binutils";
  name = "${pname}-${version}-PS3";
  src = fetchurl {
    inherit pname version sha256;
    url = "https://ftp.gnu.org/gnu/binutils/binutils-${version}.tar.bz2";
  };
  unpackPhase = ''
    export PS3DEV=${placeholder "out"}/ps3
    export PSL1GHT=$PS3DEV
    ${scripts.copy}/bin/copy_if_not_exists ${src} ${name}.tar.bz2
    ${scripts.extract}/bin/extract_if_not_exists ${name}.tar.bz2 xvfj binutils-${version}
    cp ${gnu-config}/config.guess ${gnu-config}/config.sub binutils-${version}
  '';
  patchPhase = ''
    ${scripts.patch}/bin/apply_patch_if_not_applied ${./patches/${pname}-${version}-PS3.patch} binutils-${version}
  '';
  configureFlags =
    [
      "--prefix=$PS3DEV/${prefix}"
      "--target=${target}"
      "--disable-nls "
      "--disable-shared"
      "--disable-debug "
      "--disable-dependency-tracking "
      "--disable-werror "
      "--with-gcc "
      "--with-gnu-as"
      "--with-gnu-ld"
    ]
    ++ lib.optional (prefix == "spu") [
      "--enable-lto"
    ];
  configurePhase = ''
    mkdir -p binutils-${version}/build-${prefix}
    cd binutils-${version}/build-${prefix}
    ../configure $configureFlags
  '';
  buildPhase = ''
    make -j $(nproc --all 2>&1)
  '';
  installPhase = ''
    mkdir -p $out/build $out/ps3
    make libdir=`pwd`/host-libs/lib install
  '';
  fixupPhase = ''
    mv $out/ps3/* $out
    rm -rf $out/build $out/ps3
  '';
}
