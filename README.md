# Chapeau Rouge — nix overlay for Red Hat tools

This contains pre-compiled (or from source) package related to Red
Hat.

*This is in **no way** affiliated to Red Hat (nor support by), I am just publishing those as I am using them*.

This repository provides the following overlays:
- `all`: contains all the above
- `openshift`: openshift tooling, like `oc`, `openshift-install`,
  `operator-sdk`, …

## Quickstart
To get up and running quickly, add the following lines to your =/etc/nixos/configuration.nix=:

```nix
{config, pkgs, callPackage, ... }:
{
# ...

  environment.systemPackages = with pkgs; [
    oc
    openshift-install
  ];

  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/vdemeester/chapeau-rouge/archive/main.tar.gz;
    }))
  ];

# ...
```

**Or** if you are using nix flakes, as a flake input :

```nix
{
  inputs.chapeau-rouge.url = github:vdemeester/chapeau-rouge;
  
  # ...
  
  outputs = { self, nixpkgs, chapeau-rouge }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [
          chapeau-rouge.overlay.all
        ];
        config = { allowUnfree = true; };
    };
  in {
    # Normal outputs here, using the 'pkgs' reference above.
    # ...
  };
  
  # ...
}
```
