{ config, pkgs, ... }:
{
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  home.shellAliases = {
    vi = "nvim";
    vim = "nvim";
  };

  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/modules/home/editor/nvim";

  home.packages = with pkgs; [
    neovim
    tree-sitter
    unzip
    cargo
    rustc
    ripgrep
    fd
    # mason needs these to install LSPs
    gcc
    gnumake
    nodejs
  ];
}
