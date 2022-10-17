{
  description = "Chapeau rouge, an overlay of Red Hat tools for Nix";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    {
      # Inidividual overlays.
      overlays = import ./overlays.nix;
    } // flake-utils.lib.eachSystem [ "aarch64-linux" "aarch64-darwin" "x86_64-darwin" "x86_64-linux" ]
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          packages = rec {
            inherit (pkgs.callPackage ./packages/oc.nix { })
              oc_4_9
              oc_4_10
              oc_4_11
              oc
              ;
            inherit (pkgs.callPackage ./packages/openshift-install.nix { })
              openshift-install_4_9
              openshift-install_4_10
              openshift-install_4_11
              oc
              ;
            # Operator SDK
            inherit (pkgs.callPackage ./packages/operator-sdk.nix { })
              operator-sdk_1
              operator-sdk_1_24
              operator-sdk_1_23
              operator-sdk_1_22
              operator-sdk
              ;
            # OPM
            inherit (pkgs.callPackage ./packages/opm.nix { })
              opm_1_26
              opm
              ;
            default = oc;
          };

          shell = ./shell.nix;
        }
      );
}

