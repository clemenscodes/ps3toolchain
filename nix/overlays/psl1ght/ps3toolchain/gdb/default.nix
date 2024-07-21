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
  inherit version nativeBuildInputs buildInputs hardeningDisable;
  pname = "${prefix}-gdb";
  name = "${pname}-${version}-PS3";
  src = fetchurl {
    inherit pname version sha256;
    url = "https://ftp.gnu.org/gnu/gdb/gdb-${version}.tar.xz";
  };
  unpackPhase = ''
    export PS3DEV=${placeholder "out"}/ps3
    export PSL1GHT=$PS3DEV
    ${scripts.copy}/bin/copy_if_not_exists ${src} ${name}.tar.xz
    ${scripts.extract}/bin/extract_if_not_exists ${name}.tar.xz xvf gdb-${version}
    cp ${gnu-config}/config.guess ${gnu-config}/config.sub gdb-${version}
  '';
  patchPhase = ''
    ${scripts.patch}/bin/apply_patch_if_not_applied ${./patches/${pname}-${version}-PS3.patch} gdb-${version}
  '';
  configureFlags =
    [
      "--prefix=${placeholder "out"}/ps3/${prefix}"
      "--target=${target}"
      "--disable-nls"
      "--disable-sim"
      "--disable-werror"
    ]
    ++ lib.optional (prefix == "ppu") ["--disable-multilib"]
    ++ lib.optional (prefix == "spu") [];
  configurePhase = ''
    mkdir -p gdb-${version}/build-${prefix}
    cd gdb-${version}/build-${prefix}
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
