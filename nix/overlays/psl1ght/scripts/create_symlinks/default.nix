{pkgs}:
pkgs.writeShellScriptBin "create_symlinks" ''
  create_symlinks() {
  local src="$1"
  local dest="$2"
    for item in "$src"/*; do
      local base_item=$(basename "$item")
      local dest_item="$dest/$base_item"
      if [ -d "$item" ]; then
        mkdir -p "$dest_item"
        create_symlinks "$item" "$dest_item"
      else
        echo "Creating symlink from $(realpath "$item") to $dest_item"
        ln -s "$(realpath "$item")" "$dest_item"
      fi
    done
  }
  create_symlinks "$@"
''
