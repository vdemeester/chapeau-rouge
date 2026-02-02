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

rec {
  opmGen =
    {
      version,
      sha256,
      vendorHash,
    }:

    buildGoModule (finalAttrs: {
      pname = "opm";
      inherit version vendorHash;

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
        sha256 = sha256;
      };

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

  opm_1_61 = lib.makeOverridable opmGen {
    version = "1.62.0";
    sha256 = "sha256-VIeENtuDJHK9qHkNhFCpbT1FD45KaR4L77K82fD1h6o=";
    vendorHash = "sha256-7U/b/c4TABNkI/GmIw8OUcPEaSxhlgo5PU5G3fF7DvQ=";
  };
  opm_1_60 = lib.makeOverridable opmGen {
    version = "1.60.0";
    sha256 = "sha256-ecXtpsW5T0dauE7cjW0RjWOoaQkIFIWLwwGuAuyP/Ok=";
    vendorHash = "sha256-10JW3wM1bHqO9JDys6U6Wl3vKHa5gjG28PTLaVK1MGg=";
  };
  opm_1_59 = lib.makeOverridable opmGen {
    version = "1.62.0";
    sha256 = "sha256-VIeENtuDJHK9qHkNhFCpbT1FD45KaR4L77K82fD1h6o=";
    vendorHash = "sha256-7U/b/c4TABNkI/GmIw8OUcPEaSxhlgo5PU5G3fF7DvQ=";
  };
  opm = opm_1_61;
}
