{ mkTf2Config, fetchFromGitHub }:

builtins.mapAttrs
  (name: e: mkTf2Config {
    pname = name;
    env.description = e.description;
    custom = [
      (fetchFromGitHub (builtins.removeAttrs e.src ["__type"] // {
        name = "${name}-src";
      }))
    ];
  })
  (builtins.fromJSON (builtins.readFile ./hud-db.json))
