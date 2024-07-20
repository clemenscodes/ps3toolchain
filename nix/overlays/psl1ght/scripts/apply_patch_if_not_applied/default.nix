{pkgs}:
pkgs.writeShellScriptBin "apply_patch_if_not_applied" ''
  patch_file=$1
  target_dir=$2
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
''
