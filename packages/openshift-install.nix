{ stdenv, lib, fetchurl }:

with lib;
let
  versionsMeta = importJSON ../repos/openshift-install.json;
in
rec {
  openshiftInstallGen =
    { versionData
    , target
    }:

    let
      # https://mirror.openshift.com/pub/openshift-v4/arm64/clients/ocp/4.9.49/openshift-client-linux.tar.gz
      getUrl = version: target:
        if stdenv.isAarch64 then getLinuxAarch64Url version target
        else if stdenv.isx86_64 then getLinuxAmd64Url version target
        else throw "unsupported architecture";
      getLinuxAarch64Url = version: target:
        if (target == "aarch64-linux") then "https://mirror.openshift.com/pub/openshift-v4/aarch64/clients/ocp/${version}/openshift-install-linux-${version}.tar.gz"
        else if (target == "x86_64-linux") then "https://mirror.openshift.com/pub/openshift-v4/aarch64/clients/ocp/${version}/openshift-install-linux-amd64-${version}.tar.gz"
        else throw "unsupported target architecture (${target})";
      getLinuxAmd64Url = version: target:
        if (target == "aarch64-linux") then "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${version}/openshift-install-linux-arm64-${version}.tar.gz"
        else if (target == "x86_64-linux") then "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${version}/openshift-install-linux-${version}.tar.gz"
        else throw "unsupported target architecture (${target})";
      sha256 = data: target:
        if stdenv.isAarch64 then sha256Aarch64 data target
        else if stdenv.isx86_64 then sha256Amd64 data target
        else throw "unsupported architecture";
      sha256Aarch64 = data: target:
        if (target == "aarch64-linux") then data.linux.aarch64.arm64
        else if (target == "x86_64-linux") then data.linux.aarch64.amd64
        else throw "unsupported target architecture (${target})";
      sha256Amd64 = data: target:
        if (target == "aarch64-linux") then data.linux.x86_64.arm64
        else if (target == "x86_64-linux") then data.linux.x86_64.amd64
        else throw "unsupported target architecture (${target})";
    in
    stdenv.mkDerivation rec {
      pname = "openshift-install";
      name = "${pname}-${versionData.version}";

      src = fetchurl {
        url = getUrl versionData.version target;
        sha256 = "${sha256 versionData target}";
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
  openshift-install-arm64 = openshift-install-arm64_4_15;
  openshift-install-amd64 = openshift-install-amd64_4_15;
  openshift-install_4_15 = makeOverridable openshiftInstallGen {
    versionData = versionsMeta."4.15";
    target = stdenv.buildPlatform.system;
  };
  openshift-install-arm64_4_15 = makeOverridable openshiftInstallGen {
    versionData = versionsMeta."4.15";
    target = "aarch64-linux";
  };
  openshift-install-amd64_4_15 = makeOverridable openshiftInstallGen {
    versionData = versionsMeta."4.15";
    target = "x86_64-linux";
  };
  openshift-install_4_14 = makeOverridable openshiftInstallGen {
    versionData = versionsMeta."4.14";
    target = stdenv.buildPlatform.system;
  };
  openshift-install-arm64_4_14 = makeOverridable openshiftInstallGen {
    versionData = versionsMeta."4.14";
    target = "aarch64-linux";
  };
  openshift-install-amd64_4_14 = makeOverridable openshiftInstallGen {
    versionData = versionsMeta."4.14";
    target = "x86_64-linux";
  };
  openshift-install_4_13 = makeOverridable openshiftInstallGen {
    versionData = versionsMeta."4.13";
    target = stdenv.buildPlatform.system;
  };
  openshift-install-arm64_4_13 = makeOverridable openshiftInstallGen {
    versionData = versionsMeta."4.13";
    target = "aarch64-linux";
  };
  openshift-install-amd64_4_13 = makeOverridable openshiftInstallGen {
    versionData = versionsMeta."4.13";
    target = "x86_64-linux";
  };
}
