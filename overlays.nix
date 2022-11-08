{
  openshift = self: super: {
    # TODO: opc
    inherit (super.callPackage ./packages/oc.nix { })
      oc_4_9
      oc_4_10
      oc_4_11
      oc
      ;
    inherit (super.callPackage ./packages/openshift-install.nix { })
      openshift-install_4_3
      openshift-install_4_4
      openshift-install_4_5
      openshift-install_4_6
      openshift-install_4_7
      openshift-install_4_8
      openshift-install_4_9
      openshift-install_4_10
      openshift-install_4_11
      openshift-install
      ;

    inherit (super.callPackage ./packages/odo.nix { })
      odo_1_2
      odo_2_0
      odo_2_1
      odo_2_2
      odo_2_3
      odo
      ;

    # Operator SDK
    inherit (super.callPackage ./packages/operator-sdk.nix { })
      operator-sdk_1
      operator-sdk_1_23
      operator-sdk_1_22
      operator-sdk_1_21
      operator-sdk_1_20
      operator-sdk_1_17
      operator-sdk_1_16
      operator-sdk_1_15
      operator-sdk_1_14
      operator-sdk_1_13
      operator-sdk_0_18
      operator-sdk_0_19
      operator-sdk
      ;
    # OPM
    inherit (super.callPackage ./packages/opm.nix { })
      opm_1_26
      opm
      ;

    # operator-tool = super.callPackage ./operator-tooling { };
  };
  all = self: super:
    # Overlay which aggregates overlays for tools and products in this repository
    with super.lib;

    (foldl' (flip extends) (_: super)
      (map import (import ./overlays.nix)))
      self;
}
