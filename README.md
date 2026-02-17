# Chapeau Rouge — nix overlay for Red Hat tools

This contains pre-compiled (or from source) package related to Red
Hat.

*This is in **no way** affiliated to Red Hat (nor support by), I am just publishing those as I am using them*.

This repository provides the following overlays:
- `all`: contains all the above
- `openshift`: openshift tooling, like `oc`, `openshift-install`,
  `operator-sdk`, …

## Packages

<!-- BEGIN PACKAGE TABLE -->

| Package | Version | Platforms |
|---|---|---|
| [`did`](https://github.com/psss/did) | `0.22` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| [`koff`](https://github.com/gmeghnag/koff) | `1.0.1` | `aarch64-linux`, `x86_64-linux` |
| [`koff-git`](https://github.com/gmeghnag/koff) | `20250105.0` | `aarch64-linux`, `x86_64-linux` |
| [`lumino-mcp-server`](https://github.com/spre-sre/lumino-mcp-server) | `0.9.3` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| [`oc`](https://github.com/openshift/oc) | `4.21.2` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| [`oc-git`](http://www.openshift.org) | `20260213.0` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| [`oc_4_14`](https://github.com/openshift/oc) | `4.14.61` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| [`oc_4_15`](https://github.com/openshift/oc) | `4.15.61` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| [`oc_4_16`](https://github.com/openshift/oc) | `4.16.57` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| [`oc_4_17`](https://github.com/openshift/oc) | `4.17.49` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| [`oc_4_18`](https://github.com/openshift/oc) | `4.18.33` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| [`oc_4_19`](https://github.com/openshift/oc) | `4.19.24` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| [`oc_4_20`](https://github.com/openshift/oc) | `4.20.14` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| [`oc_4_21`](https://github.com/openshift/oc) | `4.21.2` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| [`omc`](https://github.com/gmeghnag/omc) | `3.13.0` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| [`omc-git`](https://github.com/gmeghnag/omc) | `20260216.0` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| [`opc`](https://github.com/openshift-pipelines/opc) | `1.19.0` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| [`opc-git`](https://github.com/openshift-pipelines/opc) | `20251222.0` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| [`openshift-install`](https://github.com/openshift/installer) | `4.21.2` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| [`openshift-install_4_14`](https://github.com/openshift/installer) | `4.14.61` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| [`openshift-install_4_15`](https://github.com/openshift/installer) | `4.15.61` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| [`openshift-install_4_16`](https://github.com/openshift/installer) | `4.16.57` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| [`openshift-install_4_17`](https://github.com/openshift/installer) | `4.17.49` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| [`openshift-install_4_18`](https://github.com/openshift/installer) | `4.18.33` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| [`openshift-install_4_19`](https://github.com/openshift/installer) | `4.19.24` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| [`openshift-install_4_20`](https://github.com/openshift/installer) | `4.20.14` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| [`openshift-install_4_21`](https://github.com/openshift/installer) | `4.21.2` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| [`operator-sdk`](https://github.com/operator-framework/operator-sdk) | `1.42.0` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| [`opm`](https://github.com/operator-framework/operator-registry) | `1.63.0` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |

<!-- END PACKAGE TABLE -->

## Quickstart
To get up and running quickly, add the following lines to your `/etc/nixos/configuration.nix`:

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

## Questions

- **Why is it call "Chapeau Rouge" ?**
	This is a reference to the [Red Hat](https://en.wikipedia.org/wiki/Red_Hat) company name, which is a french expression for "Red Hat".
