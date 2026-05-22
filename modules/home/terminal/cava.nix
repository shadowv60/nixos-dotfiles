{ ... }:
{
  programs.cava = {
    enable = true;
    settings = {
      general = {
        framerate = 60;
        autosens = 1;
        bar_width = 1;
        sensitivity = 100;
        lower_cutoff_freq = 50;
        higher_cutoff_freq = 10000;
      };

      color = {
        gradient = 1;
        gradient_count = 8;

        # Abyss & Steel Gradient Interpolation
        gradient_color_1 = "'#1a1d24'"; # Deep Base (Bottom of the bars)
        gradient_color_2 = "'#343a47'"; # Muted Slate
        gradient_color_3 = "'#343a47'"; # Muted Slate
        gradient_color_4 = "'#5c677d'"; # Dim Blue
        gradient_color_5 = "'#5c677d'"; # Dim Blue
        gradient_color_6 = "'#9db8d2'"; # Steel Blue (Main visual accent)
        gradient_color_7 = "'#9db8d2'"; # Steel Blue
        gradient_color_8 = "'#c5d3e8'"; # Frost (Peak frequencies)
      };

      input = {
        method = "pipewire";
        source = "auto";
        sample_rate = 44100;
        channels = 2;
        sample_bits = 16;
      };

      output = {
        method = "ncurses";
        orientation = "bottom";
        channels = "stereo";
      };

      smoothing = {
        monstercat = 1;
        waves = 0;
        noise_reduction = 77;
      };
    };
  };
}
