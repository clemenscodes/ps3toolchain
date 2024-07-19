{pkgs}: let
  sources = import ./sources.nix {inherit pkgs;};
  install = import ./install.nix {inherit pkgs sources;};
  ps3toolchain =
    /*
    bash
    */
    ''
      mkdir -p $out/ps3 $out/build
      export PS3DEV="$out/ps3"
      export PSL1GHT="$PS3DEV"
      copy_if_not_exists() {
        local src=$1
        local dest=$2
        if [ ! -e $dest ]; then
          echo "Copying $src to $dest"
          cp -r $src $dest
        else
          echo "Destination $dest already exists, skipping copy"
        fi
      }
      extract_if_not_exists() {
        local tar_file=$1
        local options=$2
        local extracted_dir=$3
        if [ ! -d $extracted_dir ]; then
          echo "Extracting $tar_file to $extracted_dir with options $options"
          tar $options $tar_file
        else
          echo "Directory $extracted_dir already exists, skipping extraction"
        fi
      }
      apply_patch_if_not_applied() {
        local patch_file=$1
        local target_dir=$2
        echo "Testing patch $patch_file for $target_dir"
        set +e
        patch -Rsfp1 --dry-run -d $target_dir < $patch_file
        if [ $? -eq 1 ]; then
          echo "Applying patch $patch_file to $target_dir"
          patch -p1 -d $target_dir < $patch_file
        else
          echo "Patch $patch_file already applied to $target_dir"
        fi
        set -e
      }
      symlink_if_not_exists() {
        local target=$1
        local link_name=$2
        if [ ! -L $link_name ]; then
          echo "Creating symlink from $link_name to $target"
          ln -s $target $link_name
        else
          echo "Symlink $link_name already exists, skipping"
        fi
      }
    '';
  symlinks =
    /*
    bash
    */
    ''
      cd $PS3DEV/ppu
      if [ ! -d ppu -a ! -f ppu -a ! -h ppu -a -d powerpc64-ps3-elf ]; then
        ln -s powerpc64-ps3-elf ppu
      fi
      cd $PS3DEV/ppu/bin
      for i in `ls powerpc64-ps3-elf-* | cut -c19-`; do
        if [ ! -f ppu-$i -a ! -h ppu-$i -a -f powerpc64-ps3-elf-$i ]; then
          ln -s powerpc64-ps3-elf-$i ppu-$i
        fi
      done
    '';
  finalize =
    /*
    bash
    */
    ''
      mv $out/ps3/* $out
      rm -rf $out/build $out/ps3
    '';
in (final: prev:
    with prev; {
      ps3toolchain = with install;
        stdenv.mkDerivation {
          name = "ps3toolchain";
          nativeBuildInputs = [
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
          buildInputs = [wget python310];
          hardeningDisable = ["format"];
          phases = "installPhase";
          installPhase =
            ps3toolchain
            + ppu-binutils
            + ppu-gcc
            + ppu-gdb
            + symlinks
            + spu-binutils
            + spu-gcc
            + spu-gdb
            + finalize;
        };
    })
