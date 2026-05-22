{ pkgs, ... }:
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    theme = "nord";
  };
  xdg.configFile."rofi/gruv.rasi".source = ./rofi-themes/gruv.rasi;
  xdg.configFile."rofi/mono.rasi".source = ./rofi-themes/mono.rasi;
  xdg.configFile."rofi/nord.rasi".source = ./rofi-themes/nord.rasi;
  xdg.configFile."rofi/spirit-tree.rasi".source = ./rofi-themes/spirit-tree.rasi;
}
