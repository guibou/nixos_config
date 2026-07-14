{ pkgs, config, ... }:
{
  programs.nix-index.enableFishIntegration = true;
  home.shell.enableFishIntegration = true;
  programs.direnv.enableFishIntegration = true;
  programs.fzf.enableFishIntegration = true;
  programs.kitty.shellIntegration.enableFishIntegration = true;

  programs.fish = {
    enable = true;

    functions =
      let

        cache = command: pkgs.writeScriptBin "cache-command"
          ''
          #!/usr/bin/env sh
          cache=$1
          lock=$2
          # This is a bit unsafe, if it is interrupted, the lock will stay forever
          if mkdir $lock 2>/dev/null
          then
              ${command} 2> /dev/null > $cache.tmp
              mv $cache.tmp $cache
              rmdir $lock
          fi
          ''
        ;
        mkCached = name: ttl: command:
          ''
            set -l cache ~/.cache/mycommand/${name}-completions
            set -l lock ~/.cache/mycommand/${name}-completions.lock
            set -l max_age ${toString ttl}
        
            mkdir -p (dirname $cache)
        
            if not test -f $cache; or test (math (date +%s) - (stat -c %Y $cache)) -gt $max_age
              # This is unfortunate, but fish can only run in background real program and not simple fish expressions
              ${cache command}/bin/cache-command $cache $lock 2> /dev/null &
            end
        
            if test -f $cache
                cat $cache
            end
          '';

      in
      {
        fish_greeting.body = "";
        icat.body = ''kitty +kitten icat $argv'';
        whichreal.body = "realpath (command -v $argv)";

        ghc_with.body = ''
          argparse "v/version=" "h/hls" -- $argv

          if set -ql _flag_version
            set ghc_version "haskell.packages.ghc$_flag_version"
          else
            set ghc_version haskellPackages
          end

          if set -ql _flag_hls
            set hls "haskell-language-server"
          else
            set hls ""
          end

          nix shell --impure --expr "(with import ${pkgs.path} {};$ghc_version.ghcWithPackages (ps: with ps; [ $hls $argv ]))"
        '';

        __get_all_haskell_deps.body = mkCached "get_all_haskell_deps" 3600
          '' nix eval --impure --raw --expr 'builtins.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs (x: y: "''${x}\t''${if (builtins.tryEval (y.meta.description or "")).success then (y.meta.description or "") else ""}") ((import (builtins.getFlake "nixpkgs") {}).haskellPackages)))' ''
        ;

        __get_aws_roles.body = mkCached "get_aws_roles" 3600
          '' ztp-gen-aws -l | tail -n+2 '';
        __get_postgresql_roles.body = mkCached "__get_postgresql_roles" 3600
          '' ztp-gen-postgres -l | tail -n+2 '';

          ztp-load-aws.body = "ztp_load_aws --role $argv[1]";
          ztp-load-postgresql.body = "ztp_load_pg --role $argv[1]";
      };

    shellInit = ''
      if test (builtin random 0 1500) -eq 0
        ${pkgs.libnotify}/bin/notify-send --urgency critical "Cutaway!";
      end

      # whichreal accept any commend
      complete -c whichreal -a '(__fish_complete_command)' -f

      complete -c ghc_with -a "(__get_all_haskell_deps)" -f

      complete -c ztp-load-aws -fra '(__get_aws_roles)'

      complete -c ztp-load-postgresql -fra '(__get_postgresql_roles)'
    '';

    generateCompletions = true;

    /*
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
