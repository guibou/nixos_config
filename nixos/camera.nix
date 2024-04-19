# This is a tentative configuraton file to fix the camera on the dell xps 9315.
# I've tried many things, up to a black screen

{ config, pkgs, nixpkgs, lib, disko, ... }:
{
  hardware = {
    ipu6 = {
      enable = true;
      platform = "ipu6ep";
    };
  };

  # kernelPackages = pkgs.linuxPackages_latest;
}
