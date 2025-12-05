{ stdenv
, lib
, buildGoModule
, fetchFromGitHub
, git
, sqlite
, gpgme
, pkg-config
, validatePkgConfig
,
}:

with lib;
rec {
  operatorSdkGen =
    { version
    , k8sVersion
    , sha256
    , vendorHash
    ,
    }:

    buildGoModule rec {
      inherit version vendorHash;
      pname = "operator-sdk";
      rev = "v${version}";

      buildInputs = [
        sqlite
        gpgme
      ];
      nativeBuildInputs = [
        git
        pkg-config
        validatePkgConfig
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
          "-X ${t}.GitVersion=${version}"
          "-X ${t}.KubernetesVersion=${k8sVersion}"
        ];
      CGO_CFLAGS = lib.optionals stdenv.cc.isGNU [ "-Wno-return-local-addr" ];

      src = fetchFromGitHub {
        inherit rev;
        owner = "operator-framework";
        repo = "operator-sdk";
        sha256 = sha256;
      };

      postInstall = ''
        # completions
        mkdir -p $out/share/bash-completion/completions/
        $out/bin/operator-sdk completion bash > $out/share/bash-completion/completions/operator-sdk
        mkdir -p $out/share/zsh/site-functions/
        $out/bin/operator-sdk completion zsh > $out/share/zsh/site-functions/_operator-sdk
      '';

      meta = {
        description = "SDK for building Kubernetes applications. Provides high level APIs, useful abstractions, and project scaffolding";
        homepage = "https://github.com/operator-framework/operator-sdk";
        license = lib.licenses.asl20;
        platforms = lib.platforms.unix;
        mainProgram = "operator-sdk";
      };
    };

  operator-sdk_1_42 = makeOverridable operatorSdkGen {
    version = "1.42.0";
    k8sVersion = "1.32";
    sha256 = "sha256-iXLAFFO7PCxA8QuQ9pMmQ/GBbVM5wBy9cVzSQRHHPrg=";
    vendorHash = "sha256-F2ZYEEFG8hqCcy16DUmP9ilG6e20nXBiJnB6U+wezAo=";
  };
  operator-sdk_1_41 = makeOverridable operatorSdkGen {
    version = "1.41.1";
    k8sVersion = "1.32";
    sha256 = "sha256-J9vdLXJ5qw+Gz5I03l0CDsYw1AwCOSjYX5jP9Qo/UU8=";
    vendorHash = "sha256-O2PVS3mwqz0n+TG9SIHzlbm19JEXTWHkoIzn/snloss=";
  };
  operator-sdk_1_40 = makeOverridable operatorSdkGen {
    version = "1.40.0";
    k8sVersion = "1.32";
    sha256 = "sha256-7vTVoijlVSw7rLNqvz3EH2KxsWkOthhhhpO6A7f8WUE=";
    vendorHash = "sha256-4G6OpJgcTLGS+gzBdUjF5+uDCc5d4Z+MEkFFD0AymmU=";
  };
  operator-sdk_1 = operator-sdk_1_42;
  operator-sdk = operator-sdk_1;
}
