{ config, pkgs, nixpkgs, lib, disko, ... }:

{
  imports = [
  ];

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    permitCertUid = "nova";
  };
}

/*


# RESET
sudo tailscale up --force-reauth --reset --login-server https://relay-prod.jinko.ai --operator=guillaume

tailscale up --login-server https://relay-prod.jinko.ai --exit-node "relay-prod.relay.novainsilico.home.arpa" 
tailscale up --login-server https://relay-prod.jinko.ai --exit-node "relay-af-prod.relay.novainsilico.home.arpa" 


*/
