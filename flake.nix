{
  description = "Home Manager configuration of @guibou";

  inputs = {
    # nixos.url = "/etc/nixos";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-flake = {
      url = "github:neovim/neovim?dir=contrib";
      #inputs.nixpkgs.follows = "nixpkgs";
    };

    nightfox-nvim = {
      url = "github:/EdenEast/nightfox.nvim";
      flake = false;
    };

    disko = {
       url = "github:nix-community/disko";
    };

    ts.url = "github:polarmutex/nixpkgs/update-treesitter";
  };

  outputs = { nixpkgs, home-manager, neovim-flake, nightfox-nvim, ts, disko, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      neovim = (neovim-flake.packages.${system}.neovim).override {
        tree-sitter = ts.legacyPackages.${system}.tree-sitter;
        #libvterm-neovim = pkgs.libvterm-neovim.overrideAttrs (old: rec {
        #  version = "0.3.3";

        #  src = pkgs.fetchurl {
        #    url = "https://launchpad.net/libvterm/trunk/v0.3/+download/libvterm-${version}.tar.gz";
        #    sha256 = "sha256-CRVvQ90hKL00fL7r5Q2aVx0yxk4M8Y0hEZeUav9yJuA=";
        #  };
        #});
      };

      mkConfig = dark: home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [ ./home.nix ];

        extraSpecialArgs = { inherit neovim dark nightfox-nvim; };
      };
    in {
      homeConfigurations.dark = mkConfig true;
      homeConfigurations.light = mkConfig false;
      homeConfigurations."guillaume" = mkConfig false;


      nixosConfigurations = {
        narwal = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
	  specialArgs = { inherit nixpkgs disko; };
          modules = [
            ./nixos/configuration.nix
          ];
        };
      };
    };
}
