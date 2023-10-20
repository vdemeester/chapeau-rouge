{ stdenv, lib, buildGo119Module, fetchFromGitHub }:

with lib;
rec {
  opcGen =
    { version
    , sha256
    , rev ? "v${version}"
    }:
    buildGo119Module rec {
      pname = "opc";
      name = "${pname}-${version}";

      src = fetchFromGitHub {
        inherit rev;
        owner = "openshift-pipelines";
        repo = "opc";
        sha256 = "${sha256}";
      };
      vendorSha256 = null;

      patchPhase = ''
        sed -i 's/devel/${version}/' ./pkg/version.json
      '';
      postInstall = ''
        # completions
        mkdir -p $out/share/bash-completion/completions/
        $out/bin/opc completion bash > $out/share/bash-completion/completions/opc
        mkdir -p $out/share/zsh/site-functions/
        $out/bin/opc completion zsh > $out/share/zsh/site-functions/opc
      '';

      meta = {
        description = "A CLI for OpenShift Pipeline";
        homepage = "https://github.com/openshift-pipelines/opc";
        license = lib.licenses.asl20;
      };
    };

  opc_1_12 = makeOverridable opcGen {
    version = "1.12.1";
    sha256 = "sha256-irOv4GuFl+LQw3p47szpP5+B0Mfo5sTuA6ynRN6FwKI=";
  };
  opc_1_11 = makeOverridable opcGen {
    version = "1.11.0-rc1";
    sha256 = "sha256-8V1TVXxHPO2GTK0jyOrzgHpm9lsEFJMmxJ7LT1tq5mk=";
  };
  opc_1_10 = makeOverridable opcGen {
    version = "1.10.0-rc1";
    sha256 = "sha256-rLX0vpYkz/erbVc51jizKJet9hOV4AZZe0324uFVAU4=";
  };
  opc_1_9 = makeOverridable opcGen {
    version = "1.9.0-rc1-2";
    sha256 = "sha256-NcmPA2UXKXTKQPztgIe0C0fwvIzjRSnuXQsikBPdgPc=";
  };
  opc = opc_1_12;

  opc-git =
    let
      repoMeta = importJSON ../repos/opc-main.json;
    in
    makeOverridable opcGen {
      version = "${repoMeta.version}";
      rev = "${repoMeta.rev}";
      sha256 = "${repoMeta.sha256}";
    };
}
