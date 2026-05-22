{ pkgs, ... }:

{
  # Pass 'config' into the home-manager user block
  home-manager.users.wolk =
    { config, ... }:
    {
      programs.waybar = {
        enable = true;
        package = pkgs.waybar;
      };

      # Out-of-store symlinks to allow live-saving changes
      xdg.configFile."waybar".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/modules/system/wm/waybar";
    };
}
