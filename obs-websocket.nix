{ stdenv, lib, fetchurl, cmake, obs-studio, qt5, libGL, websocketpp, asio }:
stdenv.mkDerivation {
  name = "obs-websocket";

  buildInputs = [ cmake obs-studio qt5.full libGL websocketpp asio ];

  cmakeFlags = "-DUSE_UBUNTU_FIX=true";

  src = fetchurl {
    url = "https://github.com/Palakis/obs-websocket/archive/4.x-current.tar.gz";
    sha256 = "0nnn3xvm5l3p3r9xqrdzz3dd0b6jsykipz43azqslss9z1dq46lj";
  };
}
