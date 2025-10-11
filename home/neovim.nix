{ neovim, darkTheme, lightTheme }: { pkgs, ... }:
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

      # LSP
      asm-lsp
      typescript-language-server
      vue-language-server
      vscode-langservers-extracted

      # images support (latext)
      ghostscript
      # Let's disable latex support, I don't really use it most of the time and
      # it brings so much dependencies.
      # texliveFull

      # fs notifications
      inotify-tools

      pyright
    ];

    extraLuaPackages = ps: with ps; [
      # for image/math support
      magick
    ];

    package = neovim;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins; [
      nvim-treesitter
      blink-cmp
    ] ++
    (with nvim-treesitter-parsers; [
      latex
      haskell
      json
      vim
      python
      lua
      markdown
    ]);

    extraConfig = ''
            source /home/guillaume/nixos_config/home/.vimrc

            lua << EOF
      function load_theme_from_os_preferences()
            local obj = vim.system({'dconf', 'read', '/org/gnome/desktop/interface/color-scheme'}, {text = true}):wait().stdout

            if obj == "'prefer-dark'\n"
            then
               vim.cmd([[
                 set bg=dark
                 colorscheme ${darkTheme}
                 set bg=dark
               ]])
            else
               vim.cmd([[
                 set bg=light
                 colorscheme ${lightTheme}
                 set bg=light
                 ]])
            end
      end
      load_theme_from_os_preferences()
      EOF


    '';

  };

}
