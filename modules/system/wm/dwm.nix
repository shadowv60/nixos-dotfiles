{ pkgs, inputs, ... }:
let
   dwm-custom = pkgs.stdenv.mkDerivation rec {
  pname = "dwm-custom";
  version = "6.8";
  src = ../../../pkgs/dwm-src;
  nativeBuildInputs = with pkgs; [ pkg-config ];
  buildInputs = with pkgs; [
    libx11
    libxinerama
    libxft
    freetype
    fontconfig
  ];
  installFlags = [ "DESTDIR=$(out)" "PREFIX=" ];
  postInstall = ''
    mkdir -p $out/share/xsessions
    cp dwm.sh $out/bin/dwm-run
    chmod +x $out/bin/dwm-run
    cat > $out/share/xsessions/dwm.desktop <<EOF
    [Desktop Entry]
    Encoding=UTF-8
    Name=dwm
    Comment=Dynamic window manager
    Exec=$out/bin/dwm-run
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
  nativeBuildInputs = with pkgs; [ pkg-config ncurses ];
  buildInputs = with pkgs; [
    libx11
    libxft
    libxrender
    libxext
    freetype
    fontconfig
    imlib2
    zlib
  ];
  installFlags = [ "DESTDIR=$(out)" "PREFIX=" ];
  makeFlags = [ "CC:=$(CC)" ];
  preInstall = ''
    mkdir -p $out/share/terminfo
    export TERMINFO=$out/share/terminfo
  '';
};

    dwmblocks-custom = pkgs.stdenv.mkDerivation rec {
  pname = "dwmblocks-custom";
  version = "master";
  src = ../../../pkgs/dwmblocks-src;
  nativeBuildInputs = with pkgs; [ pkg-config ];
  buildInputs = with pkgs; [
    libx11
    xcbutil   # provides xcb-atom.pc / xcb-aux.pc / xcb-event.pc, pulls in libxcb too
  ];
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
  services.dbus.enable = true;

  environment.systemPackages = [
    dwm-custom
    st-custom
    dwmblocks-custom
  ];

  environment.variables.TERMINFO_DIRS = "${pkgs.ncurses}/share/terminfo:${st-custom}/share/terminfo";
}
