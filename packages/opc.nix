{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
}:

rec {
  opcGen =
    {
      version,
      sha256,
      rev ? "v${version}",
    }:
    buildGoModule (_finalAttrs: {
      pname = "opc";
      inherit version;

      src = fetchFromGitHub {
        inherit rev;
        owner = "openshift-pipelines";
        repo = "opc";
        sha256 = sha256;
      };
      vendorHash = null;

      nativeBuildInputs = [ installShellFiles ];

      patchPhase = ''
        runHook prePatch
        sed -i 's/devel/${version}/' ./pkg/version.json
        runHook postPatch
      '';
      postInstall = ''
        installShellCompletion --cmd opc \
          --bash <($out/bin/opc completion bash) \
          --zsh <($out/bin/opc completion zsh)
      '';

      meta = {
        description = "A CLI for OpenShift Pipeline";
        homepage = "https://github.com/openshift-pipelines/opc";
        license = lib.licenses.asl20;
        platforms = lib.platforms.unix;
        mainProgram = "opc";
      };
    });

  opc_1_19 = lib.makeOverridable opcGen {
    version = "1.19.0";
    sha256 = "sha256-E0uhX9hfPJkXgLmruYpg1Zj4LcHR9QS0mGE7WaQaPo4=";
  };
  opc_1_18 = lib.makeOverridable opcGen {
    version = "1.19.0";
    sha256 = "sha256-E0uhX9hfPJkXgLmruYpg1Zj4LcHR9QS0mGE7WaQaPo4=";
  };
  opc = opc_1_19;

  opc-git =
    let
      repoMeta = lib.importJSON ../repos/opc-main.json;
    in
    lib.makeOverridable opcGen {
      version = repoMeta.version;
      rev = repoMeta.rev;
      sha256 = repoMeta.sha256;
    };
}
