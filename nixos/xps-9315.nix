{ pkgs, ... }:
{
  imports = [
    # Setup for the xys-9315 camera IPU6
    # However, this is unsucessful since begenning 
    # ./camera.nix
  ];

  #boot.blacklistedKernelModules = [
  #  # Tentative fix in order to fix the annoying touchpad, scroll is broken sometime
  #  # Note: does not fix the bug
  #  "psmouse"

  #  # From: https://discussion.fedoraproject.org/t/intel-mipi-ipu6-camera-issue-on-fedora-41-firmware-fails-with-code-2/134842/9,
  #  # May solve the camera loading issues
  #  "intel-ipu6"
  #  "intel-ipu6-isys"
  #];

  # Was suppose to fix the problem but:
  # a) Does not fix it
  # b) does not persist on reboot
  # services.xserver.config = ''
  #       # Try to disable the two devices (mouse) which may be responsible
  #       # For the heratic behavior of my touchpad
  #       Section "InputClass"
  #          Identifier         "disable PS2 generic mouse"
  #          MatchIsTouchscreen "on"
  #          MatchProduct       "PS/2 Generic Mouse"
  #          Option             "Ignore" "on"
  #       EndSection
  #       Section "InputClass"
  #          Identifier         "disable VEN mouse"
  #          MatchIsTouchscreen "on"
  #          MatchProduct       "VEN_04F3:00 04F3:3242 Mouse"
  #          Option             "Ignore" "on"
  #       EndSection
  #     '';

  # save batter in sleep
  # That's XPS only
  # Note: removed, seems to not be required anymore
  # boot.kernelParams = [ "mem_sleep_default=deep" ];

  # Microphone fix
  # Persistence of alsa setup
  # See also the trick with alsactl init in https://discourse.nixos.org/t/dell-xps-13-9320-microphone-not-working/40932/3
  # The option does not exists anymore
  # hardware.alsa.enablePersistence = true;

  # things seems to work better on recent kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
}

# Note: DELL XPS system rescue keys
# - Press <Alt>, then <Fn>, then R key
# - release R key, and press
# - f (on the keyboard, not your layout) to run the OOM killer
# - s(ync) / u(mount) / b(boot)
