{ fetchFromGameBanana, mkTf2Config, ... }:

{
  improved-crosshairs = mkTf2Config {
    pname = "improved-crosshairs";
    custom = [
      (fetchFromGameBanana {
        name = "improved-crosshairs";
        id = "1047153";
        hash = "sha256-ULcSfxuiGY1YCE1zQ693183F7ZRC11tYhvDMJKyzL1A=";
      })
    ];
  };
}
