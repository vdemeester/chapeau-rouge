{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

{
  did = python3Packages.buildPythonApplication (finalAttrs: {
    pname = "did";
    version = "0.23";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "psss";
      repo = "did";
      tag = finalAttrs.version;
      hash = "sha256-KdE26r+C7hH3qSG4VH+gy9xmDPEiEnGU2Ag7Oda7kjw=";
    };

    build-system = [ python3Packages.setuptools ];

    dependencies = [
      python3Packages.python-dateutil
      python3Packages.requests
      python3Packages.requests-gssapi
      python3Packages.tenacity
      python3Packages.urllib3
    ];

    meta = {
      description = "What did you do last week, month, year?";
      homepage = "https://github.com/psss/did";
      license = lib.licenses.gpl2;
      platforms = lib.platforms.unix;
      mainProgram = "did";
    };
  });
}
