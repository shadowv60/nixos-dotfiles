{ config, pkgs, ... }:
let
  # Gruvbox dark palette (hard contrast bg)
  bg0 = "#1d2021"; # hardest background
  bg1 = "#282828"; # main background
  bg2 = "#3c3836"; # selection / hover
  bg3 = "#504945"; # subtle borders
  bg4 = "#665c54"; # lighter borders
  fg1 = "#ebdbb2"; # main text
  fg2 = "#d5c4a1"; # secondary text
  gray = "#928374"; # dim/metadata text
  blue = "#458588"; # accent

  customCss = ''
    /* =========================================================================
     * GRUVBOX DARK - adw-gtk3 palette overrides + GTK3/GTK4 OVERRIDES FOR THUNAR
     * ========================================================================= */
    @define-color theme_bg_color ${bg1};
    @define-color theme_base_color ${bg1};
    @define-color theme_fg_color ${fg1};
    @define-color theme_text_color ${fg1};

    /* libadwaita / adw-gtk3 named colors */
    @define-color window_bg_color ${bg1};
    @define-color window_fg_color ${fg1};
    @define-color view_bg_color ${bg1};
    @define-color view_fg_color ${fg1};
    @define-color headerbar_bg_color ${bg0};
    @define-color headerbar_fg_color ${fg1};
    @define-color headerbar_border_color ${bg3};
    @define-color popover_bg_color ${bg0};
    @define-color popover_fg_color ${fg1};
    @define-color card_bg_color ${bg2};
    @define-color card_fg_color ${fg1};
    @define-color accent_bg_color ${blue};
    @define-color accent_fg_color ${fg1};
    @define-color accent_color ${blue};
    @define-color borders ${bg3};

    window, grid, paned, box {
        background-color: ${bg1};
    }

    /* Main file view */
    ThunarWindow ThunarView,
    ThunarWindow GtkTreeView,
    ThunarWindow ExoIconView,
    ThunarWindow GtkViewport {
        background-color: ${bg1};
        color: ${fg1};
    }

    /* Sidebar */
    ThunarWindow .sidebar,
    ThunarWindow .sidebar GtkTreeView,
    ThunarWindow .sidebar scrolledwindow {
        background-color: ${bg0};
        color: ${fg2};
    }

    /* Selection / hover */
    ThunarWindow GtkTreeView:selected,
    ThunarWindow ExoIconView:selected,
    ThunarWindow .sidebar GtkTreeView:selected,
    .view:selected,
    .view:selected:focus {
        background-color: ${bg3};
        color: ${fg1};
    }
    ThunarWindow GtkTreeView:hover,
    ThunarWindow ExoIconView:hover,
    ThunarWindow .sidebar GtkTreeView:hover {
        background-color: ${bg2};
    }

    /* Path bar / breadcrumbs */
    ThunarWindow GtkToolbar,
    ThunarWindow .path-bar {
        background-color: ${bg1};
        border: none;
        padding: 4px;
    }
    ThunarWindow .path-bar GtkButton {
        background-color: ${bg2};
        color: ${fg2};
        border: 1px solid ${bg3};
        border-radius: 4px;
        padding: 4px 8px;
        margin: 0 2px;
    }
    ThunarWindow .path-bar GtkButton:checked {
        background-color: ${bg3};
        color: ${fg1};
        border-color: ${bg4};
    }
    ThunarWindow .path-bar GtkButton:hover {
        background-color: ${blue};
        color: ${fg1};
    }

    /* Menus */
    menubar, menu, menuitem {
        background-color: ${bg1};
        color: ${fg1};
        padding: 4px;
    }
    menuitem:hover {
        background-color: ${bg3};
    }

    /* Status bar */
    ThunarWindow GtkStatusbar,
    ThunarWindow GtkStatusbar box {
        background-color: ${bg0};
        color: ${gray};
    }

    separator {
        background-color: ${bg3};
    }
  '';
in
{
  gtk = {
    enable = true;

    iconTheme = {
      name = "Gruvbox-Plus-Dark";
      package = pkgs.gruvbox-plus-icons;
    };

    theme = {
      # gruvbox-gtk-theme depended on gtk-engine-murrine, which nixpkgs removed
      # (unmaintained, GTK2-only). adw-gtk3 is a maintained GTK3 theme with no
      # murrine dependency; Gruvbox is applied on top via extraCss below.
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };

    font = {
      # Already installed on the system, so no package needed here.
      name = "JetBrainsMono Nerd Font";
      size = 10;
    };

    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk3.extraCss = customCss;

    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraCss = customCss;
  };
}
