{ stdenv, lib, buildGoModule, fetchFromGitHub }:

with lib;
rec {
  omcGen =
    { version
    , sha256
    , rev ? "v${version}"
    }:
    buildGoModule rec {
      pname = "omc";
      name = "${pname}-${version}";

      #subPackages = [ "." ];
      ldflags =
        let
          t = "github.com/gmeghnag/omc/vars";
        in
        [
          "-s"
          "-w"
          "-X ${t}.OMCVersionTag=${version}"
          # -X github.com/gmeghnag/omc/vars.OMCVersionHash=${HASH}"
        ];

      src = fetchFromGitHub {
        inherit rev;
        owner = "gmeghnag";
        repo = "omc";
        sha256 = "${sha256}";
      };
      vendorHash = null;

      doCheck = false;
      preBuild = ''
        export HOME=$(pwd)
      '';
      preInstall = ''
        pwd
        ls -la .
      '';
      postInstall = ''
        # completions
        mkdir -p $out/share/bash-completion/completions/
        $out/bin/omc completion bash > $out/share/bash-completion/completions/omc
        mkdir -p $out/share/zsh/site-functions/
        $out/bin/omc completion zsh > $out/share/zsh/site-functions/omc
      '';

      meta = {
        description = "OpenShift Must-Gather Client";
        homepage = "https://github.com/gmeghnag/omc";
        license = lib.licenses.asl20;
      };
    };

  omc_3_7 = makeOverridable omcGen {
    version = "3.7.4";
    sha256 = "sha256-0omvZY3Sqr/wcKKUyfWIfr7vQY534N/EmpPLaS4TUIE=";
  };
  omc_3_6 = makeOverridable omcGen {
    version = "3.6.3";
    sha256 = "sha256-33VjDhGG91CH4vaO9v0KnI+bAZPg7MmDClYhxNOPxfQ=";
  };
  omc_3_4 = makeOverridable omcGen {
    version = "3.4.0";
    sha256 = "sha256-4SCb4Ao31RRRlqr2kxBNPxsn00XewV2Lrf1RyGvM1N0=";
  };
  omc_3_3 = makeOverridable omcGen {
    version = "3.3.2";
    sha256 = "sha256-Fjum6OU166aRckj75KIDEgwyTFX8/P528pQquYoqWGI=";
  };
  omc_3_2 = makeOverridable omcGen {
    version = "3.2.0";
    sha256 = "sha256-GBfRjS8u+KKBLie2GmzeLbD08V/LKNF7cbC7fjMxUtw=";
  };
  omc = omc_3_7;

  omc-git =
    let
      repoMeta = importJSON ../repos/omc-main.json;
    in
    makeOverridable omcGen {
      version = "${repoMeta.version}";
      rev = "${repoMeta.rev}";
      sha256 = "${repoMeta.sha256}";
    };
}
