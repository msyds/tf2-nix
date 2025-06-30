{
  description = "A Nix framework for configuring Team Fortress 2";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, ... }@inputs:
    let
      # keep it as an attrset arg for future expandability
      mkTf2Pkgs = { pkgs }: import ./tf2/packages { inherit pkgs; };
    in
    inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import inputs.nixpkgs { inherit system; };
      in {
        legacyPackages = mkTf2Pkgs pkgs;
      })
    // {
      lib = { inherit mkTf2Pkgs; };
    };
}
