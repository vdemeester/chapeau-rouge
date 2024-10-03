{ lib, buildGoModule, fetchFromGitHub }:

with lib;
rec {
  opmGen =
    { version
    , sha256
    , vendorHash
    }:

    buildGoModule rec {
      inherit vendorHash;
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

  opm_1_47 = makeOverridable opmGen {
    version = "1.47.0";
    sha256 = "sha256-EEOlNW6WCuCGp2r4aRzI8AYWwR1mCurCS2PZ9TisN8I=";
    vendorHash = "sha256-y9ox3DJnuVeAsUOO1PiF9ptVblUt+MJLkvg2eB5W60w=";
  };
  opm_1_46 = makeOverridable opmGen {
    version = "1.46.0";
    sha256 = "sha256-Kf3QnRy4UvnLgA5p+pIPnGBY53BSFCS7ba1spUMekq4=";
    vendorHash = "sha256-gQj0v6UVYwJfwELIrKP+xjQb5mDCxUjA/1qAPpsfQOg=";
  };
  opm_1_45 = makeOverridable opmGen {
    version = "1.45.0";
    sha256 = "sha256-fYjhg/ArgcfsZeKjO5VBgovs0kUoJzf0BgiW3QP62Uk=";
    vendorHash = "sha256-0SOjxxJWlI38QNupWN6zIZF0ruqavmSV9e/k1UmbQvc=";
  };
  opm_1_44 = makeOverridable opmGen {
    version = "1.44.0";
    sha256 = "sha256-LneJaLm30h1LDnx6BSqCvAvaIL375oLRRJhJ3JgBdFc=";
    vendorHash = "sha256-IzDPBu/EnMmJWe5TB4ww8dMhWB6O80OX7XXrAqkz6Vk=";
  };
  opm_1_43 = makeOverridable opmGen {
    version = "1.43.1";
    sha256 = "sha256-m2TfAAP078GPbV4jXtgHq8OKtg7Yw4GGLYgrPMExZQw=";
    vendorHash = "sha256-bPbSbcS2a9PHjAxs03CWGOT83/jwKmkKP3Khon+zrMg=";
  };
  opm_1_42 = makeOverridable opmGen {
    version = "1.42.0";
    sha256 = "sha256-qzEEDmT0xHxRyTDZwD+BwevdYkfNZqeP8gQu3ML6i/M=";
    vendorHash = "sha256-7zuD9qKbeFaVK707103pcatHdg7qdgl1fAIMmHHx+3M=";
  };
  opm_1_41 = makeOverridable opmGen {
    version = "1.41.0";
    sha256 = "sha256-50eoOhmKxWYhjf3hUPpyAOobj6vM9piObpSW5+DKZXM=";
    vendorHash = "sha256-7nt/LSQXSntzUbfO4WVUB6bWNWWGUyUmyawm4vApM1w=";
  };
  opm_1_40 = makeOverridable opmGen {
    version = "1.40.0";
    sha256 = "sha256-+EmoWuWLGJ+JROb5MSREK25kxKPErZX+KTwCm34uj/0=";
    vendorHash = "sha256-kst+Y6E0tvfBQxlx8IXdgAwIxwzRiQrNiNReGmdASqI=";
  };
  opm_1_39 = makeOverridable opmGen {
    version = "1.39.0";
    sha256 = "sha256-SnR22t9IDiRTB0xo8gTO9YprgMchp5+T8bGc0GdNfU4=";
    vendorHash = "sha256-Of0ngmLRKXBcWBXgY1hzlQXj10ZcIV3BkbErTk3K3zw=";
  };
  opm = opm_1_47;
}
