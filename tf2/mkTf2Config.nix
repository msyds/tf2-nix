{ runCommand, lib }:

{ pname
, version ? null
, custom ? []
, cfg ? []
, maps ? []
# Extra arguments to pass to stdenv.mkDerivation.
, env ? {}
}@args:

let
  version-suffix = lib.optionalString (version != null) "-${version}";
  name = pname + version-suffix;

  make-output = output: var:
    lib.optionalString (var != []) ''
      mkdir -p "$out/${output}"
      ${lib.toShellVar "outputList_${output}" var}
      for i in "''${outputList_${output}[@]}"; do
        ln -s "$i" "$out/${output}/$(basename "$i")"
      done
    '';
in runCommand name env ''
  set -xe
  mkdir -p $out
  ${make-output "cfg" cfg}
  ${make-output "custom" custom}
  ${make-output "maps" maps}
''
