{ pkgs, config, ... }:
{
   programs.nix-index.enableZshIntegration = true;
   home.shell.enableZshIntegration = true;
   programs.direnv.enableZshIntegration = true;
   programs.fzf.enableZshIntegration = true;
   programs.kitty.shellIntegration.enableZshIntegration = true;


  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    enableVteIntegration = true;
    autosuggestion.enable = true;

    dotDir = "${config.xdg.configHome}/zsh";

    plugins = [
      /*{
        name = "zsh-autocomplete"; # completes history, commands, etc.
        src = pkgs.fetchFromGitHub {
          owner = "marlonrichert";
          repo = "zsh-autocomplete";
          rev = "762afacbf227ecd173e899d10a28a478b4c84a3f";
          sha256 = "1357hygrjwj5vd4cjdvxzrx967f1d2dbqm2rskbz5z1q6jri1hm3";
        }; # e.g., nix-prefetch-url --unpack https://github.com/marlonrichert/zsh-autocomplete/archive/762afacbf227ecd173e899d10a28a478b4c84a3f.tar.gz
      }*/
    ];

    oh-my-zsh = {
      enable = true;
      plugins = [ "" ];
      theme = "norm";
    };

    initContent =
      ''
        # skydive roulette
        [ $[ $RANDOM % 1500 ] -eq 0 ] && ${pkgs.libnotify}/bin/notify-send --urgency critical "Cutaway!";

        LESS="-XRj.5"
        export BROWSER="firefox"

        icat () {
          kitty +kitten icat $*
        }

        # I don't know why, but RPROMPT seems to be set to something by
        # default
        export RPROMPT=

        # I don't know why but zsh does not contain the completion for nix
        # It seems that I have no .nix-profile in my home
        fpath=(${pkgs.nix}/share/zsh/site-functions/ "''${fpath[@]}")
        autoload -U compinit && compinit

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

  };
}
