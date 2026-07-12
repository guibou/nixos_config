{ config, pkgs, ... }:
{
  home-manager.users.guillaume = {
    home.packages = [
    (pkgs.writeScriptBin "bz-menu"
      ''
        #!/usr/bin/env sh
        PATH=${pkgs.lib.makeBinPath [pkgs.bzmenu]}:$PATH
        bzmenu --launcher fuzzel $*
      ''
    )
    (pkgs.writeScriptBin "wifi-menu"
      ''
        #!/usr/bin/env sh
        PATH=${pkgs.lib.makeBinPath [pkgs.iwmenu]}:$PATH
        iwmenu --launcher fuzzel $*
      ''
    )
    (pkgs.writeScriptBin "sound-menu"
      ''
        #!/usr/bin/env sh
        PATH=${pkgs.lib.makeBinPath [pkgs.pwmenu]}:$PATH
        pwmenu --launcher fuzzel $*
      ''
    )
    ];
  };

  xdg.portal.wlr.settings.screencast.chooser_cmd = "${pkgs.fuzzel}/bin/fuzzel --dmenu";
  programs.sway.extraPackages = [
    pkgs.fuzzel
  ];
}
