{ stdenv
, lib
, buildGoModule
, fetchFromGitHub
,
}:

with lib;
rec {
  omcGen =
    { version
    , sha256
    , rev ? "v${version}"
    ,
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

  omc_3_12 = makeOverridable omcGen {
    version = "3.12.0";
    sha256 = "sha256-C737p7yCSkdKxBiw3fq0a9ZZRr6myLAx20cJnE7HZTU=";
  };
  omc_3_11 = makeOverridable omcGen {
    version = "3.11.2";
    sha256 = "sha256-TTYigS2epmJ37SBBZQGTKyR40r2txhvzNM1RMM8jkcY=";
  };
  omc_3_10 = makeOverridable omcGen {
    version = "3.10.0";
    sha256 = "sha256-BpR/Ts/IJGnzoGE3jzv6LeE322L62Xpv9ojP6MVMjIk=";
  };
  omc = omc_3_12;

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
