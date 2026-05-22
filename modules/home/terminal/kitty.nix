{ ... }:
{
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrains Mono Nerd Font";
      size = 12;
    };
    settings = {
      # Abyss & Steel Theme
      foreground = "#e2e8f0";
      background = "#1a1d24";
      background_opacity = "0.85";

      selection_foreground = "#1a1d24";
      selection_background = "#9db8d2";
      cursor = "#c5d3e8";

      # Terminal Colors
      color0 = "#1a1d24";
      color8 = "#343a47";
      color1 = "#5c677d";
      color9 = "#9db8d2";
      color2 = "#5c677d";
      color10 = "#9db8d2";
      color3 = "#9db8d2";
      color11 = "#c5d3e8";
      color4 = "#343a47";
      color12 = "#5c677d";
      color5 = "#9db8d2";
      color13 = "#c5d3e8";
      color6 = "#9db8d2";
      color14 = "#c5d3e8";
      color7 = "#c5d3e8";
      color15 = "#ffffff";

      # Remote Control
      allow_remote_control = "yes";

      # Performance & Fast Mouse Copying
      copy_on_select = "clipboard"; # Instantly copies on select, but optimized by the settings below
      strip_trailing_spaces = "smart"; # Avoids processing trailing empty spaces, speeding up selection calculations
      select_by_word_characters = "@-./_~?&=%+#"; # Prevents wide, runaway selection lags

      # Screen Refresh Tuning during UI stress
      repaint_delay = "8"; # ~120Hz refresh internal processing (~8ms target)
      input_delay = "1"; # Minimize keyboard/mouse input lag latency down to 1ms
      sync_to_monitor = "no"; # Disables VSync stall blocks if your compositor already handles it (massive speedup on Wayland)
    };
    extraConfig = ''
      # Fallback fonts
      symbol_map U+0B80-U+0BFF Noto Sans Tamil
      symbol_map U+1F600-U+1F64F Noto Color Emoji
    '';
  };
}
