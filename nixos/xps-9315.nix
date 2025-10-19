{ pkgs, ... }:
{
  # things seems to work better on recent kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.fprintd = {
      enable = true;
      tod.enable = true;
      tod.driver = pkgs.libfprint-2-tod1-goodix;
    };
}

# Note: DELL XPS system rescue keys
# - Press <Alt>, then <Fn>, then R key
# - release R key, and press
# - f (on the keyboard, not your layout) to run the OOM killer
# - s(ync) / u(mount) / b(boot)
