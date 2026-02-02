_self: super:
let
  inherit (super)
    lib
    stdenv
    fetchurl
    fetchFromGitHub
    versionCheckHook
    ;
  inherit (super)
    buildGoModule
    installShellFiles
    git
    gpgme
    pkg-config
    validatePkgConfig
    sqlite
    ;
  inherit (super) python3Packages;

  mkGitOc =
    namePrefix: jsonFile:
    { ... }:
    let
      repoMeta = lib.importJSON jsonFile;
      fetcher =
        if repoMeta.type == "github" then
          fetchFromGitHub
        else
          throw "Unknown repository type ${repoMeta.type}!";
    in
    builtins.foldl' (drv: fn: fn drv) super.openshift ([
      (
        drv:
        drv.overrideAttrs (_old: {
          name = "${namePrefix}-${repoMeta.version}";
          inherit (repoMeta) version rev;
          src = fetcher (
            builtins.removeAttrs repoMeta [
              "type"
              "version"
            ]
          );
          ldflags = [
            "-s"
            "-w"
            "-X github.com/openshift/oc/pkg/version.commitFromGit=${repoMeta.rev}"
            "-X github.com/openshift/oc/pkg/version.versionFromGit=v${repoMeta.version}"
          ];
        })
      )
    ]);

  # Import package sets with explicit arguments to avoid callPackage cycle
  ocPackages = import ../packages/oc.nix {
    inherit
      stdenv
      lib
      fetchurl
      versionCheckHook
      ;
  };
  openshiftInstallPackages = import ../packages/openshift-install.nix {
    inherit
      stdenv
      lib
      fetchurl
      versionCheckHook
      ;
  };
  operatorSdkPackages = import ../packages/operator-sdk.nix {
    inherit
      stdenv
      lib
      buildGoModule
      fetchFromGitHub
      git
      sqlite
      gpgme
      pkg-config
      validatePkgConfig
      installShellFiles
      versionCheckHook
      ;
  };
  opmPackages = import ../packages/opm.nix {
    inherit
      lib
      buildGoModule
      fetchFromGitHub
      git
      gpgme
      pkg-config
      validatePkgConfig
      installShellFiles
      versionCheckHook
      ;
  };
  omcPackages = import ../packages/omc.nix {
    inherit
      lib
      buildGoModule
      fetchFromGitHub
      installShellFiles
      versionCheckHook
      ;
  };
  koffPackages = import ../packages/koff.nix {
    inherit
      lib
      buildGoModule
      fetchFromGitHub
      installShellFiles
      versionCheckHook
      ;
  };
  opcPackages = import ../packages/opc.nix {
    inherit
      lib
      buildGoModule
      fetchFromGitHub
      installShellFiles
      ;
  };
  didPackages = import ../packages/did.nix {
    inherit lib python3Packages fetchFromGitHub;
  };
  luminoPackages = import ../packages/lumino.nix {
    inherit lib python3Packages fetchFromGitHub;
    inherit (super) makeWrapper;
  };
in
# Merge all package sets together
ocPackages
// openshiftInstallPackages
// operatorSdkPackages
// opmPackages
// omcPackages
// koffPackages
// opcPackages
// didPackages
// luminoPackages
// {
  # oc-git uses a different build mechanism (from source)
  oc-git = mkGitOc "oc-git" ../repos/oc-main.json { };
}
