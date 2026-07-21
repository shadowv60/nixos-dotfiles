{ pkgs, ... }:

{
  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        type = "data";
        source = ''
                       ___   __              
                /¯\    \  \ /  ;             
                \  \    \  v  /              
             /¯¯¯   ¯¯¯¯\\   /  /\           
            ’————————————·\  \ /  ;          
                 /¯¯;      \ //  /_          
           _____/  /        ‘/     \         
           \      /,        /  /¯¯¯¯         
            ¯¯/  // \      /__/              
             .  / \  \·————————————.         
              \/  /   \\_____   ___/         
                 /  ,  \      \  \           
                 \_/ \__\     \_/            
        '';
        padding = {
          top = 1;
          left = 2;
          right = 4;
        };
      };
      display = {
        separator = "";
      };
      modules = [
        { type = "custom"; key = "╭───────────╮"; }
        {
          type = "title";
          key = "│ {#31} User    {#keys}│";
          format = "{user-name}";
        }
        {
          type = "os";
          key = "│ {#34}󱄅 Distro  {#keys}│";
        }
        {
          type = "kernel";
          key = "│ {#35} Kernel  {#keys}│";
        }
        {
          type = "uptime";
          key = "│ {#33}󰅐 Uptime  {#keys}│";
        }
        {
          type = "packages";
          key = "│ {#33}󰚺 Pkgs    {#keys}│";
        }
        {
          type = "shell";
          key = "│ {#32} Shell   {#keys}│";
        }
        {
          type = "wm";
          key = "│ {#36} WM      {#keys}│";
        }
        {
          type = "terminal";
          key = "│ {#31} Terminal{#keys}│";
        }
        {
          type = "cpu";
          key = "│ {#33}󰍛 CPU     {#keys}│";
        }
        {
          type = "memory";
          key = "│ {#36} Memory  {#keys}│";
        }
        {
          type = "disk";
          key = "│ {#32}󰋊 Storage {#keys}│";
        }
        { type = "custom"; key = "├───────────┤"; }
        {
          type = "colors";
          key = "│ {#39} Colors  {#keys}│";
          symbol = "circle";
        }
        { type = "custom"; key = "╰───────────╯"; }
      ];
    };
  };
}
