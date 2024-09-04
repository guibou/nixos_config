{...}:
{
  imports = [
    # Setup for the xys-9315 camera IPU6
    # However, this is unsucessful since begenning 
    ./camera.nix
  ];

  # Tentative fix in order to fix the annoying touchpad, scroll is broken sometime
  boot.blacklistedKernelModules = [ "psmouse" ];

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
  boot.kernelParams = [ "mem_sleep_default=deep" ];

}

# Note: DELL XPS system rescue keys
# - Press <Alt>, then <Fn>, then R key
# - release R key, and press
# - f (on the keyboard, not your layout) to run the OOM killer
# - s(ync) / u(mount) / b(boot)
