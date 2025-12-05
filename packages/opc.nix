{ stdenv
, lib
, buildGoModule
, fetchFromGitHub
,
}:

with lib;
rec {
  opcGen =
    { version
    , sha256
    , rev ? "v${version}"
    ,
    }:
    buildGoModule rec {
      inherit version;
      pname = "opc";

      src = fetchFromGitHub {
        inherit rev;
        owner = "openshift-pipelines";
        repo = "opc";
        sha256 = sha256;
      };
      vendorHash = null;

      patchPhase = ''
        runHook prePatch
        sed -i 's/devel/${version}/' ./pkg/version.json
        runHook postPatch
      '';
      postInstall = ''
        # completions
        mkdir -p $out/share/bash-completion/completions/
        $out/bin/opc completion bash > $out/share/bash-completion/completions/opc
        mkdir -p $out/share/zsh/site-functions/
        $out/bin/opc completion zsh > $out/share/zsh/site-functions/opc
      '';

      meta = {
        description = "A CLI for OpenShift Pipeline";
        homepage = "https://github.com/openshift-pipelines/opc";
        license = lib.licenses.asl20;
        platforms = lib.platforms.unix;
        mainProgram = "opc";
      };
    };

  opc_1_19 = makeOverridable opcGen {
    version = "1.19.0";
    sha256 = "sha256-E0uhX9hfPJkXgLmruYpg1Zj4LcHR9QS0mGE7WaQaPo4=";
  };
  opc_1_18 = makeOverridable opcGen {
    version = "1.18.0";
    sha256 = "sha256-9/qlrFJw6Q4jjlvTr4tFaKiC9ckubM59eV27MQnbhcQ=";
  };
  opc = opc_1_19;

  opc-git =
    let
      repoMeta = importJSON ../repos/opc-main.json;
    in
    makeOverridable opcGen {
      version = repoMeta.version;
      rev = repoMeta.rev;
      sha256 = repoMeta.sha256;
    };
}
