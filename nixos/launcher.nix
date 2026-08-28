{ config, pkgs, ... }:
let
  screencast-select =
    pkgs.writeScriptBin "screencast-select"
      ''
        #!/usr/bin/env sh
        PATH=${pkgs.lib.makeBinPath [
           (pkgs.novaHaskellPackages.ghcWithPackages(p: [p.process p.async]))
           pkgs.sway
           pkgs.slurp
           pkgs.jq
           pkgs.coreutils
           ]}
        # For some reasons, I need to provide the socket manually here
        export SWAYSOCK=$(ls /run/user/1000/sway-ipc.*.sock)
        runhaskell ~/nixos_config/SelectAnyWindow.hs
      ''
  ;
in
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
      screencast-select
    ];
  };

  xdg.portal.wlr.settings.screencast.chooser_cmd = "${screencast-select}/bin/screencast-select";


  programs.sway.extraPackages = [
    pkgs.fuzzel
  ];
}
