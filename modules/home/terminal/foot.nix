{ ... }:
{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "JetBrains Mono Nerd Font:size=12";
      };

      colors-dark = {
        alpha = 0.85;
        foreground = "e2e8f0"; # Crisp Light
        background = "1a1d24"; # Deep Base

        regular0 = "1a1d24"; # black
        regular1 = "5c677d"; # red (Dim Blue)
        regular2 = "5c677d"; # green (Dim Blue)
        regular3 = "9db8d2"; # yellow (Steel Blue)
        regular4 = "343a47"; # blue (Muted Slate)
        regular5 = "9db8d2"; # magenta (Steel Blue)
        regular6 = "9db8d2"; # cyan (Steel Blue)
        regular7 = "c5d3e8"; # white (Frost)

        bright0 = "343a47"; # bright black
        bright1 = "9db8d2"; # bright red
        bright2 = "9db8d2"; # bright green
        bright3 = "c5d3e8"; # bright yellow
        bright4 = "5c677d"; # bright blue
        bright5 = "c5d3e8"; # bright magenta
        bright6 = "c5d3e8"; # bright cyan
        bright7 = "ffffff"; # bright white

        selection-foreground = "1a1d24";
        selection-background = "9db8d2";
      };

      tweak = {
        font-monospace-warn = "no";
      };
    };
  };
}
