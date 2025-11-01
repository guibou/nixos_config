{ pkgs, ... }:
{
  programs.neovim.extraPackages = with pkgs; [
    typescript-language-server
    vue-language-server
    vscode-langservers-extracted
  ];
}
