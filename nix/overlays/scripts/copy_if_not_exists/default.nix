{pkgs}: pkgs.writeShellScriptBin "copy_if_not_exists" ''
  src=$1
  dest=$2
  if [ ! -e $dest ]; then
    echo "Copying $src to $dest"
    cp -r $src $dest
  else
    echo "Destination $dest already exists, skipping copy"
  fi
''
