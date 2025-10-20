# Chapeau Rouge — nix overlay for Red Hat tools

This contains pre-compiled (or from source) package related to Red
Hat.

*This is in **no way** affiliated to Red Hat (nor support by), I am just publishing those as I am using them*.

This repository provides the following overlays:
- `all`: contains all the above
- `openshift`: openshift tooling, like `oc`, `openshift-install`,
  `operator-sdk`, …

<!-- PACKAGES_START -->
## Packages

| Package | Version | Platforms |
|---|---|---|
| `did` | `0.22` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| `koff` | `1.0.1` | `aarch64-linux`, `x86_64-linux` |
| `koff-git` | `20250105.0` | `aarch64-linux`, `x86_64-linux` |
| `koff_1_0` | `1.0.1` | `aarch64-linux`, `x86_64-linux` |
| `oc` | `4.19.17` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| `oc-git` | `20251020.0` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| `oc_4_14` | `4.14.57` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| `oc_4_15` | `4.15.58` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| `oc_4_16` | `4.16.50` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| `oc_4_17` | `4.17.42` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| `oc_4_18` | `4.18.26` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| `oc_4_19` | `4.19.17` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| `omc` | `3.12.0` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| `omc-git` | `20251003.0` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| `omc_3_10` | `3.10.0` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| `omc_3_11` | `3.11.2` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| `omc_3_12` | `3.12.0` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| `opc` | `1.19.0` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| `opc-git` | `20251016.0` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| `opc_1_18` | `1.18.0` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| `opc_1_19` | `1.19.0` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| `openshift-install` | `4.19.17` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| `openshift-install_4_14` | `4.14.57` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| `openshift-install_4_15` | `4.15.58` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| `openshift-install_4_16` | `4.16.50` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| `openshift-install_4_17` | `4.17.42` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| `openshift-install_4_18` | `4.18.26` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| `openshift-install_4_19` | `4.19.17` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| `operator-sdk` | `1.41.1` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| `operator-sdk_1` | `1.41.1` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| `operator-sdk_1_40` | `1.40.0` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| `operator-sdk_1_41` | `1.41.1` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| `opm` | `1.60.0` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| `opm_1_59` | `1.59.0` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |
| `opm_1_60` | `1.60.0` | `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux` |

<!-- PACKAGES_END -->

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
