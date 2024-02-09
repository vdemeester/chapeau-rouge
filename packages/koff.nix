{ stdenv, lib, buildGo119Module, fetchFromGitHub }:

with lib;
rec {
  koffGen =
    { version
    , sha256
    , rev ? "v${version}"
    }:
    buildGo119Module rec {
      pname = "koff";
      name = "${pname}-${version}";

      subPackages = [ "." ];
      ldflags =
        let
          t = "github.com/gmeghnag/koff/vars";
        in
        [
          "-s"
          "-w"
          "-X ${t}.KoffVersionTag=${version}"
        ];

      src = fetchFromGitHub {
        inherit rev;
        owner = "gmeghnag";
        repo = "koff";
        sha256 = "${sha256}";
      };
      vendorHash = null;

      doCheck = false;
      preBuild = ''
        export HOME=$(pwd)
      '';
      preInstall = ''
        pwd
        ls -la .
      '';
      postInstall = ''
        # completions
        mkdir -p $out/share/bash-completion/completions/
        $out/bin/koff completion bash > $out/share/bash-completion/completions/koff
        mkdir -p $out/share/zsh/site-functions/
        $out/bin/koff completion zsh > $out/share/zsh/site-functions/koff
      '';

      meta = {
        description = "OpenShift Must-Gather Client";
        homepage = "https://github.com/gmeghnag/koff";
        license = lib.licenses.asl20;
      };
    };

  koff_0_11 = makeOverridable koffGen {
    version = "0.11.0";
    sha256 = "sha256-8sS02JSt98/Ixe3V2IX+5bHA2KP4grBSn97AeyJizjI=";
  };
  koff_0_10 = makeOverridable koffGen {
    version = "0.10.0";
    sha256 = "sha256-QleDch0c95GUgo9fnNdW7Gt+BmggCaYdgkmiOZFO1/E=";
  };
  koff = koff_0_11;

  koff-git =
    let
      repoMeta = importJSON ../repos/koff-main.json;
    in
    makeOverridable koffGen {
      version = "${repoMeta.version}";
      rev = "${repoMeta.rev}";
      sha256 = "${repoMeta.sha256}";
    };
}
