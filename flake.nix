{
  description = "A Nix framework for configuring Team Fortress 2";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, ... }@inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import inputs.nixpkgs { inherit system; };
        lib = pkgs.lib;
      in {
        legacyPackages = import ./tf2/packages {
          inherit pkgs lib;
        };
      });
}
