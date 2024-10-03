{ stdenv, lib, fetchurl }:

with lib;
let
  versionsMeta = importJSON ../repos/openshift-install.json;
in
rec {
  openshiftInstallGen =
    { versionData
    }:

    let
      # https://mirror.openshift.com/pub/openshift-v4/arm64/clients/ocp/4.9.49/openshift-client-linux.tar.gz
      getUrl = version:
        if (stdenv.isAarch64 && stdenv.isDarwin) then "https://mirror.openshift.com/pub/openshift-v4/aarch64/clients/ocp/${version}/openshift-install-mac-${version}.tar.gz"
        else if (stdenv.isAarch64 && stdenv.isLinux) then "https://mirror.openshift.com/pub/openshift-v4/aarch64/clients/ocp/${version}/openshift-install-linux-${version}.tar.gz"
        else if (stdenv.isx86_64 && stdenv.isDarwin) then "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${version}/openshift-install-mac-${version}.tar.gz"
        else if (stdenv.isx86_64 && stdenv.isLinux) then "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${version}/openshift-install-linux-${version}.tar.gz"
        else throw "unsupported platform";
      sha256 = data:
        if (stdenv.isAarch64 && stdenv.isDarwin) then data.darwin.aarch64
        else if (stdenv.isAarch64 && stdenv.isLinux) then data.linux.aarch64
        else if (stdenv.isx86_64 && stdenv.isDarwin) then data.darwin.x86_64
        else if (stdenv.isx86_64 && stdenv.isLinux) then data.linux.x86_64
        else throw "unsupported platform";
    in
    stdenv.mkDerivation rec {
      pname = "openshift-install";
      name = "${pname}-${versionData.version}";

      src = fetchurl {
        url = getUrl versionData.version;
        sha256 = "${sha256 versionData}";
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

  openshift-install = openshift-install_4_17;
  openshift-install_4_17 = makeOverridable openshiftInstallGen {
    versionData = versionsMeta."4.17";
  };
  openshift-install_4_16 = makeOverridable openshiftInstallGen {
    versionData = versionsMeta."4.16";
  };
  openshift-install_4_15 = makeOverridable openshiftInstallGen {
    versionData = versionsMeta."4.15";
  };
  openshift-install_4_14 = makeOverridable openshiftInstallGen {
    versionData = versionsMeta."4.14";
  };
  openshift-install_4_13 = makeOverridable openshiftInstallGen {
    versionData = versionsMeta."4.13";
  };
}
