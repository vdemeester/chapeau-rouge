{ stdenv, lib, buildGo122Module, fetchFromGitHub }:

with lib;
rec {
  opcGen =
    { version
    , sha256
    , rev ? "v${version}"
    }:
    buildGo122Module rec {
      pname = "opc";
      name = "${pname}-${version}";

      src = fetchFromGitHub {
        inherit rev;
        owner = "openshift-pipelines";
        repo = "opc";
        sha256 = "${sha256}";
      };
      vendorHash = null;

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

  opc_1_14 = makeOverridable opcGen {
    version = "1.14.3";
    sha256 = "sha256-c24TCLlnrRlPxBBO4fFpkz2+ITneJXaXjedLYYrYy2g=";
  };
  opc_1_13 = makeOverridable opcGen {
    version = "1.13.0";
    sha256 = "sha256-yeJV6hSs6T19xThqDibbbuWvpz1uU8/lpDE1mMZmVHA=";
  };
  opc_1_12 = makeOverridable opcGen {
    version = "1.12.1";
    sha256 = "sha256-irOv4GuFl+LQw3p47szpP5+B0Mfo5sTuA6ynRN6FwKI=";
  };
  opc = opc_1_14;

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
