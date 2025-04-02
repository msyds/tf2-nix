{ fetchurl, mkTf2Config, ... }:

{
  loadouts-script = mkTf2Config rec {
    pname = "tf2-loadouts-script";
    version = "3.1";
    custom = [
      (fetchurl {
        url = "https://github.com/jooonior/tf2-loadouts-script/releases/download/v${version}/loadouts.vpk";
        hash = "sha256-qMDQe/lLZz5YdH6kvG7vNKHUxPvId4AMqu/hFqr/Sd8=";
      })
    ];
  };
}
