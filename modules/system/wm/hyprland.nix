{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # Restructured to allow Home Manager's 'config' to be accessed
  home-manager.users.wolk =
    { config, ... }:
    {
      xdg.configFile."hypr".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/modules/system/wm/hypr";
    };
}
