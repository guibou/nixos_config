{ config, pkgs, ... }:
{
  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;

    xkb = {
      variant = "dvorak-alt-intl";
      layout = "us";
    };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [ dmenu i3status ];
    };
  };

  services.displayManager.defaultSession = "none+i3";

  home-manager.users.guillaume = {
    imports = [
      ({ config, lib, ... }: {
        home.activation = {
          reloadi3 = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            i3-msg restart
          '';
        };
        xdg = {
          configFile =
            let
              link = path: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos_config/home/${path}";
            in
            {
              "i3/config" = {
                source = link "i3config";
                onChange = "i3-msg restart";
              };
              "i3status/config" = {
                source = link "i3status.conf";
                onChange = "i3-msg restart";
              };
            };
        };
        programs.autorandr = {
          enable = true;
          hooks.postswitch = {
            "notify-i3" = "${pkgs.i3}/bin/i3-msg restart";
            "change-sound" = ''
               case "$AUTORANDR_CURRENT_PROFILE" in
                         default)
                              # Set to standard HP
                              # Got the name using wpctl status --name
                              wpctl set-default $(pw-cli info alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink | head -n1 | awk '{print $2}')
                           ;;
                         *)
                              # Anything else, switch to HDMI output
                              wpctl set-default $(pw-cli info  alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__HDMI1__sink | head -n1 | awk '{print $2}')
                           ;;
              esac
            '';
          };
        };
      })
    ];
  };
}
