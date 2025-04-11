{ stdenv, lib }:

{ pname
, version ? ""
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
        name="$(stripHash "$i")"
        wrapperDir="#''${name}#" 
        if [ -d "$wrapperDir" ]; then
          mv "$wrapperDir"/* "$out/${output}/"
        else
          mv "$name" "$out/${output}/$name"
        fi
      done
    '';

  allSrcs = cfg ++ maps ++ custom;

  srcArg =
    if builtins.length allSrcs == 1
    then { src = builtins.head allSrcs; }
    else { srcs = allSrcs; sourceRoot = "."; };
in stdenv.mkDerivation ({
  inherit pname version;
  # Adapted from stdenv's _defaultUnpack().
  unpackCmd = ''
    echo "hello i am unpackcmdjkj"
    set -e
    case "$curSrc" in
      *.vpk)
        name="$(stripHash "$curSrc")"
        destination="#$name#/$name"
        mkdir "$(dirname "$destination")"
        if [ -e "$destination" ]; then
            echo "Cannot copy $curSrc to $destination: destination already exists!"
            echo "Did you specify two \"srcs\" with the same \"name\"?"
            return 1
        fi
        # We can't preserve hardlinks because they may have been
        # introduced by store optimization, which might break things
        # in the build.
        cp -r --preserve=mode,timestamps --reflink=auto -- "$curSrc" "$destination"
        ;;
      *.bsp.bz2)
        bzfile="$(stripHash "$curSrc")"
        file="''${bzfile%.bz2}"
        destination="#$bzfile#/$file"
        mkdir "$(dirname "$destination")"
        bunzip2 -c "$curSrc" > "$destination"
        ;;
      *)
        return 1
        ;;
    esac
  '';
  preUnpack = ''
    echo "$unpackCmd"
    echo "$unpackCmdHooks"
  '';
  installPhase = ''
    set -xe
    mkdir -p $out
    ${lib.optionalString (builtins.length allSrcs == 1)
      "cd .."}
    ls -la
    ${make-output "cfg" cfg}
    ${make-output "custom" custom}
    ${make-output "maps" maps}
  '';
} // srcArg // env)
