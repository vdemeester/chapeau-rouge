{
  lib,
  buildGoModule,
  fetchFromGitHub,
  git,
  gpgme,
  pkg-config,
  validatePkgConfig,
  installShellFiles,
  versionCheckHook,
}:

{
  opm = buildGoModule (finalAttrs: {
    pname = "opm";
    version = "1.61.0";

    buildInputs = [
      gpgme
    ];
    nativeBuildInputs = [
      git
      pkg-config
      validatePkgConfig
      installShellFiles
    ];
    nativeInstallCheckInputs = [ versionCheckHook ];

    subPackages = [ "cmd/opm" ];
    ldflags =
      let
        t = "github.com/operator-framework/operator-registry/cmd/opm/version";
      in
      [
        "-X ${t}.gitCommit=${finalAttrs.version}"
        "-X ${t}.opmVersion=${finalAttrs.version}"
      ];
    tags = [ "json1" ];

    src = fetchFromGitHub {
      rev = "v${finalAttrs.version}";
      owner = "operator-framework";
      repo = "operator-registry";
      hash = "sha256-EWxER6zPfz83esOo3As5cGc4GXbsA87N+1L+ov+hs2M=";
    };
    vendorHash = "sha256-uE5flRoIpBg26AqgqgOKsETbsZa8btyerQFL1KUjfDA=";

    postInstall = ''
      installShellCompletion --cmd opm \
        --bash <($out/bin/opm completion bash) \
        --zsh <($out/bin/opm completion zsh)
    '';

    meta = {
      description = "Operator Registry runs in a Kubernetes or OpenShift cluster to provide operator catalog data to Operator Lifecycle Manager";
      homepage = "https://github.com/operator-framework/operator-registry";
      license = lib.licenses.asl20;
      platforms = lib.platforms.unix;
      mainProgram = "opm";
    };
  });
}
