{pkgs}: let
  sources = import ./sources.nix {inherit pkgs;};
  install = import ./install.nix {inherit pkgs sources;};
in (final: prev:
    with prev; {
      ps3libraries = with install;
        stdenv.mkDerivation {
          name = "ps3libraries";
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
            nvidia_cg_toolkit
          ];
          buildInputs = [wget python310];
          hardeningDisable = ["format"];
          phases = "installPhase";
          installPhase =
            /*
            bash
            */
            ''
              mkdir -p $out
              export PS3DEV="$out"
              export PSL1GHT="$PS3DEV"
              symlink_if_not_exists() {
                local target=$1
                local link_name=$2
                if [ ! -L $link_name ]; then
                  echo "Creating symlink from $link_name to $target"
                  ln -s $(realpath $target) $link_name
                else
                  echo "Symlink $link_name already exists, skipping"
                fi
              }
              create_symlinks() {
                local src="$1"
                local dest="$2"
                for item in "$src"/*; do
                  local base_item=$(basename "$item")
                  local dest_item="$dest/$base_item"
                  if [ -d $item ]; then
                    mkdir -p $dest_item
                    create_symlinks $item $dest_item
                  else
                    symlink_if_not_exists $item $dest_item
                  fi
                done
              }
              create_symlinks ${pkgs.ps3toolchain} $PS3DEV
            '';
        };
    })
