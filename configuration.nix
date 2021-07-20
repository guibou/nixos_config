# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    kernel.sysctl = {
      # vulkan driver asks for this
      "dev.i915.perf_stream_paranoid" = 0;
    };
    loader = {
      systemd-boot.enable = true;
      systemd-boot.consoleMode = "max";
      efi.canTouchEfiVariables = false;
    };

    #binfmt.emulatedSystems = ["armv6l-linux" "armv7l-linux"];

    cleanTmpDir = true;
    tmpOnTmpfs = true;

    kernelPackages = pkgs.linuxPackages_latest;
    extraModulePackages = [ pkgs.linuxPackages_latest.v4l2loopback ];

    # save batter in sleep
    # This was needed by XPS 13, not anymore on lenovo X1 Gen 8
    # kernelParams = [ "mem_sleep_default=deep" ];
  };

  networking = {
    hostName = "paddle"; # Define your hostname.
    networkmanager.enable = true;
    #networkmanager.unmanaged = ["vboxnet0"];
    #nameservers = ["8.8.8.8" "8.8.4.4"];

    firewall = {
      enable = false;

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

  time.timeZone = "Europe/Paris";
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
  ];

  documentation.man.enable = true;

  fonts.fonts = with pkgs; [ nerdfonts noto-fonts noto-fonts-emoji symbola ];

  # services.nix-serve.enable = true;

  programs = {
    bash.enableCompletion = true;
    command-not-found.enable = true;
    zsh.enable = true;
    sway.enable = false;
    ssh.startAgent = true;
    gnome-terminal.enable = true;
  };

  services = {
    logind = { lidSwitch = "ignore"; };
    avahi.enable = true;
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

      layout = "us";
      xkbVariant = "dvorak-alt-intl";

      dpi = 200;

      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [ dmenu i3lock i3status ];
      };

      # displayManager.lightdm.enable = true;
      #displayManager.gdm.wayland.enable = true;
      displayManager.gdm.enable = true;

      # gnome 3
      # desktopManager.gnome3.enable = true;
    };

    # Kill program before they eat all my memory
    # I still wonder why it freeze the computer considering that I have no swap space.
    # Disabled for now, I enabled a swap file
    # earlyoom.enable = true;

    # Allows CPU to burn
    # This was needed for xps. I'm testing without it on the lenovo
    # throttled.enable = true;

  };

  sound = { enable = true; };

  users.mutableUsers = false;

  users.users.root.hashedPassword =
    "$6$O6nMHrXq5eAakE$EJo.Wz3hnIKzp.ER2Lh0Lndxs606GwFmmSfZjoU/WDtqsFCQOk1L7YLR5mcAUWbGlkT.HdRfq4o5KiNPrqa1f1";

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
    ];
    shell = pkgs.zsh;

    hashedPassword =
      "$6$E8th2nqj4UVi$7BHlXOs5nrhxzsYnbeUMbiD9fXonO2TQgnFUhQ9YrjlPu4.DuPtfB8qYqE/q4TfJPWTSeKJoxU/VT/k80FriN.";
  };

  system = {
    copySystemConfiguration = true;
    stateVersion = "18.03"; # Did you read the comment?
  };

  virtualisation = {
    docker.enable = true;
    docker.enableOnBoot = false;
    docker.autoPrune.enable = true;

    virtualbox.host.enable = false;
    virtualbox.host.enableHardening = false;
  };

  #networking.interfaces.vboxnet0.ipv4.addresses = lib.mkForce [{ address = "192.168.254.1"; prefixLength = 24; }];

  nix = {
    buildMachines = [
      # tweag remote builder
      {
        hostName = "build01.tweag.io";
        sshKey = "/root/.ssh/tweag-nix-builder";
        sshUser = "nix";
        maxJobs = 24;
        system = "x86_64-linux";
        supportedFeatures = [ "big-parallel" "benchmark" "kvm" ];
      }
    ];

    trustedUsers = [ "root" "guillaume" ];
    extraOptions = ''
      auto-optimise-store = true
      builders-use-substitutes = true
    '';

    useSandbox = true;

    buildCores = 8;
    maxJobs = 8;

    binaryCaches =
      [ "https://cache.nixos.org/" "https://nixcache.reflex-frp.org"
"s3://devops-ci-infra-prod-caching-nix?region=eu-central-1&profile=nix-daemon"

      ];
    binaryCachePublicKeys =
      [ "ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI="
        "jinkotwo:04t6bF1/peQlZWVpYPN0BraxIV2pdlN2005Vi0hUvso="
      ];
  };

  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.chromium = {
    # enableVaapi = true;
  };

  hardware = {
    firmware = with pkgs; [ sof-firmware ];
    sane = {
      # enable = true;
    };
    cpu.intel.updateMicrocode = true;
    pulseaudio = {
      enable = true;
      #extraConfig = ''
      #  load-module module-alsa-sink device=hw:0,0 channels=4
      #  load-module module-alsa-source device=hw:0,6 channels=4
      #'';
    };
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;

      # Intel hw accelerated
      # Deactivated. It generates a lot of glitches
      extraPackages = with pkgs; [
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
        vaapiVdpau
        libvdpau-va-gl
        intel-ocl
      ];
    };
    bluetooth.enable = true;

    video.hidpi.enable = true;
  };

  # Setup recommanded power management settings
  # TODO: I'm trying to disable that. I'm observing slow wifi detection, issues
  # at wake up, ...
  #powerManagement.powertop.enable = true;

  # For android developement
  # programs.adb.enable = true;

  #services.unifi.enable = true;

  # Swap file on btrfs created using:
  # touch /var/swapfile
  # chmod 600 /var/swapfile
  # chattr +C /var/swapfile
  # fallocate /var/swapfile -l4g
  # mkswap /var/swapfile 
  swapDevices = [{
    device = "/var/swapfile";
    size = 8192;
  }];
}
