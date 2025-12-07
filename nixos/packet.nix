{pkgs, ...}:
{
  networking.firewall.allowedTCPPorts = [9300];
  networking.firewall.allowedUDPPorts = [5353];
  environment.systemPackages = [pkgs.packet];
}
