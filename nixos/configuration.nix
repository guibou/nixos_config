# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, nixpkgs, lib, disko, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./sway.nix
    "${disko}/module.nix"
    ./disko.nix
    # ./nvidia.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    kernel.sysctl = {
      # vulkan driver asks for this
      "dev.i915.perf_stream_paranoid" = 0;
      "kernel.sysrq" = 1;

      # neovim file watcher require that...
      # See :h fswatch-limitations
      "fs.inotify.max_user_watches" = 1000000;
      "fs.inotify.max_queued_events" = 1000000;
    };
    loader = {
      systemd-boot.enable = true;
      systemd-boot.consoleMode = "max";
      efi.canTouchEfiVariables = false;
    };

    #binfmt.emulatedSystems = ["armv6l-linux" "armv7l-linux"];

    tmp.cleanOnBoot = true;
    tmp.useTmpfs = true;

    kernelPackages = pkgs.linuxPackages_latest;

    # save batter in sleep
    # This was needed by XPS 13, not anymore on lenovo X1 Gen 8
    kernelParams = [ "mem_sleep_default=deep" ];
  };

  # systemd version of earlyoom
  # Compare with earlyoom and facebook oomd?
  systemd.oomd.enable = true;

  networking = {
    hostName = "gecko"; # Define your hostname.
    networkmanager = {
      enable = true;

      # Remove a lot of vpn plugins
      plugins = lib.mkForce [];
    };
    # allow wifi in cafee
    resolvconf.dnsExtensionMechanism = false;

    firewall = {
      enable = true;

      # Open ports in the firewall.
      # for koryo
      # allowedTCPPorts = [ 3003 3004 9160 ];

      # For castnow
      allowedTCPPortRanges = [
        # Castnow
        {
          from = 4100;
          to = 4105;
        }
        # Koryo
        {
          from = 3003;
          to = 3004;
        }
	# Webserver
	{
	   from = 8000;
	   to = 8081;
	}
      ];
      allowedUDPPorts = [ 5353 ];
    };
  };

  console = {
    # Not needed anymore, auto detected by the installer in hardware-configuration.nix
    # font = "latarcyrheb-sun32";
    keyMap = "dvorak";
  };

  i18n = { defaultLocale = "en_US.UTF-8"; };

  #time.timeZone = "Europe/Paris";
  # time.timeZone = "Indian/Reunion";
  #time.timeZone = "Indian/Mauritius";

  # "Indian/Reunion" does not work with firefox, I have no idea why.
  time.timeZone = "Asia/Dubai";
  # time.timeZone = "America/Los_Angeles";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    wget
    ncdu
    iotop
    exfat
    brightnessctl
    vulkan-tools
    ntfs3g
    neovim
  ];

  documentation.man.enable = true;

  fonts.packages = with pkgs; [ noto-fonts monaspace (nerdfonts.override { fonts = [ "BitstreamVeraSansMono" ]; })  ];

  # services.nix-serve.enable = true;

  programs = {
    bash.enableCompletion = true;
    command-not-found.enable = true;
    zsh.enable = true;
    ssh.startAgent = true;
    #gnome-terminal.enable = true;
  };

  # Enable integration with google services in gnome
  # services.gnome.gnome-online-accounts.enable = true;
  # services.gnome.gnome-keyring.enable = true;
  # services.gvfs.enable = true;
  # programs.seahorse.enable = true;

  services.autorandr.enable = true;

  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;

      wireplumber.enable = true;
    };

    logind = { lidSwitch = "ignore"; };
    avahi.enable = false;
    # fingerprint things. I don't like it.
    # fprintd.enable = true;

    fwupd.enable = true; # BIOS upgrade
    fstrim.enable = true; # trim for SSD
    openssh.enable = true;
    timesyncd.enable = true; # NTP sync
    blueman.enable = true;

    # Enable the X11 windowing system.
    xserver = {
      enable = true;
      # videoDrivers = ["intel"];

      # Enable touchpad support.
      libinput.enable = true;

      xkb = {
        variant = "dvorak-alt-intl";
        layout = "us";
      };

      #dpi = 200;

      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [ dmenu i3lock i3status ];
      };

      # displayManager.lightdm.enable = true;
      #displayManager.gdm.wayland.enable = true;
      displayManager.gdm.enable = true;
      #displayManager.gdm.wayland = true;

      # gnome 3
      # desktopManager.gnome3.enable = true;
    };

    # Kill program before they eat all my memory
    # I can also use magic sysrq
    # On dell XPS:
    # - Press <Alt>, then <Fn>, then R key
    # - release R key, and press
    # - f (on the keyboard, not your layout) to run the OOM killer
    # earlyoom.enable = true;

    # Allows CPU to burn
    # This was needed for xps. I'm testing without it on the lenovo
    # throttled.enable = true;

  };

  # diasble for pipewire
  # sound = { enable = true; };

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
      "vboxusers"
      "networkmanager"
      "video" # for brightness control
      "adbusers"
      "dialout" # for arduino
    ];
    shell = pkgs.zsh;

    hashedPassword =
      "$6$E8th2nqj4UVi$7BHlXOs5nrhxzsYnbeUMbiD9fXonO2TQgnFUhQ9YrjlPu4.DuPtfB8qYqE/q4TfJPWTSeKJoxU/VT/k80FriN.";
  };

  system = {
    stateVersion = "18.03"; # Did you read the comment?
  };

  virtualisation = {
    docker.enable = false;
    docker.enableOnBoot = false;
    docker.autoPrune.enable = true;

    #virtualbox.host.enable = true;
    virtualbox.host.enableHardening = false;
  };

  #networking.interfaces.vboxnet0.ipv4.addresses = lib.mkForce [{ address = "192.168.254.1"; prefixLength = 24; }];

  nix = {
    /*
    registry.nixpkgs.to = {
      type = "path";
      path = pkgs.path;
    };
    */
    registry.nixpkgs.flake = nixpkgs;

    package = pkgs.nixUnstable;
    buildMachines = [
      {
        hostName = "ovh-hybrid-runner-1.devops.novadiscovery.net";
        maxJobs = 47;
        system = "x86_64-linux";
        supportedFeatures = [ "big-parallel" "benchmark" "kvm" ];
      }
      {
        hostName = "ovh-hybrid-runner-2.devops.novadiscovery.net";
        maxJobs = 47;
        system = "x86_64-linux";
        supportedFeatures = [ "big-parallel" "benchmark" "kvm" ];
      }
    ];

    extraOptions = ''
      # I had problems with auto-optimise performance when doing GC
      # Instead, I think I'll regularly run `nix store optimise`
      auto-optimise-store = false
      builders-use-substitutes = true
      # require-sigs = false
      # post-build-hook = /etc/nix/post-build-hook.sh
      extra-experimental-features = nix-command flakes recursive-nix
      #extra-substituters = http://192.168.1.122:8080
      # extra-substituters = s3://devops-ci-infra-prod-caching-nix?region=eu-central-1&profile=nix-daemon

    #extra-substituters = s3://devops-ci-infra-prod-caching-nix?region=eu-central-1&profile=nix-daemon
    #extra-trusted-public-keys = jinkotwo:04t6bF1/peQlZWVpYPN0BraxIV2pdlN2005Vi0hUvso=

      warn-dirty = false
      flake-registry =
    '';

    settings = {
      sandbox = true;
      trusted-users = [ "root" "guillaume" ];
      cores = 8;
      max-jobs = 8;
    };
  };

  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.chromium = {
    # enableVaapi = true;
  };

  hardware = {
    sane = {
      enable = true;
      brscan4 = {
        enable = true;
	netDevices = {
          office = {
	    ip = "192.168.1.9";
	    model = "MFC-J6945DW";
	  };
	};
      };
    };
    cpu.intel.updateMicrocode = true;
    pulseaudio = {
      enable = false;
      # Disabled for pipewire
      # enable = false;

      extraConfig = ''
         # set-card-profile bluez_card.C0_86_B3_57_F3_DF handsfree_head_unit
      '';
    };
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = false;

      # Intel hw accelerated
      # Deactivated. It generates a lot of glitches
      extraPackages = with pkgs; [
        #intel-media-driver # LIBVA_DRIVER_NAME=iHD
        #vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
        #vaapiVdpau
        #libvdpau-va-gl
        #intel-ocl
      ];
    };
    bluetooth.enable = true;

    # video.hidpi.enable = true;
  };

  # Setup recommanded power management settings
  # TODO: I'm trying to disable that. I'm observing slow wifi detection, issues
  # at wake up, ...
  #powerManagement.powertop.enable = true;
  powerManagement.enable = true;

  # For android developement
  # programs.adb.enable = true;

  #services.unifi.enable = true;

  # Swap file on btrfs created using:
  # touch /var/swapfile
  # chmod 600 /var/swapfile
  # chattr +C /var/swapfile
  # fallocate /var/swapfile -l4g
  # mkswap /var/swapfile 

  # Swap is recommanded with systemd.oomd
  #swapDevices = [{
  #  device = "/var/swapfile";
  #  size = 8192;
  #}];

  # services.redis.servers."".enable = true;
  services.postgresql = {
    enable = false;
    package = pkgs.postgresql_12;
  };

  /*
  xdg.portal = {
   enable = true; 
   xdgOpenUsePortal = true; 
   wlr.enable = true;
  };
  */
}
