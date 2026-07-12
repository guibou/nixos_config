{ pkgs, ... }:

{
  programs = {
    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraPackages = with pkgs; [
        swaylock
        swayidle
        wl-clipboard
        i3status
      ];
    };
  };

  # services.gnome.gnome-keyring.enable = true;

  xdg.portal = {
    enable = true;
    config = { common = { default = "*"; }; };
    wlr.enable = true;

    wlr.settings = {
      screencast = {
        chooser_type = "simple";
      };
    };
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-wlr
    ];
  };

  # autologin on sway
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${pkgs.sway}/bin/sway";
        user = "guillaume";
      };
      default_session = initial_session;
    };
  };

  home-manager.users.guillaume = {
    imports = [
      ({ config, lib, ... }: {
        home.activation = {
          reloadsway = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            # TODO: this does not work for some reasons
            # swaymsg reload
          '';
        };
        xdg = {
          configFile =
            let
              link = path: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos_config/home/${path}";
            in
            {
              "sway/config" = {
                source = link "swayconfig";
                onChange = "swaymsg restart";
              };
              "i3status/config" = {
                source = link "i3status.conf";
                onChange = "swaymsg restart";
              };
            };
        };

        # Note: `Screenshots` directory MUST exists, otherwise flameshot is broken
        services.flameshot = {
          package = pkgs.flameshot.override {
            enableWlrSupport = true;
          };
        };

        home.packages = [
          pkgs.slurp
          (pkgs.writeScriptBin "lock-action"
            ''
              PATH=${pkgs.lib.makeBinPath [pkgs.pulseaudio]}:$PATH

              # I turn notifications OFF so they do not risk poping over my screen
              set-notification-pause true

              # I set volume OFF so it does not continue or pop on out of suspend
              pactl set-sink-mute @DEFAULT_SINK@ 1
              swaylock -f -c 404040
            '')

        ];
      })
    ];
  };
}
