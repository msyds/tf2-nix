{ fetchFromGameBanana
, stdenv
, lib
# Alternate crosshairs to use.  See their README.
, alternates ? []
}:

stdenv.mkDerivation {
  pname = "improved-crosshairs";
  version = "2.0";
  src = fetchFromGameBanana {
    name = "improved-crosshairs";
    id = "1047153";
    hash = "sha256-ULcSfxuiGY1YCE1zQ693183F7ZRC11tYhvDMJKyzL1A=";
  };
  buildPhase = ''
    ${lib.toShellVar "alternates" alternates}
    dest_dir="Crosshairs/materials/vgui/replay/thumbnails/"
    for alt in "''${alternates[@]}"; do
      dest="$dest_dir/$(sed -e 's/\(.*\) \[.*\]$/\1/' <<< "$alt").vtf"
      src="Alternates/$alt.vtf"
      if [ ! -e "$src" ]; then
        echo "Alternate '$alt' does not exist!"
        exit 1
      else
        mv "$src" "$dest"
      fi
    done
  '';
  installPhase = ''
    mkdir -p $out/custom
    mv Crosshairs "$out/custom/improved-crosshairs"
  '';
}
