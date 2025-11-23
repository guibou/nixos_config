{ pkgs, ... }:
{
  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.fprintd = {
      # Disable: it does not work as expected, it also disable password login
      # and last time I had moisture on my fingers and was unable to log to my
      # laptop for 5 minutes.
      enable = false;
      tod.enable = true;
      tod.driver = pkgs.libfprint-2-tod1-goodix;
    };
}

# note: the x1 carbon had sysrescue on alt + printscreen.
