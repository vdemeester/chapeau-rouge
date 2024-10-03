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
    oc_4_13
    oc_4_14
    oc_4_15
    oc_4_16
    oc_4_17
    oc
    ;
  oc-git = mkGitOc "oc-git" ../repos/oc-master.json { };
  inherit (super.callPackage ../packages/openshift-install.nix { })
    openshift-install_4_13
    openshift-install_4_14
    openshift-install_4_15
    openshift-install_4_16
    openshift-install_4_17
    openshift-install
    # master based build
    # openshift-install-git
    ;
  # Operator SDK
  inherit (super.callPackage ../packages/operator-sdk.nix { })
    operator-sdk_1
    operator-sdk_1_34
    operator-sdk_1_33
    operator-sdk_1_32
    operator-sdk_1_31
    operator-sdk_1_30
    operator-sdk
    # master based build
    # operator-sdk-git
    ;
  # OPM
  inherit (super.callPackage ../packages/opm.nix { })
    opm_1_47
    opm_1_46
    opm_1_45
    opm_1_44
    opm_1_43
    opm_1_42
    opm_1_41
    opm_1_40
    opm_1_39
    opm
    # master based build
    # opm-git
    ;
  # omc
  inherit (super.callPackage ../packages/omc.nix { })
    omc
    omc_3_2
    omc_3_3
    omc_3_4
    omc_3_6
    omc_3_7
    omc-git
    ;
  # koff
  inherit (super.callPackage ../packages/koff.nix { })
    koff
    koff_0_11
    koff_0_10
    koff-git
    ;
  # operator-tool(ing) = …
  # opc
  inherit (super.callPackage ../packages/opc.nix { })
    opc_1_15
    opc_1_14
    opc_1_13
    opc_1_12
    opc
    opc-git
    ;
}
