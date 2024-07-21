{pkgs}: {
  overlays = import ./overlays {inherit pkgs;};
}
