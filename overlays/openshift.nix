self: super:
let
  mkGitOc = namePrefix: jsonFile: { ... }@args:
    let
      repoMeta = super.lib.importJSON jsonFile;
      fetcher =
        if repoMeta.type == "github" then
          super.fetchFromGitHub
        else
          throw "Unknown repository type ${repoMeta.type}!";
    in
    builtins.foldl'
      (drv: fn: fn drv)
      super.openshift
      ([
        (
          drv: drv.overrideAttrs (
            old: {
              name = "${namePrefix}-${repoMeta.version}";
              inherit (repoMeta) version rev;
              src = fetcher (builtins.removeAttrs repoMeta [ "type" "version" ]);
              ldflags = [
                "-s"
                "-w"
                "-X github.com/openshift/oc/pkg/version.commitFromGit=${repoMeta.rev}"
                "-X github.com/openshift/oc/pkg/version.versionFromGit=v${repoMeta.version}"
              ];
            }
          )
        )
      ]);
in
{
  inherit (super.callPackage ../packages/oc.nix { })
    oc_4_9
    oc_4_10
    oc_4_11
    oc_4_12
    oc_4_13
    oc
    ;
  oc-git = mkGitOc "oc-git" ../repos/oc-master.json { };
  inherit (super.callPackage ../packages/openshift-install.nix { })
    openshift-install_4_9
    openshift-install_4_10
    openshift-install_4_11
    openshift-install_4_12
    openshift-install_4_13
    openshift-install
    # master based build
    # openshift-install-git
    ;
  # Operator SDK
  inherit (super.callPackage ../packages/operator-sdk.nix { })
    operator-sdk_1
    operator-sdk_1_32
    operator-sdk_1_31
    operator-sdk_1_30
    operator-sdk_1_29
    operator-sdk_1_28
    operator-sdk_1_27
    operator-sdk_1_26
    operator-sdk_1_25
    operator-sdk_1_24
    operator-sdk_1_23
    operator-sdk_1_22
    operator-sdk
    # master based build
    # operator-sdk-git
    ;
  # OPM
  inherit (super.callPackage ../packages/opm.nix { })
    opm_1_31
    opm_1_30
    opm_1_29
    opm_1_28
    opm_1_27
    opm_1_26
    opm
    # master based build
    # opm-git
    ;
  # omc
  inherit (super.callPackage ../packages/omc.nix { })
    omc
    omc_3_2
    omc_3_3
    omc-git
    ;
  # operator-tool(ing) = …
  # opc
  inherit (super.callPackage ../packages/opc.nix { })
    opc_1_13
    opc_1_12
    opc_1_11
    opc_1_10
    opc_1_9
    opc
    opc-git
    ;
}
