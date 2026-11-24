{
  lib,
  buildPythonApplication,
  buildPythonPackage,
  fetchFromGitHub,
  fetchPypi,
  hatchling,
  hatch-vcs,
  click,
  filelock,
  google-auth,
  google-auth-oauthlib,
  html2text,
  jupyter-client,
  jupyter-core,
  keyring,
  nbformat,
  packaging,
  prompt-toolkit,
  pyarrow,
  pydantic,
  pygments,
  requests,
  rich,
  traitlets,
  typer,
  typing-extensions,
  websocket-client,
}:

let
  jupyter-mimetypes = buildPythonPackage rec {
    pname = "jupyter-mimetypes";
    version = "0.2.0";
    format = "wheel";

    src = fetchPypi {
      pname = "jupyter_mimetypes";
      inherit version format;
      dist = "py3";
      python = "py3";
      hash = "sha256-5tzZiSWOP8lENltlbZFzGRUX4OOTvYeOl85QDls4hSc=";
    };

    dependencies = [
      pyarrow
      typing-extensions
    ];

    pythonImportsCheck = [ "jupyter_mimetypes" ];

    meta = {
      description = "MIME types for Jupyter";
      homepage = "https://github.com/datalayer/jupyter-mimetypes";
      license = lib.licenses.bsd3;
    };
  };

  jupyter-kernel-client = buildPythonPackage rec {
    pname = "jupyter-kernel-client";
    version = "0.8.0";
    pyproject = true;

    # google-colab-cli uses Google's fork of jupyter-kernel-client
    src = fetchFromGitHub {
      owner = "googlecolab";
      repo = "jupyter-kernel-client";
      rev = "f18e982c3265df5e923aa9def101ab3fd737e139";
      hash = "sha256-A2c78qPdY5HIdAmcr1PP3UbtMty84zrNnvZItu7Rk+E=";
    };

    build-system = [ hatchling ];

    dependencies = [
      jupyter-core
      jupyter-client
      jupyter-mimetypes
      requests
      traitlets
      typing-extensions
      websocket-client
    ];

    pythonImportsCheck = [ "jupyter_kernel_client" ];

    meta = {
      description = "Jupyter Kernel Client through HTTP and WebSocket (Google Colab fork)";
      homepage = "https://github.com/googlecolab/jupyter-kernel-client";
      license = lib.licenses.bsd3;
    };
  };
in
buildPythonApplication rec {
  pname = "google-colab-cli";
  version = "0.8.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "googlecolab";
    repo = "google-colab-cli";
    tag = "v${version}";
    hash = "sha256-/sAyxmZNERy56LUlghvN7O/U4oSfQMk1tE70tMpsA+s=";
  };

  build-system = [
    hatchling
    hatch-vcs
  ];

  env.SETUPTOOLS_SCM_PRETEND_VERSION = version;

  # pyproject.toml pins ==0.9.0 while uv.lock resolves to 0.8.0 from Google's fork
  pythonRelaxDeps = [ "jupyter-kernel-client" ];

  dependencies = [
    click
    filelock
    google-auth
    google-auth-oauthlib
    html2text
    jupyter-kernel-client
    keyring
    nbformat
    packaging
    prompt-toolkit
    pydantic
    pygments
    requests
    rich
    typer
    typing-extensions
    websocket-client
  ];

  pythonImportsCheck = [ "colab_cli" ];

  meta = {
    description = "CLI for interacting with Google Colab";
    homepage = "https://github.com/googlecolab/google-colab-cli";
    license = lib.licenses.asl20;
    mainProgram = "colab";
  };
}
