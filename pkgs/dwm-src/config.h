/* See LICENSE file for copyright and license details. */
#include <X11/XF86keysym.h>

/* appearance */
static const unsigned int borderpx  = 2;        /* border pixel of windows */
static const unsigned int snap      = 32;       /* snap pixel */
static const unsigned int gappih    = 5;        /* horiz inner gap between windows */
static const unsigned int gappiv    = 5;        /* vert inner gap between windows */
static const unsigned int gappoh    = 5;        /* horiz outer gap between windows and screen edge */
static const unsigned int gappov    = 5;        /* vert outer gap between windows and screen edge */
static const int smartgaps          = 0;        /* 1 means no outer gap when there is only one window */
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */
static const char *fonts[]          = { "JetBrainsMono Nerd Font Mono:size=11" };
static const char dmenufont[]       = "JetBrainsMono Nerd Font Mono:size=11";

/* Theme: Gruvbox Dark */
static const char col_bg[]          = "#282828"; // Gruvbox bg
static const char col_border_norm[] = "#3c3836"; // Gruvbox bg1 (subtle border)
static const char col_fg_norm[]     = "#ebdbb2"; // Gruvbox fg
static const char col_fg_sel[]      = "#fabd2f"; // Gruvbox yellow (active text)
static const char col_border_sel[]  = "#fe8019"; // Gruvbox orange (active border)
static const char *colors[][3]      = {
    /* fg           bg           border   */
    [SchemeNorm] = { col_fg_norm, col_bg,      col_border_norm },
    [SchemeSel]  = { col_fg_sel,  col_bg,      col_border_sel  },
};

/* tagging */
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };

static const Rule rules[] = {
    /* xprop(1):
     * WM_CLASS(STRING) = instance, class
     * WM_NAME(STRING) = title
     */
    /* class      instance    title         tags mask     isfloating   monitor */
    { "Gimp",     NULL,        NULL,         0,            1,           -1 },
    { "Firefox",  NULL,        NULL,         1 << 8,       0,           -1 },
};

/* layout(s) */
static const float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 1;    /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */
static const int refreshrate = 120;  /* refresh rate (per second) for client move/resize */

static const Layout layouts[] = {
    /* symbol     arrange function */
    { "[T]=",      tile },    /* first entry is default */
    { "><>",      NULL },    /* no layout function means floating behavior */
    { "[M]",      monocle },
};

/* Volume & Audio (Pipewire) */
#define VOL_UPDATE "pkill -RTMIN+6 dwmblocks"

static const char *volup[]   = { "/bin/sh", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ && " VOL_UPDATE, NULL };
static const char *voldown[] = { "/bin/sh", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && " VOL_UPDATE, NULL };
static const char *volmute[] = { "/bin/sh", "-c", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && " VOL_UPDATE, NULL };
static const char *playpause[] = { "playerctl", "play-pause", NULL };

/* Apps */
static const char *browser[]     = { "zen-beta", NULL };
static const char *roficmd[]     = { "rofi", "-show", "drun", NULL };
static const char *yazicmd[]     = { "st", "-c", "yazi_term", "-e", "yazi", NULL };
static const char *rmpccmd[]     = { "st", "-c", "rmpc_term", "-e", "rmpc", NULL };
static const char *cavacmd[]     = { "st", "-c", "cava_term", "-e", "cava", NULL };
static const char *nvimcmd[]     = { "st", "-c", "nvim_term", "-e", "nvim", NULL };
static const char *thunarcmd[]   = { "thunar", NULL };

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
    { MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
    { MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
    { MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
    { MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

#define STATUSBAR "dwmblocks"

/* commands */
static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
static const char *dmenucmd[] = { "dmenu_run", "-m", dmenumon, "-fn", dmenufont, "-nb", col_bg, "-nf", col_fg_norm, "-sb", col_border_norm, "-sf", col_fg_sel, "-l", "10", NULL };
static const char *termcmd[]  = { "alacritty", NULL };

static const Key keys[] = {
    /* modifier                     key        function        argument */
    { MODKEY,                       XK_a,      spawn,          {.v = dmenucmd } },
    { MODKEY,                       XK_d,      spawn,          {.v = roficmd } },
    { MODKEY,                       XK_Return, spawn,          {.v = termcmd } },
    { MODKEY,                       XK_r,      togglebar,      {0} },
    { MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
    { MODKEY,                       XK_k,      focusstack,     {.i = -1 } },
    { MODKEY,                       XK_i,      incnmaster,     {.i = +1 } },
    { MODKEY,                       XK_u,      incnmaster,     {.i = -1 } },
    { MODKEY,                       XK_h,      setmfact,       {.f = -0.05} },
    { 0,         XF86XK_AudioRaiseVolume,      spawn,          {.v = volup } },
    { 0,         XF86XK_AudioLowerVolume,      spawn,          {.v = voldown } },
    { 0,                XF86XK_AudioMute,      spawn,          {.v = volmute } },
    { MODKEY,                       XK_p,      spawn,          {.v = playpause } },
    { MODKEY,                       XK_b,      spawn,          {.v = browser } },
    { MODKEY,                       XK_f,      spawn,          {.v = yazicmd } },
    { MODKEY,                       XK_m,      spawn,          {.v = rmpccmd } },
    { MODKEY,                       XK_c,      spawn,          {.v = cavacmd } },
    { MODKEY,                       XK_z,      spawn,          {.v = nvimcmd } },
    { MODKEY,                       XK_e,      spawn,          {.v = thunarcmd } },
    { MODKEY,                       XK_F5,     spawn,          SHCMD("redshift -O 3500") },
    { MODKEY|ShiftMask,             XK_F5,     spawn,          SHCMD("redshift -x") },
    { MODKEY,                       XK_s,      spawn,          SHCMD("scrot ~/Pictures/%Y-%m-%d-%H%M%S_screenshot.png") },
    { MODKEY,                       XK_l,      setmfact,       {.f = +0.05} },
    { MODKEY|Mod4Mask,              XK_h,      incrgaps,       {.i = +1 } },
    { MODKEY|Mod4Mask,              XK_l,      incrgaps,       {.i = -1 } },
    { MODKEY|Mod4Mask|ShiftMask,    XK_h,      incrogaps,      {.i = +1 } },
    { MODKEY|Mod4Mask|ShiftMask,    XK_l,      incrogaps,      {.i = -1 } },
    { MODKEY|Mod4Mask|ControlMask,  XK_h,      incrigaps,      {.i = +1 } },
    { MODKEY|Mod4Mask|ControlMask,  XK_l,      incrigaps,      {.i = -1 } },
    { MODKEY|Mod4Mask,              XK_0,      togglegaps,     {0} },
    { MODKEY|Mod4Mask|ShiftMask,    XK_0,      defaultgaps,    {0} },
    { MODKEY,                       XK_y,      incrihgaps,     {.i = +1 } },
    { MODKEY,                       XK_o,      incrihgaps,     {.i = -1 } },
    { MODKEY|ControlMask,           XK_y,      incrivgaps,     {.i = +1 } },
    { MODKEY|ControlMask,           XK_o,      incrivgaps,     {.i = -1 } },
    { MODKEY|Mod4Mask,              XK_y,      incrohgaps,     {.i = +1 } },
    { MODKEY|Mod4Mask,              XK_o,      incrohgaps,     {.i = -1 } },
    { MODKEY|ShiftMask,             XK_y,      incrovgaps,     {.i = +1 } },
    { MODKEY|ShiftMask,             XK_o,      incrovgaps,     {.i = -1 } },
    { MODKEY|ShiftMask,             XK_Return, zoom,           {0} },
    { MODKEY,                       XK_Tab,    view,           {0} },
    { MODKEY,                       XK_q,      killclient,     {0} },
    { MODKEY,                       XK_t,      setlayout,      {.v = &layouts[0]} },
    { MODKEY|ShiftMask,             XK_f,      setlayout,      {.v = &layouts[1]} },
    { MODKEY,                       XK_g,      setlayout,      {.v = &layouts[2]} },
    { MODKEY,                       XK_space,  setlayout,      {0} },
    { MODKEY|ShiftMask,             XK_space,  togglefloating, {0} },
    { MODKEY,                       XK_0,      view,           {.ui = ~0 } },
    { MODKEY|ShiftMask,             XK_0,      tag,            {.ui = ~0 } },
    { MODKEY,                       XK_comma,  focusmon,       {.i = -1 } },
    { MODKEY,                       XK_period, focusmon,       {.i = +1 } },
    { MODKEY|ShiftMask,             XK_comma,  tagmon,         {.i = -1 } },
    { MODKEY|ShiftMask,             XK_period, tagmon,         {.i = +1 } },
    TAGKEYS(                        XK_1,                      0)
    TAGKEYS(                        XK_2,                      1)
    TAGKEYS(                        XK_3,                      2)
    TAGKEYS(                        XK_4,                      3)
    TAGKEYS(                        XK_5,                      4)
    TAGKEYS(                        XK_6,                      5)
    TAGKEYS(                        XK_7,                      6)
    TAGKEYS(                        XK_8,                      7)
    TAGKEYS(                        XK_9,                      8)
    { MODKEY|ShiftMask,             XK_q,      quit,           {0} },
};

/* button definitions */
static const Button buttons[] = {
    /* click                event mask      button          function        argument */
    { ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
    { ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
    { ClkWinTitle,          0,              Button2,        zoom,           {0} },
    { ClkStatusText,        0,              Button1,        sigstatusbar,   {.i = 1} },
    { ClkStatusText,        0,              Button2,        sigstatusbar,   {.i = 2} },
    { ClkStatusText,        0,              Button3,        sigstatusbar,   {.i = 3} },
    { ClkStatusText,        0,              Button4,        sigstatusbar,   {.i = 4} },
    { ClkStatusText,        0,              Button5,        sigstatusbar,   {.i = 5} },
    { ClkStatusText,        0,              6,              sigstatusbar,   {.i = 6} },
    { ClkStatusText,        0,              7,              sigstatusbar,   {.i = 7} },
    { ClkStatusText,        0,              8,              sigstatusbar,   {.i = 8} },
    { ClkStatusText,        0,              9,              sigstatusbar,   {.i = 9} },
    { ClkClientWin,          MODKEY,         Button1,        movemouse,      {0} },
    { ClkClientWin,          MODKEY,         Button2,        togglefloating, {0} },
    { ClkClientWin,          MODKEY,         Button3,        resizemouse,    {0} },
    { ClkTagBar,            0,              Button1,        view,           {0} },
    { ClkTagBar,            0,              Button3,        toggleview,     {0} },
    { ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
    { ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};
