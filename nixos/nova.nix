{ config, pkgs, nixpkgs, lib, disko, ... }:

{
  imports = [
  ];

  /*
    # RESET
    sudo tailscale up --force-reauth --reset --login-server https://relay-prod.jinko.ai --operator=guillaume
  
    tailscale up --login-server https://relay-prod.jinko.ai --exit-node "relay-prod.relay.novainsilico.home.arpa" 
    tailscale up --login-server https://relay-prod.jinko.ai --exit-node "relay-af-prod.relay.novainsilico.home.arpa" 
  */
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    permitCertUid = "nova";
  };

  nix.extraOptions = ''
    extra-substituters = s3://devops-ci-infra-prod-caching-nix?region=eu-central-1&profile=nova-nix-cache-ro&priority=100
    extra-trusted-public-keys = jinkotwo:04t6bF1/peQlZWVpYPN0BraxIV2pdlN2005Vi0hUvso=
  '';

}
