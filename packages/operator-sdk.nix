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
    version = "1.42.0";

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
      hash = "sha256-iXLAFFO7PCxA8QuQ9pMmQ/GBbVM5wBy9cVzSQRHHPrg=";
    };
    vendorHash = "sha256-F2ZYEEFG8hqCcy16DUmP9ilG6e20nXBiJnB6U+wezAo=";

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
