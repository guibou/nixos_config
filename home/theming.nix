{ pkgs, nightfox-nvim, ... }:
let
  darkTheme = "nordfox";
  lightTheme = "dawnfox";
in
{
  config = {
    home.packages = [
      (pkgs.writeScriptBin "dark-theme"
        ''
          PATH=${pkgs.lib.makeBinPath [pkgs.pulseaudio]}:$PATH

          cat ${nightfox-nvim}/extra/${darkTheme}/${darkTheme}.Xresources | grep '*' | sed 's/\*\(.*\): \+\(#.*\)/set $\1 \2/' > ~/.config/theme.conf
          dconf write '/org/gnome/desktop/interface/color-scheme' "'prefer-dark'"

          # force reload all nvim
          pkill -SIGUSR1 nvim || echo "no vim was started"

          # force reload sway
          swaymsg reload
        '')
      (pkgs.writeScriptBin "light-theme"
        ''
          PATH=${pkgs.lib.makeBinPath [pkgs.pulseaudio]}:$PATH

          cat ${nightfox-nvim}/extra/${lightTheme}/${lightTheme}.Xresources | grep '*' | sed 's/\*\(.*\): \+\(#.*\)/set $\1 \2/' > ~/.config/theme.conf
          dconf write '/org/gnome/desktop/interface/color-scheme' "'prefer-light'"

          # force reload all nvim
          pkill -SIGUSR1 nvim || echo "no vim was started"

          # force reload sway
          swaymsg reload
        '')
    ];

    programs.neovim = {
      initLua = ''
        function load_theme_from_os_preferences()
              local obj = vim.system({'dconf', 'read', '/org/gnome/desktop/interface/color-scheme'}, {text = true}):wait().stdout

              if obj == "'prefer-dark'\n"
              then
                 vim.opt.bg = dark
                 vim.cmd.colorscheme('${darkTheme}')
              else
                 vim.opt.bg = "light"
                 vim.cmd.colorscheme('${lightTheme}')
              end
        end

        load_theme_from_os_preferences()
      '';
    };

    gtk = {
      iconTheme.name = "Adwaita";
      iconTheme.package = pkgs.gnome-themes-extra;

      theme = {
        name = "Adwaita";
        package = pkgs.gnome-themes-extra;
      };
      gtk4.theme = null;
    };

    programs.kitty = {
      extraConfig = ''
        font_size 12

        # Monaspace
        font_family      family='Monaspace Neon Var' features=-calt
        bold_font        family='Monaspace Xenon Var' features=-calt style=Bold
        italic_font      family='Monaspace Radon Var' features=-calt
        bold_italic_font family='Monaspace Krypton Var' features=-calt style=Bold

        # Jetbrain mono
        #font_family      family="JetBrainsMono Nerd Font"
        #bold_font        auto
        #italic_font      auto
        #bold_italic_font auto

        # Mapple mono
        #font_family      family="Maple Mono"
        #bold_font        auto
        #italic_font      auto
        #bold_italic_font auto
      '';
    };

    xdg = {
      configFile = {
        "kitty/dark-theme.auto.conf" = {
          source = "${nightfox-nvim}/extra/${darkTheme}/kitty.conf";
        };
        "kitty/no-preference-theme.auto.conf" = {
          source = "${nightfox-nvim}/extra/${darkTheme}/kitty.conf";
        };
        "kitty/light-theme.auto.conf" = {
          source = "${nightfox-nvim}/extra/${lightTheme}/kitty.conf";
        };

      };
    };
  };
}




