{ stdenv, lib, buildGo118Module, fetchFromGitHub }:

with lib;
rec {
  opcGen =
    { version
    , sha256
    , rev ? "v${version}"
    }:
    buildGo118Module rec {
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

  opc_1_19 = makeOverridable opcGen {
    version = "1.9.0-rc1-2";
    sha256 = "sha256-NcmPA2UXKXTKQPztgIe0C0fwvIzjRSnuXQsikBPdgPc=";
  };
  opc = opc_1_19;

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
