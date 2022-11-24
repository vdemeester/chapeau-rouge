{ stdenv, lib, buildGo118Module, fetchFromGitHub, sqlite }:

with lib;
rec {
  operatorSdkGen =
    { version
    , k8sVersion
    , sha256
    , vendorSha256
    }:

    buildGo118Module rec {
      inherit vendorSha256;
      pname = "operator-sdk";
      name = "${pname}-${version}";
      rev = "v${version}";

      builtInputs = [ "git" sqlite ];

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
        sha256 = "${sha256}";
      };
      modSha256 = "${vendorSha256}";

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
      };
    };

  operator-sdk_1_22 = makeOverridable operatorSdkGen {
    version = "1.22.2";
    k8sVersion = "1.24";
    sha256 = "sha256-SpSdVJeN+rOZ6jeFPKadXKQLBZmrLjbrBrJsK9zDiZg=";
    vendorSha256 = "sha256-MiA3XbdSwzZLilvrqlNU8e2nMAfhmVnNeG1oUx4ISRU=";
  };
  operator-sdk_1_23 = makeOverridable operatorSdkGen {
    version = "1.23.0";
    k8sVersion = "1.24";
    sha256 = "sha256-2/zXdhRp8Q7e9ty0Zp+fpmcLNW6qfrW6ND83sypx9Xw=";
    vendorSha256 = "sha256-3/kU+M+oKaPJkqMNuvd1ANlHRnXhaUrofj/rl3CS5Ao=";
  };
  operator-sdk_1_24 = makeOverridable operatorSdkGen {
    version = "1.24.1";
    k8sVersion = "1.24";
    sha256 = "sha256-6Al9EkAnaa7/wJzV4xy6FifPXa4MdA9INwJWpkWzCb8=";
    vendorSha256 = "sha256-eczTVlArpO+uLC6IsTkj4LBIi+fXq7CMBf1zJShDN58=";
  };
  operator-sdk_1_25 = makeOverridable operatorSdkGen {
    version = "1.25.2";
    k8sVersion = "1.25";
    sha256 = "sha256-ZGcXb4RP+4ae0aAcLNL9JKLUqyoO5qCShDDbbxoge1w=";
    vendorSha256 = "sha256-1Vz+SIrNULajDqzZt53+o9wv1zLPBvKrO28BTqS4VbM=";
  };
  operator-sdk_1 = operator-sdk_1_25;
  operator-sdk = operator-sdk_1;
}
