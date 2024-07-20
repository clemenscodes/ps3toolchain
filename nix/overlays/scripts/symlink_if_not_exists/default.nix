{pkgs}:
pkgs.writeShellScriptBin "symlink_if_not_exists" ''
  target=$1
  link_name=$2
  if [ ! -L $link_name ]; then
    echo "Creating symlink from $link_name to $target"
    ln -s $target $link_name
  else
    echo "Symlink $link_name already exists, skipping"
  fi
''
