{ stdenv, lib, fetchurl }:

with lib;
rec {
  openshiftInstallGen =
    { version
    , aarch64-darwin-sha256
    , aarch64-linux-sha256
    , x86_64-darwin-sha256
    , x86_64-linux-sha256
    }:

    let
      # https://mirror.openshift.com/pub/openshift-v4/arm64/clients/ocp/4.9.49/openshift-client-linux.tar.gz
      getUrl = version:
        if (stdenv.isAarch64 && stdenv.isDarwin) then "https://mirror.openshift.com/pub/openshift-v4/aarch64/clients/ocp/${version}/openshift-install-mac-${version}.tar.gz"
        else if (stdenv.isAarch64 && stdenv.isLinux) then "https://mirror.openshift.com/pub/openshift-v4/aarch64/clients/ocp/${version}/openshift-install-linux-${version}.tar.gz"
        else if (stdenv.isx86_64 && stdenv.isDarwin) then "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${version}/openshift-install-mac-${version}.tar.gz"
        else if (stdenv.isx86_64 && stdenv.isLinux) then "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${version}/openshift-install-linux-${version}.tar.gz"
        else throw "unsupported platform";
      sha256 =
        if (stdenv.isAarch64 && stdenv.isDarwin) then aarch64-darwin-sha256
        else if (stdenv.isAarch64 && stdenv.isLinux) then aarch64-linux-sha256
        else if (stdenv.isx86_64 && stdenv.isDarwin) then x86_64-darwin-sha256
        else if (stdenv.isx86_64 && stdenv.isLinux) then x86_64-linux-sha256
        else throw "unsupported platform";
    in
    stdenv.mkDerivation rec {
      pname = "openshift-install";
      name = "${pname}-${version}";

      src = fetchurl {
        url = getUrl version;
        sha256 = "${sha256}";
      };

      phases = " unpackPhase installPhase fixupPhase ";

      unpackPhase = ''
        runHook preUnpack
        mkdir ${name}
        tar -C ${name} -xzf $src
      '';

      installPhase = ''
        runHook preInstall
        install -D ${name}/openshift-install $out/bin/openshift-install
        # completions
        mkdir -p $out/share/bash-completion/completions/
        $out/bin/openshift-install completion bash > $out/share/bash-completion/completions/openshift-install
        #mkdir -p $out/share/zsh/site-functions
        #$out/bin/openshift-install completion zsh > $out/share/zsh/site-functions/_openshift-install
      '';

      meta = {
        description = "Install an OpenShift cluster";
        homepage = "https://github.com/openshift/installer";
        license = lib.licenses.asl20;
      };
    };

  openshift-install = openshift-install_4_11;
  openshift-install_4_11 = makeOverridable openshiftInstallGen {
    version = "4.11.9";
    aarch64-darwin-sha256 = "08nkk77l47ki35d3g692cbkdxcfgfhd10qn6lngvxcdl65fkz848";
    aarch64-linux-sha256 = "1xkw4nrjlq3wpqhpg15m8c5ryfnj22ccmlg1dkzl9fkzdv1y6npf";
    x86_64-darwin-sha256 = "1504ja9rgvvh6aq8fics6nvmklx3m07ygr491vwsky1ics7cjdyi";
    x86_64-linux-sha256 = "08wpa9ck2bys044xymhz6zr385952mdy96fxbsnqhdcymc1fssfp";
  };
  openshift-install_4_10 = makeOverridable openshiftInstallGen {
    version = "4.10.37";
    aarch64-darwin-sha256 = "07569yvbahrbda7rpn128pg5ij9rilllc0nlpqy8wz3ssc4gx85i";
    aarch64-linux-sha256 = "1r81d7yh6pkpc0y6ap05r3vr08fk8yrpm70yhzbf7spi47cqmdca";
    x86_64-darwin-sha256 = "0ga9i68qmli6z1hv10rinw2fgxbs3prrh2rbs05yh7gsnk4j56kq";
    x86_64-linux-sha256 = "0n6y3s85v0kpnnh6d3mvg04inax3qghvfvc1yrlnnn0rsc8v2kdh";
  };
  openshift-install_4_9 = makeOverridable openshiftInstallGen {
    version = "4.9.49";
    aarch64-darwin-sha256 = "0i556l9ffirllcdjz7vwb9sg10n6qpa7hahing3n0jrdhppwynjz";
    aarch64-linux-sha256 = "0q6pj92rq0dqbafpv8mi67f3xi4mqs2n075xcfaynvccfr666pm7";
    x86_64-darwin-sha256 = "0y2r9lk9r6gqw82dk4zikkqq8bai009df4yja9n4rp2lq7qndybi";
    x86_64-linux-sha256 = "031vxspxw5j4y4yjzlgdyb91mra6mz3d6hhf9mfbfcbgsml9sa0x";
  };
}
