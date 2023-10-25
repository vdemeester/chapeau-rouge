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

  opm_1_30 = makeOverridable opmGen {
    version = "1.30.1";
    sha256 = "sha256-2uSfIAIaIeb2DACWaueVjvTiuumzDUqLmVXi34Pj1iM=";
    vendorSha256 = "sha256-5R+gFjgFchcCSxGij0KvpSUOVsfgOY/M3PW9Npv0obg=";
  };
  opm_1_29 = makeOverridable opmGen {
    version = "1.29.0";
    sha256 = "sha256-mIZ0M+q7lF44wiXasZvrYBtk/eFbbE7h3eRLKE9AF58=";
    vendorSha256 = "sha256-HSmjr3l0Zat0bLuCUrbfqg+Jo6uLbjH/dH5rPzxg/KA=";
  };
  opm_1_28 = makeOverridable opmGen {
    version = "1.28.0";
    sha256 = "sha256-ctSoAR6qLqAtXOd32tmCLOQdvwNNItJtlpqvNvxrY1w=";
    vendorSha256 = "sha256-P7H+3pfzbmRKKS990JDWab0waCIA88ZtfdtgYFHlR08=";
  };
  opm_1_27 = makeOverridable opmGen {
    version = "1.27.1";
    sha256 = "sha256-EvtF0E7j6br4D5Z+0vOYU9CNyCgmZ8aq028SbSKOI+s=";
    vendorSha256 = "sha256-bK1jkwwUiXQysRcsxLj78I2Zey+5IPygMPV3SOgcbzU=";
  };
  opm_1_26 = makeOverridable opmGen {
    version = "1.26.5";
    sha256 = "sha256-pTwb+ywisK+4+Z18CnJVSd6JoQyqyW9iIf8Wi6TAg4k=";
    vendorSha256 = null;
  };
  opm = opm_1_30;
}
