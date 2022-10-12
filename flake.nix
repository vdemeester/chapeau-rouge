{
  description = "Chapeau rouge, an overlay of Red Hat tools for Nix";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    let
      # Inidividual overlays.
      overlays = import ./overlays.nix;
    in
    flake-utils.lib.eachDefaultSystem
      (system:
        let pkgs = nixpkgs.legacyPackages.${system}; in
        {
          packages = rec {
            hello = pkgs.hello;
            default = hello;
          };

          overlay = import ./default.nix;

          # overlays = import ./overlays.nix;

          shell = ./shell.nix;
        }
      ) // { inherit overlays; };
}

#   {
#   inputs = {
#     taffybar.url = path:./taffybar;
#     flake-utils.url = github:numtide/flake-utils;
#   };
#   outputs = { self, flake-utils, taffybar, nixpkgs }:
#     let
#     overlay = import ./overlay.nix;
#     overlays = taffybar.overlays ++ [ overlay ];
#   in flake-utils.lib.eachDefaultSystem (system:
#   let pkgs = import nixpkgs { inherit system overlays; config.allowBroken = true; };
#   in
#   rec {
#     devShell = pkgs.haskellPackages.shellFor {
#       packages = p: [ p.imalison-taffybar p.taffybar ];
#       nativeBuildInputs = with pkgs.haskellPackages; [
#         cabal-install hlint ghcid ormolu implicit-hie haskell-language-server
#       ];
#     };
#     defaultPackage = pkgs.haskellPackages.imalison-taffybar;
#   }) // { inherit overlay overlays; } ;
# }
