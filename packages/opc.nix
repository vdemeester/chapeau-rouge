{ stdenv, lib, buildGo120Module, fetchFromGitHub }:

with lib;
rec {
  opcGen =
    { version
    , sha256
    , rev ? "v${version}"
    }:
    buildGo120Module rec {
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

  opc_1_13 = makeOverridable opcGen {
    version = "1.13.0";
    sha256 = "sha256-yeJV6hSs6T19xThqDibbbuWvpz1uU8/lpDE1mMZmVHA=";
  };
  opc_1_12 = makeOverridable opcGen {
    version = "1.12.1";
    sha256 = "sha256-irOv4GuFl+LQw3p47szpP5+B0Mfo5sTuA6ynRN6FwKI=";
  };
  opc_1_11 = makeOverridable opcGen {
    version = "1.11.2";
    sha256 = "sha256-DP49BB+ipfrDVASU/HHGh0nNan9VelQwf5Olv3pGMvk=";
  };
  opc_1_10 = makeOverridable opcGen {
    version = "1.10.6";
    sha256 = "sha256-Zai6n2KVTpYIQagxNrCW7CGhK5y7malcudFBzEO2gmw=";
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
