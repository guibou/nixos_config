{ pkgs, config, dark, neovim, nightfox-nvim, lib, nova, ... }:
let
  darkTheme = "nordfox";
  lightTheme = "dawnfox";

  currentTheme = if dark then darkTheme else lightTheme;

  #trackMania = pkgs.writeScriptBin "trackMania" ''
  #  cd /home/guillaume/.wine/drive_c/Program\ Files/TmNationsForever/
  #  ${pkgs.wineWowPackages.staging}/bin/wine TmForever.exe
  #'';

  # diablo3 = pkgs.callPackage ./home/diabloIII.nix { };
in
{
  imports = [
    (import ./home/neovim.nix { inherit neovim darkTheme lightTheme; })
    ./home/firefox.nix
    ./home/timezone-run.nix
    # ./home/ts-dev.nix
    # ./home/teaching.nix
  ];

  home.username = "guillaume";
  home.homeDirectory = "/home/guillaume";
  home.packages = with pkgs; [
    evince
    hicolor-icon-theme
    ack
    eog
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
    perf
    gdb

    # hyperfine
    (pkgs.haskell.lib.doJailbreak nix-diff)
    (pkgs.haskell.lib.unmarkBroken (pkgs.haskell.lib.doJailbreak haskellPackages.profiteur))
    patchelf
    unzip

    # GHC(i) with some defaults
    (haskellPackages.ghcWithPackages (ps:
      [
        ps.haskell-language-server
      ]))

    jq
    nixfmt-rfc-style
    ripgrep

    nil

    k9s

    v4l-utils

    parallel
    xclip
    gnuplot
    ttyplot
    nixpkgs-fmt
    cabal-install
    kubectl

    # ps2 emul
    # pcsx2

    # playstation portable emul
    # ppspp-sdl

    haskellPackages.eventlog2html

    sqlite-interactive

    nix-tree
    ncdu

    # Navigate json interactively
    # fx

    # Because that's sometime useful, in order to restart i3status
    killall

    # For network manager, replaces the appled
    networkmanager_dmenu
    bluez
    dmenu-bluetooth

    # for mouse emulation
    xdotool

    # For title in the i3bar
    xtitle

    (pkgs.writeScriptBin "diff-image"
      ''
        ${pkgs.imagemagick}/bin/compare $1 $2 png:- | montage -geometry +4+4 $1 - $2 png:- | kitty icat --stdin
      ''
    )


    (pkgs.writeScriptBin "volume-change"
      ''
        PATH=${pkgs.lib.makeBinPath [pkgs.pulseaudio pkgs.dunst pkgs.pcre pkgs.gnugrep pkgs.coreutils-full pkgs.gnused]}
        pactl $@

        # Get the volume percentage
        volume=$(pactl get-sink-volume @DEFAULT_SINK@ | pcregrep -o1 '([0-9]+)%' | head -n1)
        
        # Get the mute status
        mute_status=$(pactl get-sink-mute @DEFAULT_SINK@ | pcregrep no)
        
        # Determine the volume level and store it in the icon variable
        if [ -z "$mute_status" ]; then
            icon="muted"
        elif [ "$volume" -le 30 ]; then
            icon="low"
        elif [ "$volume" -le 60 ]; then
            icon="medium"
        else
            icon="high"
        fi

        dunstify -t 2000 -r 1234 -h int:value:$volume -a changeVolume \
                    -i ${pkgs.adwaita-icon-theme}/share/icons/Adwaita/symbolic/status/audio-volume-$icon-symbolic.svg \
                    "Volume" \
                    "$(pactl get-default-sink | cut -d. -f4 | sed 's/__sink//' | sed 's/__/ /')"
      '')

    (pkgs.writeScriptBin "jsonzlib-compress"
      ''
      #!/usr/bin/env sh
      PATH=${pkgs.lib.makeBinPath [pkgs.pigz pkgs.coreutils-full pkgs.jq]}
      cat - | jq -cj | pigz -z -
      ''
    )

    (pkgs.writeScriptBin "jsonzlib-decompress"
      ''
      #!/usr/bin/env sh
      PATH=${pkgs.lib.makeBinPath [pkgs.pigz pkgs.coreutils-full pkgs.jq]}
      cat - | pigz -d | jq '.'
      ''
    )

    (pkgs.writeScriptBin "jsonzlib-diff"
      ''
      #!/usr/bin/env sh
      PATH=${pkgs.lib.makeBinPath [pkgs.pigz pkgs.coreutils-full pkgs.jq pkgs.difftastic]}
      difft <(cat $1 | pigz -d | jq '.') <(cat $2 | pigz -d | jq '.')
      ''
    )

    (pkgs.writeScriptBin "zlib-diff"
      ''
      #!/usr/bin/env sh
      PATH=${pkgs.lib.makeBinPath [pkgs.pigz pkgs.coreutils-full pkgs.difftastic]}
      difft <(cat $1 | pigz -d) <(cat $2 | pigz -d)
      ''
    )

    (pkgs.writeScriptBin "set-notification-pause"
      ''
        PATH=${pkgs.lib.makeBinPath [pkgs.dunst pkgs.killall]}
        dunstctl set-paused $1

        # Refresh i3 status
        killall -USR1 i3status
      '')

    # What to do when I want to lock screen
    (pkgs.writeScriptBin "lock-action"
      ''
        PATH=${pkgs.lib.makeBinPath [pkgs.pulseaudio]}:$PATH
        i3lock-color --pass-volume-keys -c 404040

        # I turn notifications OFF so they do not risk poping over my screen
        set-notification-pause true

        # I set volume OFF so it does not continue or pop on out of suspend
        pactl set-sink-mute @DEFAULT_SINK@ 1
      '')


    (pkgs.writeScriptBin "notify-brightness-change"
      ''
        PATH=${pkgs.lib.makeBinPath [pkgs.brightnessctl pkgs.dunst pkgs.pcre pkgs.gnugrep]}
        current=$(brightnessctl s $1 | pcregrep -o1 '([0-9]+)%')
        dunstify -t 2000 -r 12345 -h int:value:$current -a changeBrightness \
                    -i ${pkgs.adwaita-icon-theme}/share/icons/Adwaita/symbolic/status/display-brightness-symbolic.svg \
                    "Brightness"
      '')

    nix-output-monitor
    btop
    hyperfine

    difftastic
    jjui
  ];

  # Note: `Screenshots` directory MUST exists, otherwise flameshot is broken
  services.flameshot = {
    enable = true;
    settings = {
      General = {
        disabledTrayIcon = true;
        showStartupLaunchMessage = false;

        copyPathAfterSave = true;
        saveAfterCopy = true;
        savePath = "/home/guillaume/Screenshots";
        showDesktopNotification = false;
        showHelp = false;
        showSidePanelButton = false;
      };
      Shortcuts = {
        TYPE_COPY = "Ctrl+C";
      };
    };
  };

  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.htop = {
    enable = true;
    settings = {
      show_program_path = 0;
      highlight_base_name = 1;
      hide_userland_threads = 1;
      show_cpu_frequency = 1;
      show_cpu_temperature = 1;
      column_meters_0 = "AllCPUs";
      column_meter_modes_0 = "1";
      column_meters_1 = "Tasks LoadAverage Uptime NetworkIO DiskIO Memory Swap";
      column_meter_modes_1 = "2 2 2 2 2 1 1";
    };
  };

  programs.mpv = { enable = true; };

  programs.autorandr = {
    enable = true;
    hooks.postswitch = {
      "notify-i3" = "${pkgs.i3}/bin/i3-msg restart";
      "change-sound" = ''
         case "$AUTORANDR_CURRENT_PROFILE" in
                   default)
                        # Set to standard HP
                        # Got the name using wpctl status --name
                        wpctl set-default $(pw-cli info alsa_output.pci-0000_00_1f.3-platform-sof_sdw.HiFi__Speaker__sink | head -n1 | awk '{print $2}')
                     ;;
                   *)
                        # Anything else, switch to HDMI output
                        wpctl set-default $(pw-cli info  alsa_output.pci-0000_00_1f.3-platform-sof_sdw.HiFi__HDMI1__sink | head -n1 | awk '{print $2}')
                     ;;
        esac
      '';
    };
  };

  home.shell = {
    enableBashIntegration = true;
    enableNushellIntegration = true;
    enableZshIntegration = true;
  };

  programs.nushell = {
    enable = true;
    extraConfig = ''
      '';
    };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    enableVteIntegration = true;
    autosuggestion.enable = true;

    plugins = [
      /*{
        name = "zsh-autocomplete"; # completes history, commands, etc.
        src = pkgs.fetchFromGitHub {
          owner = "marlonrichert";
          repo = "zsh-autocomplete";
          rev = "762afacbf227ecd173e899d10a28a478b4c84a3f";
          sha256 = "1357hygrjwj5vd4cjdvxzrx967f1d2dbqm2rskbz5z1q6jri1hm3";
        }; # e.g., nix-prefetch-url --unpack https://github.com/marlonrichert/zsh-autocomplete/archive/762afacbf227ecd173e899d10a28a478b4c84a3f.tar.gz
      }*/
    ];

    oh-my-zsh = {
      enable = true;
      plugins = [ "" ];
      theme = "norm";
    };

    initContent =
      ''
        # skydive roulette
        [ $[ $RANDOM % 1500 ] -eq 0 ] && ${pkgs.libnotify}/bin/notify-send --urgency critical "Cutaway!";

        LESS="-XRj.5"
        export BROWSER="firefox"

        icat () {
          kitty +kitten icat $*
        }

        # I don't know why, but RPROMPT seems to be set to something by
        # default
        export RPROMPT=

        # I don't know why but zsh does not contain the completion for nix
        # It seems that I have no .nix-profile in my home
        fpath=(${pkgs.nix}/share/zsh/site-functions/ "''${fpath[@]}")
        autoload -U compinit && compinit

        ghc_with () {
          version=$1;shift
          nix shell --impure --expr "(with import ${pkgs.path} {};haskell.packages.ghc$version.ghcWithPackages (ps: with ps; [ haskell-language-server $* ]))"
        }

        ghc_nohls_with () {
          version=$1;shift
          nix shell --impure --expr "(with import ${pkgs.path} {};haskell.packages.ghc$version.ghcWithPackages (ps: with ps; [ $* ]))"
        }

        ghci_with () {
          version=$1;shift
          nix shell --impure --expr "(with import ${pkgs.path} {};haskell.packages.ghc$version.ghcWithPackages (ps: with ps; [ $* ]))" --command ghci
        }

        cabalBuild () {
          version=$1;shift
          nix build --impure --expr '(with import ${pkgs.path} {}; haskell.packages.ghc$version.developPackage { root = ./.; })'
        }

        cabalEnv () {
          version=$1;shift
          nix develop --impure --expr '(with import ${pkgs.path} {}; (haskell.packages.ghc$version.developPackage { root = ./.; }).overrideAttrs(old: {
                    nativeBuildInputs = old.nativeBuildInputs ++ [pkgs.cabal-install pkgs.haskellPackages.haskell-language-server];
          }))'
        }
      '';

  };
  programs.direnv = {
    nix-direnv.enable = true;
    enable = true;
    enableZshIntegration = true;
  };

  xdg = {
    enable = true;

    configFile =
      let
        link = path: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos_config/home/${path}";
      in
      {
        # Enable direnv
        "direnv/direnvrc".text = ''
          : ''${XDG_CACHE_HOME:=$HOME/.cache}
                    declare -A direnv_layout_dirs
                    direnv_layout_dir() {
                        echo "''${direnv_layout_dirs[$PWD]:=$(
                            echo -n "$XDG_CACHE_HOME"/direnv/layouts/''${PWD##*/}-
                            echo -n "$PWD" | shasum | cut -d ' ' -f 1
                        )}"
                    }
        '';
        "i3/config" = {
          source = link "i3config";
          onChange = "i3-msg restart";
        };
        "i3status/config" = {
          source = link "i3status.conf";
          onChange = "i3-msg restart";
        };
        "jjui/config.toml" = {
          source = link "jjui.toml";
        };

        "dunst/dunstrc.d/conf.conf" = {
          source = link "dunstrc";
        };

        "mpv/scripts/sub-cut.lua".source = link "mpv_sub-cut.lua";


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

  gtk.cursorTheme.package = pkgs.xorg.xcursorthemes;
  gtk.cursorTheme.name = "whiteglass";
  gtk.cursorTheme.size = 16;

  xresources.extraConfig = ''
    #include "${nightfox-nvim}/extra/${currentTheme}/${currentTheme}.Xresources"
  '';

  gtk = {
    enable = true;
    iconTheme.name = "Adwaita";
    iconTheme.package = pkgs.gnome-themes-extra;
    theme = {
      name = if dark then "Adwaita-dark" else "Adwaita";
      package = pkgs.gnome-themes-extra;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = dark;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = dark;
    };
  };

  # services.network-manager-applet.enable = true;
  # services.gnome-keyring.enable = true;

  services.picom = { enable = true; };

  services.dunst = {
    enable = true;
  };

  # alert for battery events
  services.poweralertd.enable = true;

  programs.delta = {
    enable = true;
    options = { "syntax-theme" = if dark then "1337" else "GitHub"; };
  };

  programs.git = {
    lfs.enable = true;
    enable = true;

    ignores =
      [ "*~" "*.o" "*.hi" "*.dyn_hi" "*.dyn_o" ".stack-work" "\\#*\\#" ];

    settings = {
      user.email = "guillaum.bouchard@gmail.com";
      user.name = "Guillaume Bouchard";

      init.defaultBranch = "main";
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
      difftool.imgdiff.cmd = ''
        ${pkgs.imagemagick}/bin/compare $LOCAL $REMOTE png:- | montage -geometry +4+4 $LOCAL - $REMOTE png:- > /tmp/cheval.png; eog /tmp/cheval.png
      '';

      difftool.difft.cmd = "difft $LOCAL $REMOTE";
    };
  };

  home.sessionVariables = {
    EDITOR = "vim";
  };

  programs.ssh = {
    enable = true;

    enableDefaultConfig = false;

    # Docs tell me to do that
    matchBlocks."*" = {
      forwardAgent = false;
      addKeysToAgent = "no";
      compression = false;
      serverAliveInterval = 0;
      serverAliveCountMax = 3;
      hashKnownHosts = false;
      userKnownHostsFile = "~/.ssh/known_hosts";
      controlMaster =
        "no";
      controlPath = "~/.ssh/master-%r@%n:%p";
      controlPersist = "no";
    };

    extraConfig = ''
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
      enable = true;
      shellIntegration.enableZshIntegration = true;

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

        enable_audio_bell false
        visual_bell_duration 0.1

        # Default is 2k, I want MORE!
        scrollback_lines 100000

        cursor_trail 3

        notify_on_cmd_finish invisible
      '';
    };

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        email = "guillaum.bouchard@gmail.com";
        name = "Guillaume Bouchard";
      };
      ui = {
        merge-editor = "meld";
        diff-editor = "meld";
      };
      git = {
        push-new-bookmarks = true;
      };
      merge-tools.kitty = {
        program = "kitten";
        diff-args = [ "diff" "$left" "$right" ];
      };
      merge-tools.zlib = {
        program = "zlib-diff";
        diff-args = [ "$left" "$right" ];
        diff-invocation-mode = "file-by-file";
      };
      merge-tools.jsonzlib = {
        program = "jsonzlib-diff";
        diff-args = [ "$left" "$right" ];
        diff-invocation-mode = "file-by-file";
      };
      merge-tools.images = {
        program = "diff-image";
        diff-args = [ "$left" "$right" ];
        diff-invocation-mode = "file-by-file";
      };
      revset-aliases = {
        "closest_bookmark(to)" = "heads(::to & bookmarks())";
      };
      template-aliases = {
        telescope = ''format_short_commit_id(commit_id) ++ " " ++ if(description, description.first_line(), "(no description)") ++ " " ++ bookmarks ++  "\n"'';
      };
    };
  };

  # services.blueman-applet.enable = true;

  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = [ "graphical-session-pre.target" ];
    };
  };
  home.stateVersion = "20.09";

  home.activation = {
    reloadNvimColorScheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Force all nvim to the new colorscheme
      pkill -SIGUSR1 nvim || echo "no vim was started"

      ${pkgs.hsetroot}/bin/hsetroot -solid $(xrdb -get system.background)
      i3-msg restart
    '';
  };
}
