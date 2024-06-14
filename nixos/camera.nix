# This is a tentative configuraton file to fix the camera on the dell xps 9315.
# I've tried many things, up to a black screen

{ config, pkgs, nixpkgs, lib, disko, ... }:
{
  # Kernel 6.9
  boot.kernelPackages = pkgs.linuxPackages_latest;

  hardware.enableAllFirmware = true;

  services.pipewire = {
    enable = true;
    wireplumber.enable = true;
  };
}
