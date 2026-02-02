{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
}:

let
  opcGen =
    {
      version,
      hash,
      rev ? "v${version}",
    }:
    buildGoModule (_finalAttrs: {
      pname = "opc";
      inherit version;

      src = fetchFromGitHub {
        inherit rev hash;
        owner = "openshift-pipelines";
        repo = "opc";
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
in
{
  opc = opcGen {
    version = "1.19.0";
    hash = "sha256-E0uhX9hfPJkXgLmruYpg1Zj4LcHR9QS0mGE7WaQaPo4=";
  };

  opc-git =
    let
      repoMeta = lib.importJSON ../repos/opc-main.json;
    in
    opcGen {
      version = repoMeta.version;
      rev = repoMeta.rev;
      hash = repoMeta.sha256;
    };
}
