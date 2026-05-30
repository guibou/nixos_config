{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
  };

  users.users.guillaume.shell = pkgs.fish;
}
