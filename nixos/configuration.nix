{ config, pkgs, nixpkgs, lib, disko, ... }:

{
  imports = [
    ./hardware-configuration.nix
    "${disko}/module.nix"
    ./disko.nix
    ./xps-9315.nix
    ./timezone-run.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    kernel.sysctl = {
      "kernel.sysrq" = 1;

      # neovim file watcher require that...
      # See :h fswatch-limitations
      "fs.inotify.max_user_watches" = lib.mkForce 1000000;
      "fs.inotify.max_queued_events" = 1000000;
    };
    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "max";
        configurationLimit = 20;
      };
      efi.canTouchEfiVariables = false;
    };

    # Boot is not on tmpfs because I had problem when installing large package
    # But cleaning tmp on boot allows the cruft to not stay.
    tmp.cleanOnBoot = true;
  };

  # TODO: this is in order to kill programs, such as ghc, when it uses too much memory.
  # But i had never had really good results with it, my system is still freezing sometime.
  systemd.oomd.enable = true;

  networking = {
    hostName = "gecko";

    networkmanager = {
      enable = true;
    };

    # Allow wifi in cafee
    resolvconf.dnsExtensionMechanism = false;

    firewall = {
      enable = true;
    };
  };

  console = {
    keyMap = "dvorak";
  };

  i18n = { defaultLocale = "en_US.UTF-8"; };

  documentation.man.enable = true;

  fonts.packages = with pkgs; [ nerd-fonts.bitstream-vera-sans-mono monaspace ];

  # services.nix-serve.enable = true;

  programs = {
    i3lock = {
       enable = true;
       package = pkgs.i3lock-color;
     };
    steam.enable = true;
    bash.completion.enable = true;
    zsh = {
       enable = true;
       enableCompletion = true;
     };
    ssh.startAgent = true;
  };

  # Automatic change screen configuration
  services.autorandr.enable = true;

  services = {
    pipewire = {
      enable = true;
      alsa.enable = false;
      pulse.enable = true;

      wireplumber.enable = true;

      # I have no idea what I'm doing, but it may fixs final fantasy on proton / steam
      extraConfig.pipewire.adjust-sample-rate = {
        "context.properties" = {
          "default.clock.min-quantum" = 1024;
        };
      };
    };

    logind = { settings.Login.HandleLidSwitch = "ignore"; };
    avahi.enable = false;

    fwupd.enable = true; # BIOS upgrade
    fstrim.enable = true; # trim for SSD

    # I'm NOT connecting to SSH on my laptop
    openssh.enable = false;

    timesyncd.enable = true; # NTP sync
    blueman.enable = true;

    # Enable touchpad support.
    libinput.enable = true;

    # Enable the X11 windowing system.
    xserver = {
      enable = true;

      xkb = {
        variant = "dvorak-alt-intl";
        layout = "us";
      };

      # TODO: this could be moved to home-manager
      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [ dmenu i3status ];
      };
    };
  };

  services.displayManager =
    {
      defaultSession = "none+i3";

      autoLogin = {
        # it freeze once logged
        enable = false;
        user = "guillaume";
      };

        gdm = {
          enable = true;
      };
    };

  # Enable for pipewire;
  security.rtkit.enable = true;

  users.mutableUsers = false;

  users.users.root.hashedPassword = "$6$nKLIR1dRDGe0uzw7$aJ2bP5pvs2sGfj78cM87FrPCiNvQ9iaNp1XcA/3ZFQyPpY5wMKuHvkUweL3EtMzzoMz13ZR796asFB3UdLnTO/";

  users.users.guillaume = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [
      "wheel"
      "docker"
      "plugdev"
      "networkmanager"
      "video" # for brightness control
    ];

    shell = pkgs.zsh;

    hashedPassword =
      "$6$E8th2nqj4UVi$7BHlXOs5nrhxzsYnbeUMbiD9fXonO2TQgnFUhQ9YrjlPu4.DuPtfB8qYqE/q4TfJPWTSeKJoxU/VT/k80FriN.";
  };

  system = {
    stateVersion = "18.03"; # Did you read the comment?

    activationScripts = {
      # Show diff between current and new system
      nixosDiff = ''
        PATH=$PATH:${lib.makeBinPath [ pkgs.nvd pkgs.nix ]}
        nvd diff /run/current-system "$systemConfig"
      '';
    };
  };

  virtualisation = {
    docker.enable = false;
    docker.enableOnBoot = false;
    docker.autoPrune.enable = true;
  };

  nix = {
    # Pin registry so it only contains flake and that this flake is already
    # pinned to current nixpkgs.

    # This saves a nixpkgs redownload everytime I run `nix run nixpkgs#xxx`,
    # which is highly convenient when you are on the other side of the world
    # and the internect connection is going through an optical fiber under the
    # ocean that rocks and sharks are cutting every days ending by "day".
    registry.nixpkgs.flake = nixpkgs;

    package = pkgs.nixVersions.latest;

    settings = {
      sandbox = true;
      trusted-users = [ "root" "guillaume" ];
      cores = 12;
      max-jobs = 12;

      # This thing had saved me a lot of disk before, but `nix-collect-garbage`
      # can be impressively slow and fail in case of not enough hard disk.
      # It is also slower when doing nix build
      # I'm now relying on manual optimisation on demand + btrfs compression +
      # (TODO: btrfs deduplication).
      # I can also nix-collect-garbage every year and not wait 3 years like
      # last time ;)
      auto-optimise-store = false;

      builders-use-substitutes = true;
      extra-experimental-features = [ "nix-command" "flakes" "recursive-nix" ];
      warn-dirty = false;

      # No more implicit registry
      flake-registry = [ ];

      # lazy-trees = true;
    };
  };

  # Required for some unfree firmware, I suppose.
  nixpkgs.config.allowUnfree = true;

  hardware = {
    cpu.intel.updateMicrocode = true;
    bluetooth.enable = true;
  };

  powerManagement.enable = true;
  services.upower.enable = true;

  # Most of the critical part of the system are on my main user, sudo is only
  # used to `nixos-rebuild switch` on a new system.
  # So, an attacker who have access to my user session unlocked will gain
  # NOTHING by using sudo.
  security.sudo.wheelNeedsPassword = false;


  # This environment variable prevents the AWS cli from trying to fetch
  # metadata at the initialisation, and allow us to win 6 seconds of
  # waiting at each nix command.
  # See https://github.com/aws/aws-cli/issues/5623
  systemd.services.nix-daemon.serviceConfig.Environment = [ "AWS_EC2_METADATA_DISABLED=true" ];


  # Helps with path completion, well' I'm unsure
  environment.pathsToLink = [ "/share/zsh" ];
}
