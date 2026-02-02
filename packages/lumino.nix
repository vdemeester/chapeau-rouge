{
  lib,
  python3Packages,
  fetchFromGitHub,
  makeWrapper,
}:

{
  lumino-mcp-server = python3Packages.buildPythonApplication (finalAttrs: {
    pname = "lumino-mcp-server";
    version = "0.9.3";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "spre-sre";
      repo = "lumino-mcp-server";
      tag = "v${finalAttrs.version}";
      hash = "sha256-MLhc5r9bKR97mxqYiHbZoaq2T/Oyr8vOUFbzof/n3Fs=";
    };

    build-system = [ python3Packages.hatchling ];

    nativeBuildInputs = [ makeWrapper ];

    dependencies = with python3Packages; [
      aiohttp
      kubernetes
      mcp
      pandas
      numpy
      scikit-learn
      prometheus-client
      pyyaml
      requests
      python-dotenv
      pydantic
      uvicorn
      starlette
      networkx
    ];

    # No pythonImportsCheck - package uses "src" as module name
    # Tests require kubernetes cluster
    doCheck = false;

    # The package doesn't define console_scripts, and main.py uses relative path loading
    # for src/server-mcp.py, so we need to copy the entire structure
    postInstall = ''
      mkdir -p $out/share/lumino-mcp-server
      install -Dm755 $src/main.py $out/share/lumino-mcp-server/main.py
      cp -r $out/${python3Packages.python.sitePackages}/src $out/share/lumino-mcp-server/
      makeWrapper ${python3Packages.python.interpreter} $out/bin/lumino-mcp-server \
        --add-flags "$out/share/lumino-mcp-server/main.py" \
        --prefix PYTHONPATH : "$PYTHONPATH:$out/${python3Packages.python.sitePackages}"
    '';

    meta = {
      description = "MCP server for intelligent observability across Kubernetes, OpenShift, and Tekton";
      homepage = "https://github.com/spre-sre/lumino-mcp-server";
      license = lib.licenses.asl20;
      platforms = lib.platforms.unix;
      mainProgram = "lumino-mcp-server";
    };
  });
}
