{ lib
, buildGoModule
, fetchFromGitHub
, git
, gpgme
, pkg-config
, validatePkgConfig
,
}:

with lib;
rec {
  opmGen =
    { version
    , sha256
    , vendorHash
    ,
    }:

    buildGoModule rec {
      inherit vendorHash;
      pname = "opm";
      name = "${pname}-${version}";
      rev = "v${version}";

      buildInputs = [
        gpgme
      ];
      nativeBuildInputs = [
        git
        pkg-config
        validatePkgConfig
      ];
      nativeInstallCheckInputs = [ versionCheckHook ];

      subPackages = [ "cmd/opm" ];
      ldflags =
        let
          t = "github.com/operator-framework/operator-registry/cmd/opm/version";
        in
        [
          "-X ${t}.gitCommit=${version}"
          "-X ${t}.opmVersion=${version}"
        ];
      tags = [ "json1" ];

      src = fetchFromGitHub {
        inherit rev;
        owner = "operator-framework";
        repo = "operator-registry";
        sha256 = "${sha256}";
      };

      postInstall = ''
        # completions
        mkdir -p $out/share/bash-completion/completions/
        $out/bin/opm completion bash > $out/share/bash-completion/completions/opm
        mkdir -p $out/share/zsh/site-functions/
        $out/bin/opm completion zsh > $out/share/zsh/site-functions/_opm
      '';

      meta = {
        description = "Operator Registry runs in a Kubernetes or OpenShift cluster to provide operator catalog data to Operator Lifecycle Manager.

";
        homepage = "https://github.com/operator-framework/operator-registry";
        license = lib.licenses.asl20;
      };
    };

  opm_1_61 = makeOverridable opmGen {
    version = "1.61.0";
    sha256 = "sha256-EWxER6zPfz83esOo3As5cGc4GXbsA87N+1L+ov+hs2M=";
    vendorHash = "sha256-uE5flRoIpBg26AqgqgOKsETbsZa8btyerQFL1KUjfDA=";
  };
  opm_1_60 = makeOverridable opmGen {
    version = "1.60.0";
    sha256 = "sha256-ecXtpsW5T0dauE7cjW0RjWOoaQkIFIWLwwGuAuyP/Ok=";
    vendorHash = "sha256-10JW3wM1bHqO9JDys6U6Wl3vKHa5gjG28PTLaVK1MGg=";
  };
  opm_1_59 = makeOverridable opmGen {
    version = "1.59.0";
    sha256 = "sha256-04eEx5zkc4+NQjSDYxXMHSl8+Izy8TXAQyJ2+rMsK50=";
    vendorHash = "sha256-Es+wDvrNE1D97AgArZuZqhnNUtyncRcbrhjbMN4FWhk=";
  };
  opm = opm_1_61;
}
