{ mkTf2Config, fetchurl }:

builtins.mapAttrs
  (name: e: mkTf2Config {
    pname = name;
    env.description = e.description;
    maps = [
      (fetchurl {
        name = "${name}-src";
        inherit (e.src) url hash;
      })
    ];
  })
  (builtins.fromJSON (builtins.readFile ./jump-academy.json))
