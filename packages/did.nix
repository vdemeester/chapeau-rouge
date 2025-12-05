{
  lib,
  python3Packages,
  fetchFromGitHub,
}:
with lib;
rec {
  did = python3Packages.buildPythonApplication {
    pname = "did";
    version = "0.22";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "psss";
      repo = "did";
      tag = "0.22";
      sha256 = "sha256-LIuvO2RR8MizYhQnbp+FfljrRJMorITFe6/hXz5t338=";
    };
    propagatedBuildInputs = [
      python3Packages.python-dateutil
      python3Packages.requests
      python3Packages.requests-gssapi
      python3Packages.tenacity
      python3Packages.urllib3
    ];
    build-system = [ python3Packages.setuptools ];

    meta = {
      description = "What did you do last week, month, year?";
      homepage = "https://github.com/psss/did";
      license = lib.licenses.gpl2;
      platforms = lib.platforms.unix;
      mainProgram = "did";
    };
  };
}
