{ stdenv, lib, fetchurl }:

with lib;
let
  versionsMeta = importJSON ../repos/oc.json;
in
rec {
  ocGen =
    { version
    , aarch64-darwin-sha256
    , aarch64-linux-sha256
    , x86_64-darwin-sha256
    , x86_64-linux-sha256
    }:

    let
      # https://mirror.openshift.com/pub/openshift-v4/arm64/clients/ocp/4.9.49/openshift-client-linux.tar.gz
      getUrl = version:
        if (stdenv.isAarch64 && stdenv.isDarwin) then "https://mirror.openshift.com/pub/openshift-v4/aarch64/clients/ocp/${version}/openshift-client-mac-${version}.tar.gz"
        else if (stdenv.isAarch64 && stdenv.isLinux) then "https://mirror.openshift.com/pub/openshift-v4/aarch64/clients/ocp/${version}/openshift-client-linux-${version}.tar.gz"
        else if (stdenv.isx86_64 && stdenv.isDarwin) then "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${version}/openshift-client-mac-${version}.tar.gz"
        else if (stdenv.isx86_64 && stdenv.isLinux) then "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${version}/openshift-client-linux-${version}.tar.gz"
        else throw "unsupported platform";
      sha256 =
        if (stdenv.isAarch64 && stdenv.isDarwin) then aarch64-darwin-sha256
        else if (stdenv.isAarch64 && stdenv.isLinux) then aarch64-linux-sha256
        else if (stdenv.isx86_64 && stdenv.isDarwin) then x86_64-darwin-sha256
        else if (stdenv.isx86_64 && stdenv.isLinux) then x86_64-linux-sha256
        else throw "unsupported platform";
    in
    stdenv.mkDerivation rec {
      pname = "oc";
      name = "${pname}-${version}";

      src = fetchurl {
        url = getUrl version;
        sha256 = "${sha256}";
      };

      phases = " unpackPhase installPhase fixupPhase ";

      unpackPhase = ''
        runHook preUnpack
        mkdir ${name}
        tar -C ${name} -xzf $src
      '';

      installPhase = ''
        runHook preInstall
        install -D ${name}/oc $out/bin/oc
        patchelf \
          --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
          $out/bin/oc
        # completions
        mkdir -p $out/share/bash-completion/completions/
        $out/bin/oc completion bash > $out/share/bash-completion/completions/oc
        mkdir -p $out/share/zsh/site-functions
        $out/bin/oc completion zsh > $out/share/zsh/site-functions/_oc
      '';
    };

  oc = oc_4_14;
  oc_4_14 = makeOverridable ocGen {
    version = versionsMeta."4.14".version;
    aarch64-darwin-sha256 = versionsMeta."4.14".darwin.aarch64;
    aarch64-linux-sha256 = versionsMeta."4.14".linux.aarch64;
    x86_64-darwin-sha256 = versionsMeta."4.14".darwin.x86_64;
    x86_64-linux-sha256 = versionsMeta."4.14".linux.x86_64;
  };
  oc_4_13 = makeOverridable ocGen {
    version = versionsMeta."4.13".version;
    aarch64-darwin-sha256 = versionsMeta."4.13".darwin.aarch64;
    aarch64-linux-sha256 = versionsMeta."4.13".linux.aarch64;
    x86_64-darwin-sha256 = versionsMeta."4.13".darwin.x86_64;
    x86_64-linux-sha256 = versionsMeta."4.13".linux.x86_64;
  };
  oc_4_12 = makeOverridable ocGen {
    version = versionsMeta."4.12".version;
    aarch64-darwin-sha256 = versionsMeta."4.12".darwin.aarch64;
    aarch64-linux-sha256 = versionsMeta."4.12".linux.aarch64;
    x86_64-darwin-sha256 = versionsMeta."4.12".darwin.x86_64;
    x86_64-linux-sha256 = versionsMeta."4.12".linux.x86_64;
  };
  oc_4_11 = makeOverridable ocGen {
    version = versionsMeta."4.11".version;
    aarch64-darwin-sha256 = versionsMeta."4.11".darwin.aarch64;
    aarch64-linux-sha256 = versionsMeta."4.11".linux.aarch64;
    x86_64-darwin-sha256 = versionsMeta."4.11".darwin.x86_64;
    x86_64-linux-sha256 = versionsMeta."4.11".linux.x86_64;
  };
  oc_4_10 = makeOverridable ocGen {
    version = versionsMeta."4.10".version;
    aarch64-darwin-sha256 = versionsMeta."4.10".darwin.aarch64;
    aarch64-linux-sha256 = versionsMeta."4.10".linux.aarch64;
    x86_64-darwin-sha256 = versionsMeta."4.10".darwin.x86_64;
    x86_64-linux-sha256 = versionsMeta."4.10".linux.x86_64;
  };
  oc_4_9 = makeOverridable ocGen {
    version = versionsMeta."4.9".version;
    aarch64-darwin-sha256 = versionsMeta."4.9".darwin.aarch64;
    aarch64-linux-sha256 = versionsMeta."4.9".linux.aarch64;
    x86_64-darwin-sha256 = versionsMeta."4.9".darwin.x86_64;
    x86_64-linux-sha256 = versionsMeta."4.9".linux.x86_64;
  };
}
