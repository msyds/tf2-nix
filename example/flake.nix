{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    tf2-nix.url = "path:///home/crumb/src/tf2-nix";
  };

  outputs = { self, ... }@inputs: {
    # TF2 config built as a package.
    packages.x86_64-linux.default =
      let
        pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
        tf2pkgs = inputs.tf2-nix.packages.x86_64-linux;
      in tf2pkgs.mergeTf2Configs (with tf2pkgs; [
        mastercomfig.presets.medium-low
        mastercomfig.addons.flat-mouse
        mastercomfig.addons.no-tutorial
        mastercomfig.addons.null-canceling-movement
        maps.jump_beef
        improved-crosshairs
        loadouts-script
        # Packages are overridable.
        (huds.deerhud.overrideAttrs (final: prev: {
          patches = [ ./raise-uber-meter.patch ];
        }))
        # Existing configs on your file system may be referenced by path:
        ./my-config
      ]);

    # TF2 config installed using Home-manager.
    homeConfigurations.default =
      let gameDir = ".local/share/Steam/steamapps/common/Team Fortress 2/tf";
      in {
        home.file.${gameDir} = {
          recursive = true;
          source = self.packages.x86_64-linux.default;
        };
      };
  };
}
