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
tailscale up --reset --login-server https://relay-prod.jinko.ai --operator="$SUDO_USER"

tailscale up --login-server https://relay-prod.jinko.ai --exit-node "relay-prod.relay.novainsilico.home.arpa" --operator="$SUDO_USER"

tailscale up --login-server https://relay-prod.jinko.ai --exit-node "relay-af-prod.relay.novainsilico.home.arpa"

tailscale down
*/
