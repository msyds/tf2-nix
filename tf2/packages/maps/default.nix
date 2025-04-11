{ pkgs, callPackage, fetchFromGitHub, mkTf2Config }@args:

let
  jump-academy = callPackage ./jump-academy {};
  extras = callPackage ./extras.nix {};
in jump-academy // extras
