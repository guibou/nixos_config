{
  description = "Home Manager configuration of @guibou";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-flake.url = "github:nix-community/neovim-nightly-overlay";

    nightfox-nvim = {
      url = "github:/EdenEast/nightfox.nvim";
      flake = false;
    };

    disko = {
      url = "github:nix-community/disko";
    };
  };

  # Contains everything cached from nix-community, including neovim
  nixConfig = {
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
  };

  outputs = { nixpkgs, home-manager, neovim-flake, nightfox-nvim, disko, ... }:
    let
      system = "x86_64-linux";
      neovim = (neovim-flake.packages.${system}.neovim).override { };
    in
    {
      nixosConfigurations =
        let
          myNixos = dark:
            nixpkgs.lib.nixosSystem {
              inherit system;
              specialArgs = { inherit nixpkgs disko; };
              modules = [
                ./nixos/configuration.nix

                home-manager.nixosModules.home-manager
                {
                  home-manager.useGlobalPkgs = true;
                  home-manager.useUserPackages = true;

                  home-manager.users.guillaume = import ./home.nix;

                  # Optionally, use home-manager.extraSpecialArgs to pass
                  # arguments to home.nix
                  home-manager.extraSpecialArgs = {
                    inherit neovim dark nightfox-nvim;
                  };
                }
              ];
            };
        in
        {
          gecko = myNixos false;
          gecko_dark = myNixos true;
        };
    };
}
