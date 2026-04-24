{ neovim }: { pkgs, lib, ... }:
{
  programs.neovim = {
    enable = true;

    # new default with home.stateVersion 26.05
    withRuby = false;
    withPython3 = false;

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
      blink-cmp
    ];

    extraConfig = lib.mkBefore ''
      source /home/guillaume/nixos_config/home/.vimrc
    '';

  };

}
