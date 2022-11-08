{ pkgs ? import <nixpkgs> { } }:
{
  inherit (pkgs.callPackage ./oc.nix { })
    oc_4_9
    oc_4_10
    oc_4_11
    oc_4_12
    oc
    ;
  inherit (pkgs.callPackage ./openshift-install.nix { })
    openshift-install_4_9
    openshift-install_4_10
    openshift-install_4_11
    openshift-install
    ;
  # Operator SDK
  inherit (pkgs.callPackage ./operator-sdk.nix { })
    operator-sdk_1
    operator-sdk_1_25
    operator-sdk_1_24
    operator-sdk_1_23
    operator-sdk_1_22
    operator-sdk
    ;
  # OPM
  inherit (pkgs.callPackage ./opm.nix { })
    opm_1_26
    opm
    ;
}
