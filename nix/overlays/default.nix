{pkgs}: [
  (import ./ps3toolchain {inherit pkgs;})
  (import ./psl1ght {inherit pkgs;})
  (import ./ps3libraries {inherit pkgs;})
]
