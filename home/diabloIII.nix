{ pkgs }:

with pkgs; rec {
  #wine = wineStaging;

  wine = wineWowPackages.staging;

  dxtn = pkgsi686Linux.libtxc_dxtn;

  diablo3_nodxtn = runCommand "diablo3" { buildInputs = [ makeWrapper wine samba ]; } ''
    mkdir -p "$out/bin"
    makeWrapper "${wine}/bin/wine" "$out/bin/diablo3_launcher" \
        --set WINEARCH win64 \
        --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib \
        --prefix LD_LIBRARY_PATH : /run/opengl-driver-32/lib \
        --prefix PATH : ${samba}/bin/ \
        --add-flags "'.wine/drive_c/Program Files/Battle.net/Battle.net Launcher.exe'"
    makeWrapper "${wine}/bin/wine" "$out/bin/diablo3" \
        --set WINEARCH win64 \
        --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib \
        --prefix LD_LIBRARY_PATH : /run/opengl-driver-32/lib \
        --prefix PATH : ${samba}/bin/ \
        --add-flags "'.wine/drive_c/Program Files/Diablo III/Diablo III.exe' -launch"
    '';


   # Note: to first install battle.Net, you need to run wine
   # with WINEARCH=win64, otherwise it setups wine in 32bit
   # mode.
   wineShell = mkShell {
       buildInputs = [wine samba];
   };
}
