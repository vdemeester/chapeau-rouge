{ stdenv, lib, fetchurl }:

with lib;
let
  versionsMeta = importJSON ../repos/openshift-install.json;
in
rec {
  openshiftInstallGen =
    { version
    , aarch64-darwin-sha256
    , aarch64-linux-sha256
    , x86_64-darwin-sha256
    , x86_64-linux-sha256
    }:

    let
      # https://mirror.openshift.com/pub/openshift-v4/arm64/clients/ocp/4.9.49/openshift-client-linux.tar.gz
      getUrl = version:
        if (stdenv.isAarch64 && stdenv.isDarwin) then "https://mirror.openshift.com/pub/openshift-v4/aarch64/clients/ocp/${version}/openshift-install-mac-${version}.tar.gz"
        else if (stdenv.isAarch64 && stdenv.isLinux) then "https://mirror.openshift.com/pub/openshift-v4/aarch64/clients/ocp/${version}/openshift-install-linux-${version}.tar.gz"
        else if (stdenv.isx86_64 && stdenv.isDarwin) then "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${version}/openshift-install-mac-${version}.tar.gz"
        else if (stdenv.isx86_64 && stdenv.isLinux) then "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${version}/openshift-install-linux-${version}.tar.gz"
        else throw "unsupported platform";
      sha256 =
        if (stdenv.isAarch64 && stdenv.isDarwin) then aarch64-darwin-sha256
        else if (stdenv.isAarch64 && stdenv.isLinux) then aarch64-linux-sha256
        else if (stdenv.isx86_64 && stdenv.isDarwin) then x86_64-darwin-sha256
        else if (stdenv.isx86_64 && stdenv.isLinux) then x86_64-linux-sha256
        else throw "unsupported platform";
    in
    stdenv.mkDerivation rec {
      pname = "openshift-install";
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
        install -D ${name}/openshift-install $out/bin/openshift-install
        patchelf \
          --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
          $out/bin/openshift-install || true # in case it is dynamically linked
        # completions
        mkdir -p $out/share/bash-completion/completions/
        $out/bin/openshift-install completion bash > $out/share/bash-completion/completions/openshift-install
        #mkdir -p $out/share/zsh/site-functions
        #$out/bin/openshift-install completion zsh > $out/share/zsh/site-functions/_openshift-install
      '';

      meta = {
        description = "Install an OpenShift cluster";
        homepage = "https://github.com/openshift/installer";
        license = lib.licenses.asl20;
      };
    };

  openshift-install = openshift-install_4_15;
  openshift-install_4_15 = makeOverridable openshiftInstallGen {
    version = versionsMeta."4.15".version;
    aarch64-darwin-sha256 = versionsMeta."4.15".darwin.aarch64;
    aarch64-linux-sha256 = versionsMeta."4.15".linux.aarch64;
    x86_64-darwin-sha256 = versionsMeta."4.15".darwin.x86_64;
    x86_64-linux-sha256 = versionsMeta."4.15".linux.x86_64;
  };
  openshift-install_4_14 = makeOverridable openshiftInstallGen {
    version = versionsMeta."4.14".version;
    aarch64-darwin-sha256 = versionsMeta."4.14".darwin.aarch64;
    aarch64-linux-sha256 = versionsMeta."4.14".linux.aarch64;
    x86_64-darwin-sha256 = versionsMeta."4.14".darwin.x86_64;
    x86_64-linux-sha256 = versionsMeta."4.14".linux.x86_64;
  };
  openshift-install_4_13 = makeOverridable openshiftInstallGen {
    version = versionsMeta."4.13".version;
    aarch64-darwin-sha256 = versionsMeta."4.13".darwin.aarch64;
    aarch64-linux-sha256 = versionsMeta."4.13".linux.aarch64;
    x86_64-darwin-sha256 = versionsMeta."4.13".darwin.x86_64;
    x86_64-linux-sha256 = versionsMeta."4.13".linux.x86_64;
  };
  openshift-install_4_12 = makeOverridable openshiftInstallGen {
    version = versionsMeta."4.12".version;
    aarch64-darwin-sha256 = versionsMeta."4.12".darwin.aarch64;
    aarch64-linux-sha256 = versionsMeta."4.12".linux.aarch64;
    x86_64-darwin-sha256 = versionsMeta."4.12".darwin.x86_64;
    x86_64-linux-sha256 = versionsMeta."4.12".linux.x86_64;
  };
  openshift-install_4_11 = makeOverridable openshiftInstallGen {
    version = versionsMeta."4.11".version;
    aarch64-darwin-sha256 = versionsMeta."4.11".darwin.aarch64;
    aarch64-linux-sha256 = versionsMeta."4.11".linux.aarch64;
    x86_64-darwin-sha256 = versionsMeta."4.11".darwin.x86_64;
    x86_64-linux-sha256 = versionsMeta."4.11".linux.x86_64;
  };
  openshift-install_4_10 = makeOverridable openshiftInstallGen {
    version = versionsMeta."4.10".version;
    aarch64-darwin-sha256 = versionsMeta."4.10".darwin.aarch64;
    aarch64-linux-sha256 = versionsMeta."4.10".linux.aarch64;
    x86_64-darwin-sha256 = versionsMeta."4.10".darwin.x86_64;
    x86_64-linux-sha256 = versionsMeta."4.10".linux.x86_64;
  };
  openshift-install_4_9 = makeOverridable openshiftInstallGen {
    version = versionsMeta."4.9".version;
    aarch64-darwin-sha256 = versionsMeta."4.9".darwin.aarch64;
    aarch64-linux-sha256 = versionsMeta."4.9".linux.aarch64;
    x86_64-darwin-sha256 = versionsMeta."4.9".darwin.x86_64;
    x86_64-linux-sha256 = versionsMeta."4.9".linux.x86_64;
  };
}
