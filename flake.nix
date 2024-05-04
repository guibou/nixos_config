{
  description = "Home Manager configuration of @guibou";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-flake = {
      url = "github:neovim/neovim?dir=contrib";
    };

    nightfox-nvim = {
      url = "github:/EdenEast/nightfox.nvim";
      flake = false;
    };

    disko = {
      url = "github:nix-community/disko";
    };
  };

  outputs = { nixpkgs, home-manager, neovim-flake, nightfox-nvim, disko, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      neovim = (neovim-flake.packages.${system}.neovim).override { };

      mkConfig = dark: home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [ ./home.nix ];

        extraSpecialArgs = { inherit neovim dark nightfox-nvim; };
      };
    in
    {
      homeConfigurations.dark = mkConfig true;
      homeConfigurations.light = mkConfig false;
      homeConfigurations."guillaume" = mkConfig false;


      nixosConfigurations = {
        gecko = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit nixpkgs disko; };
          modules = [
            ./nixos/configuration.nix
          ];
        };
      };
    };
}
