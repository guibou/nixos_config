{ pkgs, config, nur, ... }:
{
  home.packages = with pkgs; [
    # Draw graph and insert latex formula
    xournalpp
    texlive.combined.scheme-full

    # C++ dev
    ccls
  ];
}
