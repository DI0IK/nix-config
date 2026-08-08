{ pkgs, ... }:

{
  programs.vscode.enable = true;

  home.persistence."/persist".directories = [
    ".config/VSCodium"
    ".vscode-oss"
  ];
}
