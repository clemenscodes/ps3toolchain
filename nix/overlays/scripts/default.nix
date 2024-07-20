{pkgs}: {
  patch = import ./apply_patch_if_not_applied {inherit pkgs;};
  copy = import ./copy_if_not_exists {inherit pkgs;};
  extract = import ./extract_if_not_exists {inherit pkgs;};
  symlink = import ./symlink_if_not_exists {inherit pkgs;};
}
