{ pkgs, inputs, ... }:
let
  dwm-custom = pkgs.stdenv.mkDerivation rec {
    pname = "dwm-custom";
    version = "6.8";
    src = ../../../pkgs/dwm-src;
    nativeBuildInputs = with pkgs; [ pkg-config ];
    buildInputs = with pkgs; [
      xorg.libX11
      xorg.libXinerama
      xorg.libXft
      freetype
      fontconfig
    ];
    installFlags = [ "DESTDIR=$(out)" "PREFIX=" ];
    postInstall = ''
      mkdir -p $out/share/xsessions
      cat > $out/share/xsessions/dwm.desktop <<EOF
      [Desktop Entry]
      Encoding=UTF-8
      Name=dwm
      Comment=Dynamic window manager
      Exec=$out/bin/dwm
      Type=Application
      EOF
    '';
    passthru.providedSessions = [ "dwm" ];
    makeFlags = [ "CC:=$(CC)" ];
  };

  st-custom = pkgs.stdenv.mkDerivation rec {
    pname = "st-custom";
    version = "0.9.3";
    src = ../../../pkgs/st-src;
    nativeBuildInputs = with pkgs; [ pkg-config ];
    buildInputs = with pkgs; [
      xorg.libX11
      xorg.libXft
      xorg.libXrender
      xorg.libXext
      freetype
      fontconfig
      imlib2
      zlib
    ];
    installFlags = [ "DESTDIR=$(out)" "PREFIX=" ];
    makeFlags = [ "CC:=$(CC)" ];
  };

  dwmblocks-custom = pkgs.stdenv.mkDerivation rec {
    pname = "dwmblocks-custom";
    version = "master";
    src = ../../../pkgs/dwmblocks-src;
    nativeBuildInputs = with pkgs; [ pkg-config ];
    buildInputs = with pkgs; [ xorg.libX11 ];
    # This Makefile has no config.mk — INSTALL_DIR/BIN are baked into the
    # Makefile itself, so override INSTALL_DIR directly rather than DESTDIR+PREFIX.
    installFlags = [ "INSTALL_DIR=$(out)/bin" ];
    makeFlags = [ "CC:=$(CC)" ];
  };
in
{
  imports = [
    inputs.xlibre-overlay.nixosModules.overlay-xlibre-xserver
    inputs.xlibre-overlay.nixosModules.overlay-all-xlibre-drivers
  ];

  services.xserver.enable = true;
  services.displayManager.sessionPackages = [ dwm-custom ];
  services.dbus.enable = true; # dwmblocks status loop needs a session bus, same fix as gentoo-btw

  environment.systemPackages = [
    dwm-custom
    st-custom
    dwmblocks-custom
  ];
}
