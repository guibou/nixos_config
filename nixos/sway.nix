{ config, pkgs, nixpkgs, lib, ... }:

{
  programs = {
    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraPackages = with pkgs; [
        swaylock
        swayidle
        wl-clipboard
        wmenu
        i3status
        # autosway
      ];
    };
  };

  # services.gnome.gnome-keyring.enable = true;

  xdg.portal = {
    enable = true;
    config = { common = { default = "wlr"; }; };
    wlr.enable = true;

    # I seriously have no idea what I'm doing
    #extraPortals = [
    #  pkgs.xdg-desktop-portal-gtk
    #  pkgs.xdg-desktop-portal-wlr
    #];

    #wlr.settings.screencast = {
    #  output_name = "eDP-1";
    #  chooser_type = "simple";
    #  chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
    #};
  };

  services.displayManager.defaultSession = "sway";

  home-manager.users.guillaume = {
    imports = [
      ({ config, lib, ... }: {
        home.sessionVariables = {
          DMENU_BLUETOOTH_LAUNCHER = "wmenu";
        };

        home.activation = {
          reloadSway = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            sway-msg restart
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
              };
              "networkmanager-dmenu/config.ini".text = ''
                [dmenu]
                dmenu_command = wmenu
              '';
            };
        };

        # Note: `Screenshots` directory MUST exists, otherwise flameshot is broken
        services.flameshot = {
          package = pkgs.flameshot.override {
            enableWlrSupport = true;
          };
        };
      })
    ];
  };
}

/*

  for dunst, I had to run:

  ```
  dbus-update-activation-environment WAYLAND_DISPLAY
  ```

  https://discourse.nixos.org/t/dunst-crashes-if-run-as-service/27671/2

*/


