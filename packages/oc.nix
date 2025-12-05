{ stdenv
, lib
, fetchurl
, versionCheckHook
,
}:

let
  versionsMeta = lib.importJSON ../repos/oc.json;
in
rec {
  ocGen =
    { versionData
    ,
    }:

    let
      # https://mirror.openshift.com/pub/openshift-v4/arm64/clients/ocp/4.9.49/openshift-client-linux.tar.gz
      getUrl =
        version:
        if (stdenv.isAarch64 && stdenv.isDarwin) then
          "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${version}/openshift-client-mac-arm64-${version}.tar.gz"
        else if (stdenv.isAarch64 && stdenv.isLinux) then
          "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${version}/openshift-client-linux-arm64-${version}.tar.gz"
        else if (stdenv.isx86_64 && stdenv.isDarwin) then
          "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${version}/openshift-client-mac-${version}.tar.gz"
        else if (stdenv.isx86_64 && stdenv.isLinux) then
          "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${version}/openshift-client-linux-${version}.tar.gz"
        else
          throw "unsupported platform";
      sha256 =
        data:
        if (stdenv.isAarch64 && stdenv.isDarwin) then
          data.darwin.aarch64
        else if (stdenv.isAarch64 && stdenv.isLinux) then
          data.linux.aarch64
        else if (stdenv.isx86_64 && stdenv.isDarwin) then
          data.darwin.x86_64
        else if (stdenv.isx86_64 && stdenv.isLinux) then
          data.linux.x86_64
        else
          throw "unsupported platform";
    in
    stdenv.mkDerivation (finalAttrs: {
      pname = "oc";
      version = versionData.version;

      src = fetchurl {
        url = getUrl versionData.version;
        sha256 = sha256 versionData;
      };

      dontBuild = true;
      dontConfigure = true;

      unpackPhase = ''
        runHook preUnpack
        mkdir oc-${finalAttrs.version}
        tar -C oc-${finalAttrs.version} -xzf $src
        runHook postUnpack
      '';

      installPhase = ''
        runHook preInstall
        install -D oc-${finalAttrs.version}/oc $out/bin/oc
        patchelf \
          --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
          $out/bin/oc || true # in case it is dynamically linked
        # completions
        mkdir -p $out/share/bash-completion/completions/
        $out/bin/oc completion bash > $out/share/bash-completion/completions/oc
        mkdir -p $out/share/zsh/site-functions
        $out/bin/oc completion zsh > $out/share/zsh/site-functions/_oc
        runHook postInstall
      '';

      nativeInstallCheckInputs = [ versionCheckHook ];

      meta = {
        description = "OpenShift CLI tool";
        homepage = "https://github.com/openshift/oc";
        license = lib.licenses.asl20;
        platforms = lib.platforms.linux ++ lib.platforms.darwin;
        mainProgram = "oc";
      };
    });

  oc = oc_4_20;
  oc_4_20 = lib.makeOverridable ocGen {
    versionData = versionsMeta."4.20";
  };
  oc_4_19 = lib.makeOverridable ocGen {
    versionData = versionsMeta."4.19";
  };
  oc_4_18 = lib.makeOverridable ocGen {
    versionData = versionsMeta."4.18";
  };
  oc_4_17 = lib.makeOverridable ocGen {
    versionData = versionsMeta."4.17";
  };
  oc_4_16 = lib.makeOverridable ocGen {
    versionData = versionsMeta."4.16";
  };
  oc_4_15 = lib.makeOverridable ocGen {
    versionData = versionsMeta."4.15";
  };
  oc_4_14 = lib.makeOverridable ocGen {
    versionData = versionsMeta."4.14";
  };
}
