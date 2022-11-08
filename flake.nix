{
  description = "Chapeau rouge, an overlay of Red Hat tools for Nix";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";

  outputs = { self, nixpkgs, flake-utils, pre-commit-hooks }:
    flake-utils.lib.eachSystem [ "aarch64-linux" "aarch64-darwin" "x86_64-darwin" "x86_64-linux" ]
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
              openshift-install
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

          checks = {
            pre-commit-check = pre-commit-hooks.lib.${system}.run {
              src = ./.;
              hooks = {
                nixpkgs-fmt.enable = true;
                nix-linter.enable = true;
                statix.enable = true;
              };
            };
          };
          devShells.default = pkgs.mkShell {
            inherit (self.checks.${system}.pre-commit-check) shellHook;
            buildInputs = with pkgs; [
              pre-commit
            ];
          };
        }
      ) // {
      # Inidividual overlays.
      overlays = {
        openshift = _: prev: {
          inherit (prev.callPackage ./packages/oc.nix { })
            oc_4_9
            oc_4_10
            oc_4_11
            oc
            ;
          inherit (prev.callPackage ./packages/openshift-install.nix { })
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
          inherit (prev.callPackage ./packages/odo.nix { })
            odo_1_2
            odo_2_0
            odo_2_1
            odo_2_2
            odo_2_3
            odo
            ;
          # Operator SDK
          inherit (prev.callPackage ./packages/operator-sdk.nix { })
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
          inherit (prev.callPackage ./packages/opm.nix { })
            opm_1_26
            opm
            ;
        };
        default = _: _: { };
      };
    };
}

