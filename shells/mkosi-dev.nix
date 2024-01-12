{ pkgs }:

let
  testDeps = with pkgs; [
    (python3.withPackages
      (ps: with ps; [
        setuptools
        pytest
        mypy
        isort
        pyflakes
        argcomplete
      ]))
    nodePackages_latest.pyright
  ];

  testScript = pkgs.writeShellApplication {
    name = "mkosi-tests";
    runtimeInputs = testDeps;
    text = ''
      set -euxo pipefail
      python3 -m isort mkosi/
      python3 -m pyflakes mkosi/ tests/
      sh -c '! git grep -P "\\t" "*.py"'
      python3 -m mypy mkosi/ tests/
      pyright mkosi/ tests/
      python3 -m pytest -sv tests | cat # no pager
      python3 -m mkosi -h | cat # no pager
    '';
  };
in

pkgs.mkShell {
  buildInputs = testDeps ++ [ testScript ];
}
