{
  description = "A Nix framework for configuring Team Fortress 2";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import inputs.nixpkgs { inherit system; };
      lib = pkgs.lib;
    in {
      packages.x86_64-linux = import ./tf2/packages {
        inherit pkgs lib;
      };
    };
}
