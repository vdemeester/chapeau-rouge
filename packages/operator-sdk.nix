{ stdenv, lib, buildGo121Module, fetchFromGitHub, sqlite }:

with lib;
rec {
  operatorSdkGen =
    { version
    , k8sVersion
    , sha256
    , vendorHash
    }:

    buildGo121Module rec {
      inherit vendorHash;
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
      modSha256 = "${vendorHash}";

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

  operator-sdk_1_37 = makeOverridable operatorSdkGen {
    version = "1.37.0";
    k8sVersion = "1.29";
    sha256 = "sha256-ANG9KpyEO+fpjelYU+HNTkbg2S0vFNyPzPRFjcLoLOI=";
    vendorHash = "sha256-pr3WTUZetps/Gof8lttN2beomiobVPCgX0j9V77g5sI=";
  };
  operator-sdk_1_36 = makeOverridable operatorSdkGen {
    version = "1.36.1";
    k8sVersion = "1.29";
    sha256 = "sha256-ZUWbM2g3l5uesM9QDlRqRo9gFipgaS8YyEbnIyRaMS0=";
    vendorHash = "sha256-FEoAV3Fhmjhkc7sYfE1QQFmhOZbXps57mBD0fyvQq00=";
  };
  operator-sdk_1_34 = makeOverridable operatorSdkGen {
    version = "1.34.2";
    k8sVersion = "1.28";
    sha256 = "sha256-vVa1ljPRSHSo7bVqPkRt/jbuSlzLmnVaLnyreskwOrM=";
    vendorHash = "sha256-YspUrnSS6d8Ta8dmUjx9A5D/V5Bqm08DQJrRBaIGyQg=";
  };
  operator-sdk_1_33 = makeOverridable operatorSdkGen {
    version = "1.33.0";
    k8sVersion = "1.27";
    sha256 = "sha256-Q8G/B9apvjvW45WSPXHSn6e5mZSsahNl6ymfguOeSa0=";
    vendorHash = "sha256-WoebO6RDwDyflXwHTJxRLAyNpmic2gahIaLO/i6Q1cc=";
  };
  operator-sdk_1_32 = makeOverridable operatorSdkGen {
    version = "1.32.0";
    k8sVersion = "1.26";
    sha256 = "sha256-sWnHx9IKwr6um9YlrF2ULQ7HZo0TNC4MpWHTVpmWqFs=";
    vendorHash = "sha256-Gl0LUlMLeku2B5DkWpzeoXfMLb/OnOx4Urw4RF4cuTQ=";
  };
  operator-sdk_1_31 = makeOverridable operatorSdkGen {
    version = "1.31.0";
    k8sVersion = "1.26";
    sha256 = "sha256-v/7nqZg/lwiK2k92kQWSZCSjEZhTAQHCGBcTfxQX2r0=";
    vendorHash = "sha256-geKWTsDLx5drTleTnneg2JIbe5sMS5JUQxTX9Bcm+IQ=";
  };
  operator-sdk_1_30 = makeOverridable operatorSdkGen {
    version = "1.30.0";
    k8sVersion = "1.26";
    sha256 = "sha256-mDjBu25hOhm3FrUDsFq1rjBn58K91Bao8gqN2heZ9ps=";
    vendorHash = "sha256-QfTWjSsWpbbGgKrv4U2E6jA6eAT4wnj0ixpUqDxtsY8=";
  };
  operator-sdk_1 = operator-sdk_1_37;
  operator-sdk = operator-sdk_1;
}
