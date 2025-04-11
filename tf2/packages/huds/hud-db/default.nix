{ mkTf2Config, fetchFromGitHub }:

builtins.mapAttrs
  (name: e: mkTf2Config {
    pname = name;
    env.description = e.description;
    custom = [
      (fetchFromGitHub (builtins.removeAttrs e.src ["__type"] // {
        inherit name;
      }))
    ];
  })
  (builtins.fromJSON (builtins.readFile ./hud-db.json))
