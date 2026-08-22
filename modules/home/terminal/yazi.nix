{ pkgs, ... }:
{
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    shellWrapperName = "y";
    settings = {
      mgr = {
        show_hidden = false;
      };
      opener = {
        edit = [
          {
            run = ''nvim "$@"'';
            block = true;
            desc = "Neovim";
            for = "unix";
          }
        ];
        play = [
          {
            run = ''vlc "$@"'';
            orphan = true;
            desc = "VLC";
            for = "unix";
          }
        ];
        zen-beta = [
          {
            run = ''zen-beta "$@"'';
            orphan = true;
            desc = "zen-beta";
            for = "unix";
          }
        ];
      };
      open = {
        prepend_rules = [
          { mime = "inode/directory"; use = "open"; }
          { mime = "text/*"; use = "edit"; }
          { mime = "application/javascript"; use = "edit"; }
          { mime = "application/json"; use = "edit"; }
          { url = "*.{md,txt,conf,toml,yaml,yml,lua,fish,py,rs}"; use = "edit"; }
          { mime = "audio/*"; use = "play"; }
          { mime = "video/*"; use = "play"; }
          { mime = "*"; use = "zen-beta"; }
        ];
      };
    };
    flavors = {
      gruvbox-dark = ./yazi-flavors/gruvbox;
    };
    theme.flavor = {
      dark = "gruvbox-dark";
      light = "gruvbox-dark";
    };
  };
}
