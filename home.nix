{pkgs, config, dark, neovim, nightfox-nvim, lib, ...}:
  let
    foxTheme = if dark then "nordfox" else "dawnfox";

    #trackMania = pkgs.writeScriptBin "trackMania" ''
    #  cd /home/guillaume/.wine/drive_c/Program\ Files/TmNationsForever/
    #  ${pkgs.wineWowPackages.staging}/bin/wine TmForever.exe
    #'';

    # diablo3 = pkgs.callPackage ./home/diabloIII.nix { };
  in
  {
  # I like strong control over my unfree predicates
  # nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (pkgs.lib.getName pkg) [
      "steam-original"
      "steam"
      "steam-runtime"
    ];

  home.username = "guillaume";
  home.homeDirectory = "/home/guillaume";
  home.packages = with pkgs; [
    tig
    evince
    hicolor-icon-theme
    ack
    brightnessctl
    gnome.eog
    ffmpeg
    file

    imagemagick
    ispell
    # Mans
    man-pages-posix
    stdmanpages
    man-pages

    meld
    pavucontrol
    duckstation
    # simplescreenrecorder
    # transmission-gtk

    # Poulet stuffs
    # coq

    # Great pcregrep
    pcre

    # glslang

    # network utils
    nethogs

    # Games
    # I'm not gaming these days
    # steam
    # diablo3.diablo3_nodxtn
    #trackMania
    # N64 emulation
    #(retroarch.override {
    #  cores = [ libretro.mupen64plus libretro.parallel-n64 libretro.pcsx2 ];
    #})


    # Dev utils
    binutils-unwrapped
    python3
    fd
    linuxPackages.perf
    gdb
    # xournal
    # renderdoc

    # hyperfine
    (pkgs.haskell.lib.doJailbreak nix-diff)
    (pkgs.haskell.lib.unmarkBroken (pkgs.haskell.lib.doJailbreak haskellPackages.profiteur))
    #haskellPackages.ghc-prof-flamegraph
    patchelf
    unzip

    # GHC(i) with some defaults
    (haskellPackages.ghcWithPackages (ps:
      with ps; [
        #(haskell.lib.dontCheck (pkgs.haskell.lib.unmarkBroken (ps.callHackageDirect {

        #  pkg = "PyF";
        #  ver = "0.11.1.0";
        #  sha256 = "sha256-EuSog8IpsdQrciKoDGUBHK2iH7S/9ltnkUUxzKtpPXQ=";
        #} {})))
        #ps.containers
        #ps.selda
        #ps.vector
        #ps.aeson
        #ps.optics
        #ps.generic-optics
        ps.haskell-language-server
        #ps.cabal-fmt
        #ps.streaming-bytestring
      ]))

    jq
    nixfmt-rfc-style
    ripgrep
    
    # CCLS for C++ dev pulls a lot of dependencies
    # (ccls.override{llvmPackages = llvmPackages_latest;})

    # gimp

    nil

    k9s
    pgformatter
    pgbadger

    v4l-utils
    sshuttle

    parallel
    xclip
    gnuplot
    ttyplot
    nixpkgs-fmt
    #yaml-language-server
    cabal-install
    # bitwarden-cli
    kubectl

    # ps2 emul
    # pcsx2

    # playstation portable emul
    # ppspp-sdl

    haskellPackages.eventlog2html

    #peek
    sqlite-interactive

    nix-tree

    #xournalpp
    #texlive.combined.scheme-full

    (pkgs.writeScriptBin "volume-change"
    ''
      PATH=${pkgs.lib.makeBinPath [pkgs.pulseaudio pkgs.libnotify pkgs.pcre pkgs.gnugrep pkgs.coreutils-full]}
      set -x
  
      pactl $@

      current=$(pactl get-sink-volume @DEFAULT_SINK@ | pcregrep -o1 '([0-9]+)%' | head -n1)
      icon=$(pactl get-sink-mute @DEFAULT_SINK@ | pcregrep no > /dev/null && echo "high" || echo "muted")
      echo $current
      notify-send -t 2000 -r 1234 -h int:value:$current \
                  -i ${pkgs.flat-remix-icon-theme}/share/icons/Flat-Remix-Violet-Dark/apps/scalable/audio-volume-$icon.svg \
                  "Volume [$current%]"

      pkill i3status -SIGUSR1
    '')

    (pkgs.writeScriptBin "notify-brightness-change"
    ''
      PATH=${pkgs.lib.makeBinPath [pkgs.brightnessctl pkgs.libnotify pkgs.pcre pkgs.gnugrep]}
      set -x
      current=$(brightnessctl | pcregrep -o1 '([0-9]+)%')
      echo $current
      notify-send -t 2000 -r 12345 -h int:value:$current \
                  -i ${pkgs.flat-remix-icon-theme}/share/icons/Flat-Remix-Violet-Dark/apps/scalable/brightnesssettings.svg \
                  "Brightness [$current%]"
    '')

    nix-output-monitor
    btop
    hyperfine
  ];

  # Note: `Screenshots` directory MUST exists, otherwise flameshot is broken
  services.flameshot = {
    enable = true;
    settings = {
      General = {
        disabledTrayIcon = true;
        showStartupLaunchMessage = false;
        
        checkForUpdates=false;
        copyPathAfterSave=true;
        saveAfterCopy=true;
        savePath= "/home/guillaume/Screenshots";
        showDesktopNotification=false;
        showHelp=false;
        showSidePanelButton=false;
      };
      Shortcuts = {
        TYPE_COPY="Ctrl+C";
      };
    };
  };

  # Disable: I'm not using this anymore
  #systemd.user.services.xautolock-session = {
  #  Unit = {
  #    Description = "xautolock, session locker service";
  #    After = [ "graphical-session-pre.target" ];
  #    PartOf = [ "graphical-session.target" ];
  #  };

  #  Install = { WantedBy = [ "graphical-session.target" ]; };

  #  Service = {
  #    ExecStart = pkgs.lib.concatStringsSep " " ([
  #      "${pkgs.xautolock}/bin/xautolock"
  #      "-time 1"
  #      "-locker '${pkgs.i3lock}/bin/i3lock -c 404040 -i /home/guillaume/cool_shoots/wallpaper.png'"
  #      "-detectsleep"
  #    ]);
  #  };
  #};

  services.pasystray.enable = true;

  programs.firefox.enable = true;
  programs.htop = {
    enable = true;
    settings = {
      show_program_path = 0;
      highlight_base_name=1;
      hide_userland_threads=1;
      show_cpu_frequency = 1;
      show_cpu_temperature = 1;
      column_meters_0="AllCPUs";
      column_meter_modes_0="1";
      column_meters_1="Tasks LoadAverage Uptime NetworkIO DiskIO Memory Swap";
      column_meter_modes_1="2 2 2 2 2 1 1";
    };
  };

  programs.lazygit = {
    enable = false;
    settings = {
      gui.theme = {
        lightTheme = !dark;
      };
    };
  };

  programs.mpv = { enable = true; };

  # I'm not thinking about using it
  #programs.bat = {
  #  enable = true;
  #  config = { theme = "Solarized (light)"; };
  #};

  #programs.gnome-terminal = {
  #  enable = true;
  #  showMenubar = false;

  #  profile."Default" = {
  #    # colors.palette = "Tango";
  #    default = true;
  #    showScrollbar = false;
  #    visibleName = "Default";
  #  };
  #};

  programs.autorandr = {
    enable = true;
    hooks.postswitch = { "notify-i3" = "${pkgs.i3}/bin/i3-msg restart"; };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = false;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "norm";
    };

    initExtra = let
      mkGhcUtils = versionM:
      let
        version = if versionM == null
        then
          ""
        else
          versionM;
        packageSet = if versionM == null
        then
          "haskellPackages"
        else
          "haskell.packages.ghc${version}";

      in

      ''
      ghc${version}_with () {
        nix shell --impure --expr "(with import ${pkgs.path} {};${packageSet}.ghcWithPackages (ps: with ps; [ haskell-language-server $* ]))"
      }

      ghc${version}_nohls_with () {
        nix shell --impure --expr "(with import ${pkgs.path} {};${packageSet}.ghcWithPackages (ps: with ps; [ $* ]))"
      }

      ghci${version}_with () {
        nix shell --impure --expr "(with import ${pkgs.path} {};${packageSet}.ghcWithPackages (ps: with ps; [ $* ]))" --command ghci
      }

      cabalBuild${version} () {
         nix build --impure --expr '(with import ${pkgs.path} {}; ${packageSet}.developPackage { root = ./.; })'
      }

      cabalEnv${version} () {
           nix develop --impure --expr '(with import ${pkgs.path} {}; (${packageSet}.developPackage { root = ./. ;}).overrideAttrs(old: {
              nativeBuildInputs = old.nativeBuildInputs ++ [pkgs.cabal-install pkgs.haskellPackages.haskell-language-server];
              }))'
      }
      '';
    in
      ''
      autoload -U compinit && compinit

      # skydive roulette
      [ $[ $RANDOM % 1500 ] -eq 0 ] && ${pkgs.libnotify}/bin/notify-send --urgency critical "Cutaway!";

      COMPLETION_WAITING_DOTS="true"
      ENABLE_CORRECTION="true"

      LESS="-XR"
      export BROWSER="firefox"

      icat () {
        kitty +kitten icat $*
      }

      # I don't know why, but RPROMPT seems to be set to something by
      # default
      export RPROMPT=

      if [[ -n $KITTY_INSTALLATION_DIR ]]; then
        export KITTY_SHELL_INTEGRATION="enabled"
        autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration
        kitty-integration
        unfunction kitty-integration
      fi
    ''
    + mkGhcUtils "90"
    + mkGhcUtils "92"
    + mkGhcUtils "94"
    + mkGhcUtils "96"
    + mkGhcUtils "98"
    + mkGhcUtils null;

  };
  programs.direnv = {
    nix-direnv.enable = true;
    enable = true;
    enableZshIntegration = true;
  };

  xdg.configFile."direnv/direnvrc".text = ''
    : ''${XDG_CACHE_HOME:=$HOME/.cache}
    declare -A direnv_layout_dirs
    direnv_layout_dir() {
        echo "''${direnv_layout_dirs[$PWD]:=$(
            echo -n "$XDG_CACHE_HOME"/direnv/layouts/''${PWD##*/}-
            echo -n "$PWD" | shasum | cut -d ' ' -f 1
        )}"
    }
  '';
  xdg.enable = true;

  programs.home-manager = {
    enable = true;
    path = lib.mkForce "https://github.com/rycee/home-manager/archive/master.tar.gz";
  };

  gtk.cursorTheme.package = pkgs.xorg.xcursorthemes;
  gtk.cursorTheme.name = "whiteglass";
  gtk.cursorTheme.size = 16;

  xresources.extraConfig = ''
    #include "${nightfox-nvim}/extra/${foxTheme}/${foxTheme}.Xresources"
  '';

  gtk = {
    enable = true;
    iconTheme.name = "Adwaita";
    iconTheme.package = pkgs.gnome.gnome-themes-extra;
    theme.name = "Adwaita";
    theme.package = pkgs.gnome.gnome-themes-extra;
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = dark;
    };
  };

  services.network-manager-applet.enable = true;
  # services.gnome-keyring.enable = true;

  # Disable with sway
  # services.picom = { enable = true; };

  services.dunst = {
    enable = true;

    settings = {
      global = {
        markup = "full";
        geometry = "300x50-15+49";
        word_wrap = "yes";
        browser = "${pkgs.firefox}/bin/firefox";
      };
    };
  };

  /*
  programs.chromium = {
    enable = true;
    commandLineArgs = pkgs.lib.optionals dark ["--enable-features=WebContentsForceDark"];
  };
  */

  services.cbatticon = { enable = true; };

  programs.git = {
    lfs.enable = true;
    enable = true;

    ignores =
      [ "*~" "*.o" "*.hi" "*.dyn_hi" "*.dyn_o" ".stack-work" "\\#*\\#" ];

    userEmail = "guillaum.bouchard@gmail.com";
    userName = "Guillaume Bouchard";

    delta = {
      enable = true;
      options = { "syntax-theme" = if dark then "1337" else "GitHub"; };
    };

    extraConfig = {
      core = {
        askPass = "";
        editor = "vim";
        autocrlf = false;
        commentChar = ";";
      };
      push.autoSetupRemote = true;
      rebase = { autostash = true; };
      diff = {
        colorMoved = "default";
        tool = "meld";
      };
      difftool.sort.cmd = "diff <(sort $LOCAL) <(sort $REMOTE)";
      difftool.jq.cmd = ''
          diff <(jq $JQ_ARGS $LOCAL) <(jq $JQ_ARGS $REMOTE);
          jq "$JQ_ARGS | keys" $LOCAL;
        '';

      difftool.jqzlib.cmd = ''
          diff <(${pkgs.qpdf}/bin/zlib-flate -uncompress < $LOCAL | jq "") <(${pkgs.qpdf}/bin/zlib-flate -uncompress < $REMOTE | jq "")
        '';
    };
  };

  home.sessionVariables = {
    TZ = "Indian/Reunion";
    EDITOR = "vim";
    S3NOVA =
      "s3://devops-ci-infra-prod-caching-nix?region=eu-central-1&profile=nix-daemon";
  };

  programs.ssh = {
    enable = true;

    extraConfig = ''
      Host ovh-hybrid-runner-1
      Hostname ovh-hybrid-runner-1.devops.novadiscovery.net
      User ubuntu
      IdentityFile ~/.ssh/nova-infra-prod

      Host ovh-hybrid-runner-2
      Hostname ovh-hybrid-runner-2.devops.novadiscovery.net
      User ubuntu
      IdentityFile ~/.ssh/nova-infra-prod

      Host git.novadiscovery.net
      IdentityFile ~/.ssh/id_gecko

      Host github.com
      IdentityFile ~/.ssh/id_gecko
    '';
  };

  home.file = {
    ".config/ncdu/config".text = ''
      --color off
    '';

    ".gdbinit".source = pkgs.runCommand ".gdbinit" { } ''
      echo "add-auto-load-safe-path /" > $out
    '';
  };

  programs.neovim = {
    enable = true;

    extraPackages = with pkgs; [
      jq tree-sitter nodejs yarn

      # Faster filewatch
      fswatch

      # Build some extensions
      gcc cmake
    ];
    
    package = neovim;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins; [ vim-plug ];

    extraConfig = ''
      source /home/guillaume/.config/home-manager/home/.vimrc

      set bg=${if dark then "dark" else "light"}
      :colorscheme ${foxTheme}
    '';

  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.obs-studio = {
    enable = false;
    plugins = [
      # websocket
      # (pkgs.callPackage ./obs-websocket.nix {})
    ];
  };

  dconf.settings = {
    "org/gnome/evince/default" = { continuous = true; };
    "org/gnome/desktop/interface" = { color-scheme = if dark then "prefer-dark" else "prefer-light"; };
  };

  programs.kitty = 
  {
    #inherit package;
    enable = true;
    extraConfig = ''
      include ${nightfox-nvim}/extra/${foxTheme}/kitty.conf
      font_size 12
      # font_family Bitstream Vera Sans Mono Nerd Font

      # Monaspace
      font_family      Monaspace Krypton Regular
      bold_font        Monaspace Krypton Bold
      italic_font      Monaspace Krypton Regular Italic
      bold_italic_font Monaspace Krypton Bold Italic

      enable_audio_bell false
      visual_bell_duration 0.1
    '';
  };

  /*
    aws eks update-kubeconfig --profile nova-jinko --name jk-preprod --region eu-central-1
    aws eks update-kubeconfig --profile nova-jinko --name jk-prod --region eu-central-1

    kubectl config set-context arn:aws:eks:eu-central-1:980984948228:cluster/jk-preprod --namespace jinko-preprod
    kubectl config set-context arn:aws:eks:eu-central-1:980984948228:cluster/jk-prod --namespace jinko-prod
  */
  programs.awscli = {
    enable = true;
    settings = {
      "nix-daemon" = {
         region = "eu-central-1";
       };
      
      "default" = {
        region = "eu-central-1";
      };

      "nova-jinko" = {
         region = "eu-central-1";
       };
    };
  };

  services.blueman-applet.enable = true;

  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = [ "graphical-session-pre.target" ];
    };
  };
  home.stateVersion = "20.09";

  home.activation = {
    reloadNvimColorScheme = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Force all nvim to the new colorscheme
      for path in $(${pkgs.lib.getExe pkgs.neovim-remote} --nostart --serverlist)
      do
        $DRY_RUN_CMD ${pkgs.lib.getExe pkgs.neovim-remote} --nostart --servername $path -cc 'set bg=${if dark then "dark" else "light"}'
        $DRY_RUN_CMD ${pkgs.lib.getExe pkgs.neovim-remote} --nostart --servername $path -cc 'colorscheme ${foxTheme}'
      done

      # Nice log output
      PATH=$PATH:${lib.makeBinPath [ pkgs.nvd pkgs.nix ]}
      nvd diff $oldGenPath $newGenPath
    '';

    # This was using .config and inHomeConfig, but it is broken in recent nix
    updateLinks = ''
      export ROOT="${config.home.homeDirectory}/.config/home-manager/home"
      mkdir -p .config/i3
      ln -sf "$ROOT/i3config" .config/i3/config
      ln -sf "$ROOT/i3status.conf" .i3status.conf
      i3-msg restart

      mkdir -p .config/mpv/scripts
      ln -sf "$ROOT/mpv_sub-cut.lua" .config/mpv/scripts/sub-cut.lua
    '';

  };
}
