{ fetchFromGitHub, mkTf2Config, ... }:

{
  deerhud = mkTf2Config {
    pname = "deerhud";
    custom = [
      (fetchFromGitHub {
        name = "deerhud";
        owner = "DeerUwU";
        repo = "deerhud-tf2";
        rev = "78a24effbc66bc78b4bb557228eaa0195db3270c";
        hash = "sha256-uwKRilkEPHk1snjH/n9u32dMXr3cXjYN06cfthpZe7g=";
      })
    ];
  };
}
