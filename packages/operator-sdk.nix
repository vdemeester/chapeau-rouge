{
  stdenv,
  lib,
  buildGoModule,
  fetchFromGitHub,
  git,
  sqlite,
  gpgme,
  pkg-config,
  validatePkgConfig,
  installShellFiles,
  versionCheckHook,
}:

{
  operator-sdk = buildGoModule (finalAttrs: {
    pname = "operator-sdk";
    version = "1.42.1";

    buildInputs = [
      sqlite
      gpgme
    ];
    nativeBuildInputs = [
      git
      pkg-config
      validatePkgConfig
      installShellFiles
    ];
    nativeInstallCheckInputs = [ versionCheckHook ];

    subPackages = [ "cmd/operator-sdk" ];
    ldflags =
      let
        t = "github.com/operator-framework/operator-sdk/internal/version";
      in
      [
        "-s"
        "-w"
        "-X ${t}.GitVersion=${finalAttrs.version}"
        "-X ${t}.KubernetesVersion=1.32"
      ];
    CGO_CFLAGS = lib.optionals stdenv.cc.isGNU [ "-Wno-return-local-addr" ];

    src = fetchFromGitHub {
      rev = "v${finalAttrs.version}";
      owner = "operator-framework";
      repo = "operator-sdk";
      hash = "sha256-mEOEwjjlrbzOK1OcLohmOubcHCQpEtV8zp8oJ6AgsnY=";
    };
    vendorHash = "sha256-pBoIvkg2BX9eNUYmY/wffkrMNMkhSGd9T5s6hzo9aOw=";

    postInstall = ''
      installShellCompletion --cmd operator-sdk \
        --bash <($out/bin/operator-sdk completion bash) \
        --zsh <($out/bin/operator-sdk completion zsh)
    '';

    meta = {
      description = "SDK for building Kubernetes applications. Provides high level APIs, useful abstractions, and project scaffolding";
      homepage = "https://github.com/operator-framework/operator-sdk";
      license = lib.licenses.asl20;
      platforms = lib.platforms.unix;
      mainProgram = "operator-sdk";
    };
  });
}
