{ stdenv
, lib
, buildGoModule
, fetchFromGitHub
, installShellFiles
, versionCheckHook
,
}:

rec {
  omcGen =
    { version
    , sha256
    , rev ? "v${version}"
    ,
    }:
    buildGoModule (finalAttrs: {
      pname = "omc";
      inherit version;

      #subPackages = [ "." ];
      ldflags =
        let
          t = "github.com/gmeghnag/omc/vars";
        in
        [
          "-s"
          "-w"
          "-X ${t}.OMCVersionTag=${finalAttrs.version}"
          # -X github.com/gmeghnag/omc/vars.OMCVersionHash=${HASH}"
        ];

      src = fetchFromGitHub {
        inherit rev;
        owner = "gmeghnag";
        repo = "omc";
        sha256 = sha256;
      };
      vendorHash = null;

      nativeBuildInputs = [ installShellFiles ];
      nativeInstallCheckInputs = [ versionCheckHook ];

      doCheck = false;
      preBuild = ''
        export HOME=$(pwd)
      '';
      postInstall = ''
        $out/bin/omc completion bash > omc.bash
        $out/bin/omc completion zsh > omc.zsh
        installShellCompletion --cmd omc \
          --bash omc.bash \
          --zsh omc.zsh
      '';

      meta = {
        description = "OpenShift Must-Gather Client";
        homepage = "https://github.com/gmeghnag/omc";
        license = lib.licenses.asl20;
        platforms = lib.platforms.unix;
        mainProgram = "omc";
      };
    });

  omc_3_12 = lib.makeOverridable omcGen {
    version = "3.12.2";
    sha256 = "sha256-+kJXYaXd026Yruq0zhBoszWG0xgOhAmby+c5Wtz98Q8=";
  };
  omc_3_11 = lib.makeOverridable omcGen {
    version = "3.11.2";
    sha256 = "sha256-TTYigS2epmJ37SBBZQGTKyR40r2txhvzNM1RMM8jkcY=";
  };
  omc_3_10 = lib.makeOverridable omcGen {
    version = "3.10.0";
    sha256 = "sha256-BpR/Ts/IJGnzoGE3jzv6LeE322L62Xpv9ojP6MVMjIk=";
  };
  omc = omc_3_12;

  omc-git =
    let
      repoMeta = lib.importJSON ../repos/omc-main.json;
    in
    lib.makeOverridable omcGen {
      version = repoMeta.version;
      rev = repoMeta.rev;
      sha256 = repoMeta.sha256;
    };
}
