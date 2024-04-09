{ config, pkgs, nixpkgs, lib, ... }:

{
  imports = [ ];

  programs = {
    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraPackages = with pkgs; [
        swaylock
	swayidle
	wl-clipboard
      ];
    };
  };
}
