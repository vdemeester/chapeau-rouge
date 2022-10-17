{ stdenv, lib, fetchurl }:

with lib;
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

  oc = oc_4_11;
  oc_4_11 = makeOverridable ocGen {
    version = "4.11.9";
    aarch64-darwin-sha256 = "10cfl22c9jilh5gxgf7cxy76z52pfhh6411g4vsg1phhdn0vj7rw";
    aarch64-linux-sha256 = "0vxb568g6wsfr1vvfgl1c1r885q2bnmdxkmb6rwp0lm2dlgbsxmx";
    x86_64-darwin-sha256 = "1597xp3ih62qhxdy4h5kigij8iwkz07qi0smsb6790c6gml7q0wc";
    x86_64-linux-sha256 = "11crwdmwf4v8h65kyfagzqh7aphvqix4xmds968r79211y3zm3w8";
  };
  oc_4_10 = makeOverridable ocGen {
    version = "4.10.37";
    aarch64-darwin-sha256 = "1fx2b98cl6la2ckxnw36yfydjd6l18nzw9a9y5ljjyxfsrr6nirx";
    aarch64-linux-sha256 = "03yhb51cjcf5f4g19bf4s29vgi3p1qmnycncdpb00k9ym118iql8";
    x86_64-darwin-sha256 = "1f1kwzi6ymaf0m5498zj28j2g2ks2mpfff9qah72a9mykgrf5g1g";
    x86_64-linux-sha256 = "11crwdmwf4v8h65kyfagzqh7aphvqix4xmds968r79211y3zm3w8";
  };
  oc_4_9 = makeOverridable ocGen {
    version = "4.9.49";
    aarch64-darwin-sha256 = "1fx2b98cl6la2ckxnw36yfydjd6l18nzw9a9y5ljjyxfsrr6nirx";
    aarch64-linux-sha256 = "0i6d54sca05iaijk02afdqjhnhbgw5lag7h9zhs424dxl9qjrzlg";
    x86_64-darwin-sha256 = "1f9fsfbmcnx0sc0kglb0rv34np6bjgfsi0zcn9qsd7hh2ym48br7";
    x86_64-linux-sha256 = "1hc6m2r7p188zsd8d10dn4vr59pizrcykaghsph09g46l0zcnjz3";
  };
}
