{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  versionCheckHook,
}:

rec {
  koffGen =
    {
      version,
      sha256,
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
        inherit rev;
        owner = "gmeghnag";
        repo = "koff";
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

  koff_1_0 = lib.makeOverridable koffGen {
    version = "1.0.1";
    sha256 = "sha256-qMZcyXqQ+zEEytnQbTF37I0+sZYJRNTXyL8rgDiFI1U=";
  };
  koff = koff_1_0;

  koff-git =
    let
      repoMeta = lib.importJSON ../repos/koff-main.json;
    in
    lib.makeOverridable koffGen {
      version = repoMeta.version;
      rev = repoMeta.rev;
      sha256 = repoMeta.sha256;
    };
}
