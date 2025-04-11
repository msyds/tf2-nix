{ pkgs, callPackage, fetchFromGitHub, mkTf2Config }@args:

let
  hud-db = callPackage ./hud-db {
    inherit fetchFromGitHub mkTf2Config;
  };
  extras = callPackage ./extras.nix {
    inherit fetchFromGitHub mkTf2Config;
  };
in hud-db // extras
