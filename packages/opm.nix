{ lib, buildGoModule, fetchFromGitHub }:

with lib;
rec {
  opmGen =
    { version
    , sha256
    , vendorSha256
    }:

    buildGoModule rec {
      inherit vendorSha256;
      pname = "opm";
      name = "${pname}-${version}";
      rev = "v${version}";

      builtInputs = [ "git" ];

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

  opm_1_26 = makeOverridable opmGen {
    version = "1.26.2";
    sha256 = "sha256-I87PvfP6IU9OT0EkogKsE2Dl5UK7Z2RoRM/WlcuJAq8=";
    vendorSha256 = null;
  };
  opm = opm_1_26;
}
