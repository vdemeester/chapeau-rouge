{ stdenv
, lib
, buildGoModule
, fetchFromGitHub
,
}:

with lib;
rec {
  koffGen =
    { version
    , sha256
    , rev ? "v${version}"
    ,
    }:
    buildGoModule rec {
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

  koff_1_0 = makeOverridable koffGen {
    version = "1.0.1";
    sha256 = "sha256-qMZcyXqQ+zEEytnQbTF37I0+sZYJRNTXyL8rgDiFI1U=";
  };
  koff = koff_1_0;

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
