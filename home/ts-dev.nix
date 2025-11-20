{ pkgs, ... }:
{
  programs.neovim.extraPackages = with pkgs; [
    typescript-language-server
    # vtsls
    vue-language-server
    vscode-langservers-extracted
  ];
}
