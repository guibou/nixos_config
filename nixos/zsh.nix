{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };

  users.users.guillaume.shell = pkgs.zsh;

  # Helps with path completion, well' I'm unsure
  environment.pathsToLink = [ "/share/zsh" ];

}
