{ lib, ... }:

lib.mapAttrs'
  (file: _:
    lib.nameValuePair
      (lib.removeSuffix ".nix" file)
      (import ./${file}))
  (lib.filterAttrs
    (file: _: lib.hasSuffix ".nix" file && file != "default.nix")
    (builtins.readDir ./.))
