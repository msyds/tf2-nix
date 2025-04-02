{ fetchurl
, mkTf2Config
, ...
}:

let
  mastercomfigVersion = "9.10.3";

  releasesUrl = version:
    "https://github.com/mastercomfig/mastercomfig/releases/download/${version}";

  fetchMastercomfig = { version, file, hash }:
    fetchurl {
      url = "${releasesUrl version}/${file}";
      inherit hash;
    };

  mkMastercomfig =
    type:
    { name
    , hash
    , file ? "mastercomfig-${name}-${type}.vpk"
    , version ? mastercomfigVersion
    }:
    mkTf2Config {
      pname = "mastercomfig-${name}-${type}";
      inherit version;
      custom = [
        (fetchMastercomfig {
          inherit version file hash;
        })
      ];
    };

  mkMastercomfigAddon = mkMastercomfig "addon";
  mkMastercomfigPreset = mkMastercomfig "preset";
in {
  addons.disable-pyroland = mkMastercomfigAddon {
    name = "disable-pyroland";
    hash = "sha256-cEFaXSXwlHwm7BnkSLmG4vAPYhL1O0XwNG0UpTnDFY8=";
  };

  addons.flat-mouse = mkMastercomfigAddon {
    name = "flat-mouse";
    hash = "sha256-v2Url+m8dzXIrs8mz5VZWRqwqSSaxyH7t2vDvT10cdg=";
  };

  presets.high = mkMastercomfigPreset {
    name = "high";
    hash = "sha256-704aEg1Gyl5vI6Y6VTmlUEiP70PjrF6/VlxsrkkepWs=";
  };

  presets.low = mkMastercomfigPreset {
    name = "low";
    hash = "sha256-CpIbjy1dzNCEa583DthygkIQ5aq7Wp2QOJGANC2IGNs=";
  };

  addons.lowmem = mkMastercomfigAddon {
    name = "lowmem";
    hash = "sha256-21iyJ4Zg+p5qES05FP2fMO7/p3YrrIkNp2GM2oEjT4E=";
  };

  presets.medium-high = mkMastercomfigPreset {
    name = "medium-high";
    hash = "sha256-pS1KcFxxB/oT9DcopZyu77nr4td6x2mDrEFVNOPmtws=";
  };

  presets.medium-low = mkMastercomfigPreset {
    name = "medium-low";
    hash = "sha256-P9Zk9IZVpX1hkAcdpNvKfzP2P+TDPNRwwv4I8uM+WU4=";
  };

  presets.medium = mkMastercomfigPreset {
    name = "medium";
    hash = "sha256-yEcxPkU/0vJn7vy3n2ViYdTCBV3O9gX57fMQQZYlm3I=";
  };

  addons.no-footsteps = mkMastercomfigAddon {
    name = "no-footsteps";
    hash = "sha256-7WIWwV2PnwRM79I7vOdfRggQi/NUS+6GHkAAyo8ap2I=";
  };

  addons.no-soundscapes = mkMastercomfigAddon {
    name = "no-soundscapes";
    hash = "sha256-Qp7QW9zZXpX7zrK+Fmpf428lU7Mc86sMn6+5Syhnxz0=";
  };

  addons.no-tutorial = mkMastercomfigAddon {
    name = "no-tutorial";
    hash = "sha256-sA3kN2iNe5bwh+954ef+sV0hjMdMZLs6IPgsHDi5oXE=";
  };

  presets.none = mkMastercomfigPreset {
    name = "none";
    hash = "sha256-FQ8o4fxUkIAqlFPZPULScwDBaQjc88NiO579IaFTikA=";
  };

  addons.null-canceling-movement = mkMastercomfigAddon {
    name = "null-canceling-movement";
    hash = "sha256-B3pHn80lMRN4q5hF/JSAdzDLTnyh7MNbYzMURrYmXxU=";
  };

  addons.transparent-viewmodels = mkMastercomfigAddon {
    name = "transparent-viewmodels";
    hash = "sha256-nsUBSsGHXM+xwecixZvhisbifLqkqSyF7kIkJFmq6ow=";
  };

  presets.ultra = mkMastercomfigPreset {
    name = "ultra";
    hash = "sha256-VfSFxRuZtYLuNrtX6X7BEMtL6wMbFyela7zbmZurlCw=";
  };

  presets.very-low = mkMastercomfigPreset {
    name = "very-low";
    hash = "sha256-faGnju5aPovl++kAh2HNkkroUoMz9/Fx6kSgb3IBRfg=";
  };
}
