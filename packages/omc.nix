{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  versionCheckHook,
}:

let
  omcGen =
    {
      version,
      hash,
      rev ? "v${version}",
    }:
    buildGoModule (finalAttrs: {
      pname = "omc";
      inherit version;

      ldflags =
        let
          t = "github.com/gmeghnag/omc/vars";
        in
        [
          "-s"
          "-w"
          "-X ${t}.OMCVersionTag=${finalAttrs.version}"
        ];

      src = fetchFromGitHub {
        inherit rev hash;
        owner = "gmeghnag";
        repo = "omc";
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
in
{
  omc = omcGen {
    version = "3.13.0";
    hash = "sha256-ZzMsp57a5t4WsEjksqqMwYWd5dZ4NBLgThZMxGUh/hk=";
  };

  omc-git =
    let
      repoMeta = lib.importJSON ../repos/omc-main.json;
    in
    omcGen {
      version = repoMeta.version;
      rev = repoMeta.rev;
      hash = repoMeta.sha256;
    };
}
