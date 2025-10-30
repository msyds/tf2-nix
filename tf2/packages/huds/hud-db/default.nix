{ mkTf2Config, fetchFromGitHub, lib }:

builtins.mapAttrs
  (name: e: mkTf2Config {
    pname = name;
    custom = [
      (fetchFromGitHub (builtins.removeAttrs e.src ["__type"] // {
        name = "${name}-src";
      }))
    ];
    meta = {
      inherit (e) description;
      # Hud-db currently requires all HUDs to be on GitHub.  We can thus
      # somewhat-safely assume the homepage.  A number of packages have
      # explicitly-set homepages, and we do not yet support them.  Doing so
      # requires patching the fetch-hud-db script, which I intend to do soonish.
      homepage = "https://github.com/${e.src.owner}/${e.src.repo}";
      platforms = lib.platforms.all;
      # The biggest outstanding issue is recording the license here.  Hud-db
      # does not track license info, whiuch is a big issue IMO.
    };
  })
  (builtins.fromJSON (builtins.readFile ./hud-db.json))
