self: super: {
  inherit (super.callPackage ../packages/oc.nix { })
    oc_4_9
    oc_4_10
    oc_4_11
    oc
    ;
  inherit (super.callPackage ../packages/openshift-install.nix { })
    openshift-install_4_9
    openshift-install_4_10
    openshift-install_4_11
    openshift-install
    ;
  # Operator SDK
  inherit (super.callPackage ../packages/operator-sdk.nix { })
    operator-sdk_1
    operator-sdk_1_25
    operator-sdk_1_24
    operator-sdk_1_23
    operator-sdk_1_22
    operator-sdk
    ;
  # OPM
  inherit (super.callPackage ../packages/opm.nix { })
    opm_1_26
    opm
    ;
}
