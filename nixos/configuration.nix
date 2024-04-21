{ config, pkgs, nixpkgs, lib, disko, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    "${disko}/module.nix"
    ./disko.nix
    ./camera.nix
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

    # Boot is not on tmpfs because I had problem when installing large package
    # But cleaning tmp on boot allows the cruft to not stay.
    tmp.cleanOnBoot = true;

    # save batter in sleep
    # That's XPS only
    kernelParams = [ "mem_sleep_default=deep" ];
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
    # Not needed anymore, auto detected by the installer in hardware-configuration.nix
    # font = "latarcyrheb-sun32";
    keyMap = "dvorak";
  };

  i18n = { defaultLocale = "en_US.UTF-8"; };

  #time.timeZone = "Europe/Paris";
  #time.timeZone = "Indian/Reunion";
  # "Indian/Reunion" does not work with firefox, I have no idea why.
  time.timeZone = "Asia/Dubai";

  documentation.man.enable = true;

  # TODO: Reevaluate if this cannot be moved to home-manager
  fonts.packages = with pkgs; [ noto-fonts monaspace (nerdfonts.override { fonts = [ "BitstreamVeraSansMono" ]; }) ];

  # services.nix-serve.enable = true;

  programs = {
    bash.enableCompletion = true;
    zsh.enable = true;
    ssh.startAgent = true;
  };

  # Automatic change screen configuration
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

    # I'm NOT connecting to SSH on my laptop
    openssh.enable = false;

    timesyncd.enable = true; # NTP sync
    blueman.enable = true;

    # Enable the X11 windowing system.
    xserver = {
      enable = true;

      # Enable touchpad support.
      libinput.enable = true;

      xkb = {
        variant = "dvorak-alt-intl";
        layout = "us";
      };

      # TODO: this could be moved to home-manager
      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [ dmenu i3lock i3status ];
      };

      displayManager.gdm.enable = true;
    };

    # Note: DELL XPS system rescue keys
    # - Press <Alt>, then <Fn>, then R key
    # - release R key, and press
    # - f (on the keyboard, not your layout) to run the OOM killer
    # - s(ync) / u(mount) / b(boot)
  };

  sound = { enable = true; };

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

    package = pkgs.nixUnstable;

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
    };
  };

  # Required for some unfree firmware, I suppose.
  nixpkgs.config.allowUnfree = true;

  hardware = {
    cpu.intel.updateMicrocode = true;
    opengl = {
      enable = true;
      driSupport = true;

      # Not playing with 32bits things, so don't care for now.
      driSupport32Bit = false;
    };

    bluetooth.enable = true;
  };

  powerManagement.enable = true;
}
