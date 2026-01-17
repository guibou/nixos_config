{ config, lib, pkgs, nightfox-nvim, ... }:
let
  darkTheme = "nordfox";
  lightTheme = "dawnfox";

  currentTheme = if config.dark-theme then darkTheme else lightTheme;
  dark = config.dark-theme;
in
{
  options = {
    dark-theme = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = {
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

    xresources.extraConfig = ''
      #include "${nightfox-nvim}/extra/${currentTheme}/${currentTheme}.Xresources"
    '';

    gtk = {
      iconTheme.name = "Adwaita";
      iconTheme.package = pkgs.gnome-themes-extra;

      theme = {
        name = if dark then "Adwaita-dark" else "Adwaita";
        package = pkgs.gnome-themes-extra;
      };
      gtk4.theme = null;

      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = dark;
      };
      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = dark;
      };
    };

    programs.delta = {
      options = { "syntax-theme" = if dark then "1337" else "GitHub"; };
    };


    programs.kitty = {
      extraConfig = ''
        include ${nightfox-nvim}/extra/${currentTheme}/kitty.conf
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
        /*
        # TODO: kitty auto theme switch does not work as expected, so for now I
        # just force the theme files
        "kitty/dark-theme.auto.conf" = {
          source = "${nightfox-nvim}/extra/${currentTheme}/kitty.conf";
        };
        "kitty/no-preference-theme.auto.conf" = {
          source = "${nightfox-nvim}/extra/${currentTheme}/kitty.conf";
        };

        "kitty/light-theme.auto.conf" = {
          source = "${nightfox-nvim}/extra/${currentTheme}/kitty.conf";
        };
        */

      };
    };

    dconf.settings = {
      "org/gnome/desktop/interface" = { color-scheme = if dark then "prefer-dark" else "prefer-light"; };
    };
  };
}
