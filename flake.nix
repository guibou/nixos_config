{
  description = "Home Manager configuration of @guibou";

  inputs = {
    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs?shallow=1&ref=nixos-unstable";

    home-manager = {
      url = "git+https://github.com/nix-community/home-manager?shallow=1&ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-flake.url = "git+https://github.com/nix-community/neovim-nightly-overlay?shallow=1&ref=master";

    nightfox-nvim = {
      url = "git+https://github.com/EdenEast/nightfox.nvim?shallow=1&ref=main";
      flake = false;
    };

    disko.url = "git+https://github.com/nix-community/disko?shallow=1&ref=master";

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    doctor = {
      url = "git+file:///home/guillaume/jinko/doctor";
    };
  };

  # Contains everything cached from nix-community, including neovim
  nixConfig = {
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
  };

  outputs = { nixpkgs, home-manager, neovim-flake, nightfox-nvim, disko, nur, doctor, ... }:
    let
      system = "x86_64-linux";
      neovim = (neovim-flake.packages.${system}.neovim).override { };

      novaModule = {
        nixpkgs.overlays = [
          doctor.overlays.autoCalledPackages
        ];

        imports = [
          #doctor.nixosModules.datadog-agent
          #doctor.nixosModules.antivirus
          doctor.nixosModules.vpn
          "${doctor}/nixos/modules/nix-cache.nix"
          "${doctor}/nixos/user-config.nix"
          { }
        ];

        userConfig = {
          login = "guillaume.bouchard";
          pc = "n00101";
        };

        home-manager.users.guillaume = {
          imports = [
            ./home.nix
            "${doctor}/nix/hm/zerotrust.nix"
            "${doctor}/nixos/collections/nova/ssh-known-hosts/hm.nix"
            "${doctor}/nixos/collections/guillaume.bouchard/firefox-bookmarks/hm.nix"
            "${doctor}/nixos/common/user-profile.nix"
          ];
        };

        home-manager.users.root = import "${doctor}/nixos/hm/root.nix";
      };
    in
    {
      nixosConfigurations =
        let
          myNixos = { dark, isNova }:
            nixpkgs.lib.nixosSystem {
              inherit system;
              specialArgs = {
                inherit nixpkgs disko nur;
              };

              modules =
                nixpkgs.lib.optional isNova novaModule
                ++
                [
                  ./nixos/configuration.nix
                  home-manager.nixosModules.home-manager

                  {
                    # Ensure that home-manager uses nixpkgs and that flake have
                    # the globally pinned nixpkgs
                    home-manager.useGlobalPkgs = true;
                    home-manager.useUserPackages = true;

                    # Some config files can be overriden by the tool (such as htop)
                    # When home-manager try to create the symlink, it will fail
                    # Instead, this won't fail and just move the new file in a "backup" file
                    home-manager.backupFileExtension = "backup";

                    home-manager.users.guillaume = {
                      imports = [
                        ./home.nix
                      ];
                      dark-theme = dark;
                    };

                    # Optionally, use home-manager.extraSpecialArgs to pass
                    # arguments to home.nix
                    home-manager.extraSpecialArgs = {
                      inherit neovim nightfox-nvim;
                      nur = nur.legacyPackages.${system};
                    };
                  }
                ];
            };
        in
        {
          gecko = myNixos { dark = false; isNova = true; };
          gecko_no_nova = myNixos { dark = false; isNova = false; };
          gecko_dark = myNixos { dark = true; isNova = true; };

          family =
            nixpkgs.lib.nixosSystem {
              inherit system;
              specialArgs = { inherit nixpkgs disko nur; };

              modules =
                [
                  ./nixos/configuration-familly-laptop.nix
                ];
            };
        };
    };
}
