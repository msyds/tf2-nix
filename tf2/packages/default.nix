{ pkgs, lib }:

let
  mkTf2Config = pkgs.callPackage ../mkTf2Config.nix {};

  fetchFromGameBanana =
    { id
    , hash
    , name ? "source"
    }:
    pkgs.fetchzip {
      url = "https://gamebanana.com/dl/${id}";
      extension = "zip";
      inherit hash name;
    };

  mkCfg = name: body:
    pkgs.runCommand name {} ''
      ${lib.toShellVar "name" name}
      mkdir -p $out/cfg "$(dirname "$out/cfg/$name")"
      tee "$out/cfg/$name.cfg" << SUPER_UNIQUE_EOF
      // Generated by tf2.nix

      ${body}
      SUPER_UNIQUE_EOF
    '';

  mergeTf2Configs = configs:
    pkgs.symlinkJoin {
      name = "merged-tf2-config";
      paths = configs;
    };

  extra-args = {
    inherit mkTf2Config fetchFromGameBanana mkCfg mergeTf2Configs callPackage;
  };

  callPackage = lib.callPackageWith (pkgs // extra-args);
in lib.mergeAttrsList [ 
  { inherit mkTf2Config fetchFromGameBanana mkCfg mergeTf2Configs; }
  { mastercomfig = callPackage ./mastercomfig.nix {}; }
  { huds = callPackage ./huds {}; }
  { maps = callPackage ./maps {}; }
  (builtins.mapAttrs
    (_: v: callPackage v {})
    (import ./misc {inherit lib;}))
  (callPackage ./scripts.nix {})
]
