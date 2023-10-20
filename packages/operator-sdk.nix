{ stdenv, lib, buildGo119Module, fetchFromGitHub, sqlite }:

with lib;
rec {
  operatorSdkGen =
    { version
    , k8sVersion
    , sha256
    , vendorSha256
    }:

    buildGo119Module rec {
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
    version = "1.25.4";
    k8sVersion = "1.25";
    sha256 = "sha256-uLWGE/FL4sfcFz9caVMgdFGzH8jsuFIXNAT8PdhqUio=";
    vendorSha256 = "sha256-L+Z1k+z/XNO9OeTQVzNJd1caRip6Ti8mPfNmXJx5D5c=";
  };
  operator-sdk_1_26 = makeOverridable operatorSdkGen {
    version = "1.26.1";
    k8sVersion = "1.25";
    sha256 = "sha256-D82tFN0EUmcRUkXf8kSaxzVacS+Ggwa+8D5f8ZSvVy0=";
    vendorSha256 = "sha256-L+Z1k+z/XNO9OeTQVzNJd1caRip6Ti8mPfNmXJx5D5c=";
  };
  operator-sdk_1_27 = makeOverridable operatorSdkGen {
    version = "1.27.0";
    k8sVersion = "1.25";
    sha256 = "sha256-rvLWM6G2kOOuFU0JuwdIjSCFNyjBNL+fOoEj+tIR190=";
    vendorSha256 = "sha256-L+Z1k+z/XNO9OeTQVzNJd1caRip6Ti8mPfNmXJx5D5c=";
  };
  operator-sdk_1_28 = makeOverridable operatorSdkGen {
    version = "1.28.1";
    k8sVersion = "1.26";
    sha256 = "sha256-YzkPAKwkV8io0lz7JxIX4lciv85iqldkyitrLicbFJc=";
    vendorSha256 = "sha256-ZWOIF3vmtoXzdGHHzjPy/351bHzMTTXcgSRBso+ixyM=";
  };
  operator-sdk_1_29 = makeOverridable operatorSdkGen {
    version = "1.29.0";
    k8sVersion = "1.26";
    sha256 = "sha256-oHGs1Bx5k02k6mp9WAe8wIQ4FjMOREcUYv0DKZaXGdE==";
    vendorSha256 = "sha256-I2vL4uRmUbgaf3KGUHSQV2jWozStKHyjek3BQlxyY/c=";
  };
  operator-sdk_1_30 = makeOverridable operatorSdkGen {
    version = "1.30.0";
    k8sVersion = "1.26";
    sha256 = "sha256-mDjBu25hOhm3FrUDsFq1rjBn58K91Bao8gqN2heZ9ps=";
    vendorSha256 = "sha256-QfTWjSsWpbbGgKrv4U2E6jA6eAT4wnj0ixpUqDxtsY8=";
  };
  operator-sdk_1_31 = makeOverridable operatorSdkGen {
    version = "1.31.0";
    k8sVersion = "1.26";
    sha256 = "sha256-v/7nqZg/lwiK2k92kQWSZCSjEZhTAQHCGBcTfxQX2r0=";
    vendorSha256 = "sha256-geKWTsDLx5drTleTnneg2JIbe5sMS5JUQxTX9Bcm+IQ=";
  };
  operator-sdk_1_32 = makeOverridable operatorSdkGen {
    version = "1.32.0";
    k8sVersion = "1.26";
    sha256 = "sha256-sWnHx9IKwr6um9YlrF2ULQ7HZo0TNC4MpWHTVpmWqFs=";
    vendorSha256 = "sha256-Gl0LUlMLeku2B5DkWpzeoXfMLb/OnOx4Urw4RF4cuTQ=";
  };
  operator-sdk_1 = operator-sdk_1_32;
  operator-sdk = operator-sdk_1;
}
