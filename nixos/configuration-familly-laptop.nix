{ config, pkgs, nixpkgs, lib, disko, ... }:

{
  imports = [
    ./hardware-configuration.nix
    "${disko}/module.nix"
    ./disko.nix
    ./timezone-run.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    kernel.sysctl = {
      "kernel.sysrq" = 1;
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

  networking = {
    hostName = "noya";

    networkmanager = {
      enable = true;
    };
  };

  console = {
    keyMap = "azerty";
  };

  i18n = { defaultLocale = "fr_FR.UTF-8"; };

  fonts.packages = with pkgs; [ ];

  programs = {
    steam.enable = true;
  };

  services = {
    pipewire = {
      enable = true;
      alsa.enable = false;
      pulse.enable = true;

      wireplumber.enable = true;
    };

    avahi.enable = true;

    fprintd.enable = true;

    fstrim.enable = true;

    openssh.enable = true;

    timesyncd.enable = true;
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

    hashedPassword =
      "$6$E8th2nqj4UVi$7BHlXOs5nrhxzsYnbeUMbiD9fXonO2TQgnFUhQ9YrjlPu4.DuPtfB8qYqE/q4TfJPWTSeKJoxU/VT/k80FriN.";
  };

  users.users.cyrielle = {
    isNormalUser = true;
    uid = 1001;
    extraGroups = [
      "wheel"
      "docker"
      "plugdev"
      "networkmanager"
      "video" # for brightness control
    ];

    hashedPassword =
      "$6$E8th2nqj4UVi$7BHlXOs5nrhxzsYnbeUMbiD9fXonO2TQgnFUhQ9YrjlPu4.DuPtfB8qYqE/q4TfJPWTSeKJoxU/VT/k80FriN.";
  };

  users.users.abigael = {
    isNormalUser = true;
    uid = 1002;
    extraGroups = [
      "wheel"
      "docker"
      "plugdev"
      "networkmanager"
      "video" # for brightness control
    ];

    hashedPassword =
      "$6$E8th2nqj4UVi$7BHlXOs5nrhxzsYnbeUMbiD9fXonO2TQgnFUhQ9YrjlPu4.DuPtfB8qYqE/q4TfJPWTSeKJoxU/VT/k80FriN.";
  };

  users.users.valerian = {
    isNormalUser = true;
    uid = 1003;
    extraGroups = [
      "wheel"
      "docker"
      "plugdev"
      "networkmanager"
      "video" # for brightness control
    ];

    hashedPassword =
      "$6$E8th2nqj4UVi$7BHlXOs5nrhxzsYnbeUMbiD9fXonO2TQgnFUhQ9YrjlPu4.DuPtfB8qYqE/q4TfJPWTSeKJoxU/VT/k80FriN.";
  };

  system = {
    stateVersion = "25.11";

    activationScripts = {
      # Show diff between current and new system
      nixosDiff = ''
        PATH=$PATH:${lib.makeBinPath [ pkgs.nvd pkgs.nix ]}
        nvd diff /run/current-system "$systemConfig"
      '';
    };
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
      trusted-users = [ "root" "guillaume" "cyrielle" "valerian" "abigael" ];
      cores = 12;
      max-jobs = 12;

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
    bluetooth.enable = true;
  };

  powerManagement.enable = true;
  services.upower.enable = true;

  # Desktop manager
  services.desktopManager.gnome.enable = true;
}
