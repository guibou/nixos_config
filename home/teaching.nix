{ pkgs, config, nur, ... }:
{
  home.packages = with pkgs; [
    # Draw graph and insert latex formula
    xournalpp
    texliveSmall

    # C++ dev
    ccls
  ];
}
