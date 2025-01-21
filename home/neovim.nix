{ neovim, foxTheme, dark }: { pkgs, ... }:
{
  programs.neovim = {
    enable = true;

    extraPackages = with pkgs; [
      # For treesitter
      jq
      tree-sitter
      nodejs
      yarn

      # Faster filewatch
      fswatch

      # Build some extensions
      gcc
      cmake

      # ASM
      asm-lsp
    ];

    extraLuaPackages = ps: with ps; [
      # for image support
      magick
    ];

    package = neovim;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins; [ vim-plug ];

    extraConfig = ''
      source /home/guillaume/nixos_config/home/.vimrc

      set bg=${if dark then "dark" else "light"}
      :colorscheme ${foxTheme}
    '';

  };

}
