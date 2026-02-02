{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  versionCheckHook,
}:

let
  koffGen =
    {
      version,
      hash,
      rev ? "v${version}",
    }:
    buildGoModule (finalAttrs: {
      pname = "koff";
      inherit version;

      subPackages = [ "." ];
      ldflags =
        let
          t = "github.com/gmeghnag/koff/vars";
        in
        [
          "-s"
          "-w"
          "-X ${t}.KoffVersionTag=${finalAttrs.version}"
        ];

      src = fetchFromGitHub {
        inherit rev hash;
        owner = "gmeghnag";
        repo = "koff";
      };
      vendorHash = null;

      nativeBuildInputs = [ installShellFiles ];
      nativeInstallCheckInputs = [ versionCheckHook ];

      doCheck = false;
      preBuild = ''
        export HOME=$(pwd)
      '';
      postInstall = ''
        installShellCompletion --cmd koff \
          --bash <($out/bin/koff completion bash) \
          --zsh <($out/bin/koff completion zsh)
      '';

      meta = {
        description = "OpenShift Must-Gather Client";
        homepage = "https://github.com/gmeghnag/koff";
        license = lib.licenses.asl20;
        platforms = lib.platforms.unix;
        mainProgram = "koff";
      };
    });
in
{
  koff = koffGen {
    version = "1.0.1";
    hash = "sha256-qMZcyXqQ+zEEytnQbTF37I0+sZYJRNTXyL8rgDiFI1U=";
  };

  koff-git =
    let
      repoMeta = lib.importJSON ../repos/koff-main.json;
    in
    koffGen {
      version = repoMeta.version;
      rev = repoMeta.rev;
      hash = repoMeta.sha256;
    };
}
