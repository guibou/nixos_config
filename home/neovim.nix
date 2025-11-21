{ neovim }: { pkgs, lib, ... }:
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

      # images support (latext)
      ghostscript

      # fs notifications
      inotify-tools

      pyright

      # For math display
      python3Packages.pylatexenc
      imagemagick
      librsvg
    ];

    extraLuaPackages = ps: with ps; [
      # for image/math support
      magick
    ];

    package = neovim.overrideAttrs (old: {
      patches = old.patches ++ [ ../home/neovim_patch_36257.diff ];
    });

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins; [
      nvim-treesitter
      blink-cmp

      nvim-treesitter-parsers.latex
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

    extraConfig = lib.mkBefore ''
      source /home/guillaume/nixos_config/home/.vimrc
    '';

  };

}
