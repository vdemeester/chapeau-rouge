{
  stdenv,
  lib,
  fetchurl,
  versionCheckHook,
}:

let
  versionsMeta = lib.importJSON ../repos/openshift-install.json;

  openshiftInstallGen =
    {
      versionData,
    }:

    let
      # https://mirror.openshift.com/pub/openshift-v4/arm64/clients/ocp/4.9.49/openshift-client-linux.tar.gz
      getUrl =
        version:
        if (stdenv.isAarch64 && stdenv.isDarwin) then
          "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${version}/openshift-install-mac-arm64-${version}.tar.gz"
        else if (stdenv.isAarch64 && stdenv.isLinux) then
          "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${version}/openshift-install-linux-arm64-${version}.tar.gz"
        else if (stdenv.isx86_64 && stdenv.isDarwin) then
          "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${version}/openshift-install-mac-${version}.tar.gz"
        else if (stdenv.isx86_64 && stdenv.isLinux) then
          "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${version}/openshift-install-linux-${version}.tar.gz"
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
      pname = "openshift-install";
      version = versionData.version;

      src = fetchurl {
        url = getUrl versionData.version;
        sha256 = sha256 versionData;
      };

      dontBuild = true;
      dontConfigure = true;

      unpackPhase = ''
        runHook preUnpack
        mkdir openshift-install-${finalAttrs.version}
        tar -C openshift-install-${finalAttrs.version} -xzf $src
        runHook postUnpack
      '';

      installPhase = ''
        runHook preInstall
        install -D openshift-install-${finalAttrs.version}/openshift-install $out/bin/openshift-install
        patchelf \
          --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
          $out/bin/openshift-install || true # in case it is dynamically linked
        # completions
        mkdir -p $out/share/bash-completion/completions/
        $out/bin/openshift-install completion bash > $out/share/bash-completion/completions/openshift-install
        #mkdir -p $out/share/zsh/site-functions
        #$out/bin/openshift-install completion zsh > $out/share/zsh/site-functions/_openshift-install
        runHook postInstall
      '';
      nativeInstallCheckInputs = [ versionCheckHook ];

      meta = {
        description = "Install an OpenShift cluster";
        homepage = "https://github.com/openshift/installer";
        license = lib.licenses.asl20;
        platforms = lib.platforms.linux ++ lib.platforms.darwin;
        mainProgram = "openshift-install";
      };
    });

  # Dynamically generate versioned packages from the JSON
  # e.g., "4.20" -> openshift-install_4_20
  versionedPackages = lib.mapAttrs' (
    version: data:
    let
      attrName = "openshift-install_${builtins.replaceStrings [ "." ] [ "_" ] version}";
    in
    lib.nameValuePair attrName (lib.makeOverridable openshiftInstallGen { versionData = data; })
  ) versionsMeta;

  # Find the latest version (highest major.minor)
  sortedVersions = builtins.sort (
    a: b:
    let
      aParts = lib.splitString "." a;
      bParts = lib.splitString "." b;
      aMajor = lib.toInt (builtins.elemAt aParts 0);
      aMinor = lib.toInt (builtins.elemAt aParts 1);
      bMajor = lib.toInt (builtins.elemAt bParts 0);
      bMinor = lib.toInt (builtins.elemAt bParts 1);
    in
    if aMajor != bMajor then aMajor > bMajor else aMinor > bMinor
  ) (builtins.attrNames versionsMeta);

  latestVersion = builtins.head sortedVersions;
  latestAttrName = "openshift-install_${builtins.replaceStrings [ "." ] [ "_" ] latestVersion}";
in
versionedPackages
// {
  # Default to the latest version
  openshift-install = versionedPackages.${latestAttrName};
}
