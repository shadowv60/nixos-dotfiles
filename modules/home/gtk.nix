{ config, pkgs, ... }:

let
  customCss = ''
    /* =========================================================================
     * ABYSS & STEEL - AGGRESSIVE GTK3/GTK4 RESET FOR THUNAR
     * ========================================================================= */

    /* Global Fallbacks */
    @define-color theme_bg_color #1a1d24;
    @define-color theme_base_color #1a1d24;
    @define-color theme_fg_color #e2e8f0;
    @define-color theme_text_color #e2e8f0;

    /* Force Main Window Frame & Panels */
    window, 
    grid, 
    paned, 
    box {
        background-color: #1a1d24;
    }

    /* --- MAIN FILE VIEW CONTAINER --- */
    ThunarWindow ThunarView,
    ThunarWindow GtkTreeView,
    ThunarWindow ExoIconView,
    ThunarWindow GtkViewport {
        background-color: #1a1d24 !important;
        color: #e2e8f0 !important;
    }

    /* --- SIDEBAR (PLACES / TREE) --- */
    ThunarWindow .sidebar,
    ThunarWindow .sidebar GtkTreeView,
    ThunarWindow .sidebar scrolledwindow {
        background-color: #14161c !important; /* Slightly deeper base for visual hierarchy */
        color: #9db8d2 !important;              /* Steel Blue text */
    }

    /* --- ROW SELECTIONS & HOVERS --- */
    ThunarWindow GtkTreeView:selected,
    ThunarWindow ExoIconView:selected,
    ThunarWindow .sidebar GtkTreeView:selected,
    .view:selected, 
    .view:selected:focus {
        background-color: #343a47 !important; /* Muted Slate block */
        color: #e2e8f0 !important;            /* Crisp white text */
    }

    ThunarWindow GtkTreeView:hover,
    ThunarWindow ExoIconView:hover,
    ThunarWindow .sidebar GtkTreeView:hover {
        background-color: #232730 !important;
    }

    /* --- TOP BREADCRUMBS / PATH BAR --- */
    ThunarWindow GtkToolbar,
    ThunarWindow .path-bar {
        background-color: #1a1d24 !important;
        border: none;
        padding: 4px;
    }

    ThunarWindow .path-bar GtkButton {
        background-color: #232730;
        color: #9db8d2;
        border: 1px solid #343a47;
        border-radius: 4px;
        padding: 4px 8px;
        margin: 0 2px;
    }

    ThunarWindow .path-bar GtkButton:checked {
        background-color: #343a47 !important;
        color: #e2e8f0 !important;
        border-color: #5c677d;
    }

    ThunarWindow .path-bar GtkButton:hover {
        background-color: #2c323e;
        color: #e2e8f0;
    }

    /* --- MENUBAR & TOOLBARS --- */
    menubar, 
    menu, 
    menuitem {
        background-color: #1a1d24 !important;
        color: #e2e8f0 !important;
        padding: 4px;
    }

    menuitem:hover {
        background-color: #343a47 !important;
    }

    /* --- STATUS BAR (BOTTOM) --- */
    ThunarWindow GtkStatusbar,
    ThunarWindow GtkStatusbar box {
        background-color: #14161c !important;
        color: #5c677d !important; /* Dim Blue metadata text */
    }

    /* Clean up borders and lines */
    separator {
        background-color: #343a47 !important;
    }
  '';
in
{
  gtk = {
    enable = true;

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    theme = {
      name = "Arc-Dark";
      package = pkgs.arc-theme;
    };

    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk3.extraCss = customCss;

    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraCss = customCss;
  };
}
