{neovim, foxTheme, dark}: {pkgs, ...}:
{
  programs.neovim = {
    enable = true;

    extraPackages = with pkgs; [
      jq tree-sitter nodejs yarn

      # Faster filewatch
      fswatch

      # Build some extensions
      gcc cmake
    ];
    
    package = neovim;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins; [ vim-plug ];

    extraConfig = ''
      source /home/guillaume/.config/home-manager/home/.vimrc

      set bg=${if dark then "dark" else "light"}
      :colorscheme ${foxTheme}
    '';

  };

}
