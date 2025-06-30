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
        inherit (pkgs) lib;
        tf2Pkgs = mkTf2Pkgs { inherit pkgs; };
      in {
        legacyPackages = tf2Pkgs;
        packages = lib.mergeAttrsList (lib.flip map [
          []
          [ "huds" ]
          [ "maps" ]
          [ "mastercomfig" "addons" ]
          [ "mastercomfig" "presets" ]
        ] (attrPath:
          lib.pipe tf2Pkgs [
            (lib.getAttrFromPath attrPath)
            (lib.filterAttrs (_: v: lib.isDerivation v))
            (lib.mapAttrs' (k: v: lib.nameValuePair (lib.concatStringsSep "_" (attrPath ++ [k])) v))
          ]
        ));
      })
    // {
      lib = { inherit mkTf2Pkgs; };
    };
}
