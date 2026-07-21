{ config, pkgs, ... }:

{
  home.file = {
    ".local/bin" = {
      source = ../../scripts;
      recursive = true;
    };
  };

  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
  };

  xdg.desktopEntries.ab-download-manager = {
    name = "AB Download Manager";
    exec = "ab-download-manager";
    icon = "ab-download-manager";
    categories = [
      "Network"
      "FileTransfer"
    ];
  };

  gtk = {
    enable = true;
    gtk4.theme = config.gtk.theme;
    cursorTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };
  };
}
