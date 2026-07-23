{ lib, stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation {
  pname = "echo-sddm";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "xCaptaiN09";
    repo = "echo-sddm";
    rev = "v1.0.0";
    hash = "sha256-gou7G43uBsaRiHMUA/FlSAox5NYhI9u9t8onh1Kpl2g=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/sddm/themes/echo
    cp -r Main.qml metadata.desktop theme.conf install.sh LICENSE assets \
      $out/share/sddm/themes/echo/
      echo "QtVersion=6" >> $out/share/sddm/themes/echo/metadata.desktop
    runHook postInstall
  '';

  meta = with lib; {
    description = "macOS Terminal-inspired SDDM theme";
    homepage = "https://github.com/xCaptaiN09/echo-sddm";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
