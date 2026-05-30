{ pkgs, config, ... }:
{
  programs.nix-index.enableFishIntegration = true;
  home.shell.enableFishIntegration = true;
  programs.direnv.enableFishIntegration = true;
  programs.fzf.enableFishIntegration = true;
  programs.kitty.shellIntegration.enableFishIntegration = true;

  programs.fish = {
    enable = true;

    functions = {
      fish_greeting.body = "";
      icat.body = ''
        kitty +kitten icat $args
      '';
    };

    generateCompletions = true;

    /*
      initContent =
      ''
        # skydive roulette
        [ $[ $RANDOM % 1500 ] -eq 0 ] && ${pkgs.libnotify}/bin/notify-send --urgency critical "Cutaway!";

        LESS="-XRj.5"
        export BROWSER="firefox"

        icat () {
          kitty +kitten icat $*
        }

        ghc_with () {
          version=$1;shift
          nix shell --impure --expr "(with import ${pkgs.path} {};haskell.packages.ghc$version.ghcWithPackages (ps: with ps; [ haskell-language-server $* ]))"
        }

        ghc_nohls_with () {
          version=$1;shift
          nix shell --impure --expr "(with import ${pkgs.path} {};haskell.packages.ghc$version.ghcWithPackages (ps: with ps; [ $* ]))"
        }

        ghci_with () {
          version=$1;shift
          nix shell --impure --expr "(with import ${pkgs.path} {};haskell.packages.ghc$version.ghcWithPackages (ps: with ps; [ $* ]))" --command ghci
        }

        cabalBuild () {
          version=$1;shift
          nix build --impure --expr '(with import ${pkgs.path} {}; haskell.packages.ghc$version.developPackage { root = ./.; })'
        }

        cabalEnv () {
          version=$1;shift
          nix develop --impure --expr '(with import ${pkgs.path} {}; (haskell.packages.ghc$version.developPackage { root = ./.; }).overrideAttrs(old: {
                    nativeBuildInputs = old.nativeBuildInputs ++ [pkgs.cabal-install pkgs.haskellPackages.haskell-language-server];
          }))'
        }
      '';
    */
  };

}
