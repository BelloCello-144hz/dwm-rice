/* See LICENSE file for copyright and license details. */
/*
 * Nord-themed dwm 6.5 configuration.
 * Requires the patches in ./patches applied in this order:
 *   vanitygaps -> fibonacci -> autostart -> statuscmd
 */

/* Nord palette (https://www.nordtheme.com/docs/colors-and-palettes) */
#define NORD0  "#2E3440" /* polar night: darkest background   */
#define NORD1  "#3B4252" /* polar night: unfocused border     */
#define NORD2  "#434C5E" /* polar night                       */
#define NORD3  "#4C566A" /* polar night: comments / muted     */
#define NORD4  "#D8DEE9" /* snow storm: main text             */
#define NORD6  "#ECEFF4" /* snow storm: brightest text        */
#define NORD8  "#88C0D0" /* frost: selection / focused border */

#define FONT   "JetBrainsMono Nerd Font:size=14"

/* appearance */
static const unsigned int borderpx  = 2;        /* border pixel of windows */
static const unsigned int snap      = 32;       /* snap pixel */
static const unsigned int gappih    = 6;        /* horiz inner gap between windows */
static const unsigned int gappiv    = 6;        /* vert inner gap between windows */
static const unsigned int gappoh    = 6;        /* horiz outer gap between windows and screen edge */
static const unsigned int gappov    = 6;        /* vert outer gap between windows and screen edge */
static const int smartgaps          = 0;        /* 1 means no outer gap when there is only one window */
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */
static const char *fonts[]          = { FONT, "monospace:size=14" };
static const char dmenufont[]       = FONT;
static const char col_bg[]          = NORD0;
static const char col_border[]      = NORD1;
static const char col_fg[]          = NORD4;
static const char col_selfg[]       = NORD0;
static const char col_sel[]         = NORD8;
static const char *colors[][3]      = {
        /*               fg         bg      border     */
        [SchemeNorm] = { col_fg,    col_bg,  col_border },
        [SchemeSel]  = { col_selfg, col_sel, col_sel    },
};

/* tagging */
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };

static const Rule rules[] = {
        /* xprop(1):
         *      WM_CLASS(STRING) = instance, class
         *      WM_NAME(STRING) = title
         */
        /* class            instance    title       tags mask     isfloating   monitor */
        { "Gimp",           NULL,       NULL,       0,            1,           -1 },
        { "Pavucontrol",    NULL,       NULL,       0,            1,           -1 },
        { "Nm-connection-editor", NULL, NULL,       0,            1,           -1 },
        { "firefox",        NULL,       NULL,       1 << 1,       0,           -1 },
};

/* layout(s) */
static const float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 0;    /* 1 means respect size hints in tiled resizals (0 = no stray gaps for terminals) */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */

#include "fibonacci.c"
static const Layout layouts[] = {
        /* symbol     arrange function */
        { "[]=",      tile },    /* first entry is default */
        { "[@]",      spiral },  /* fibonacci spiral */
        { "[\\]",     dwindle }, /* fibonacci dwindle */
        { "[M]",      monocle },
        { "><>",      NULL },    /* no layout function means floating behavior */
};

/* key definitions: Super (Windows key) as modifier */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
        { MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
        { MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
        { MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
        { MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
static const char *dmenucmd[] = { "dmenu_run", "-m", dmenumon, "-fn", dmenufont, "-nb", col_bg, "-nf", col_fg, "-sb", col_sel, "-sf", col_selfg, NULL };
static const char *termcmd[]  = { "kitty", NULL };

/*
 * statuscmd: commands spawned when clicking a block of the status bar.
 * scripts/status.sh prefixes every block with a raw byte \x01, \x02, ...
 * whose value is the id below. The pressed mouse button is exported as $BUTTON.
 *   block 1 = app-menu button (opens dmenu)
 *   block 2 = CPU, block 3 = RAM (open htop in kitty)
 */
#define DMENU_SH "dmenu_run -fn '" FONT "' -nb '" NORD0 "' -nf '" NORD4 "' -sb '" NORD8 "' -sf '" NORD0 "'"
static const StatusCmd statuscmds[] = {
        { DMENU_SH,                1 },
        { "kitty -e htop",         2 },
        { "kitty -e htop -s PERCENT_MEM", 3 },
};
static const char *statuscmd[] = { "/bin/sh", "-c", NULL, NULL };

static const Key keys[] = {
        /* modifier                     key        function        argument */
        { MODKEY,                       XK_d,      spawn,          {.v = dmenucmd } },
        { MODKEY,                       XK_Return, spawn,          {.v = termcmd } },
        { MODKEY,                       XK_b,      togglebar,      {0} },
        { MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
        { MODKEY,                       XK_k,      focusstack,     {.i = -1 } },
        { MODKEY,                       XK_i,      incnmaster,     {.i = +1 } },
        { MODKEY,                       XK_u,      incnmaster,     {.i = -1 } },
        { MODKEY,                       XK_h,      setmfact,       {.f = -0.05} },
        { MODKEY,                       XK_l,      setmfact,       {.f = +0.05} },
        { MODKEY|ShiftMask,             XK_Return, zoom,           {0} },
        { MODKEY,                       XK_Tab,    view,           {0} },
        { MODKEY,                       XK_q,      killclient,     {0} },
        { MODKEY,                       XK_t,      setlayout,      {.v = &layouts[0]} },
        { MODKEY,                       XK_r,      setlayout,      {.v = &layouts[1]} },
        { MODKEY|ShiftMask,             XK_r,      setlayout,      {.v = &layouts[2]} },
        { MODKEY,                       XK_m,      setlayout,      {.v = &layouts[3]} },
        { MODKEY,                       XK_f,      setlayout,      {.v = &layouts[4]} },
        { MODKEY,                       XK_space,  setlayout,      {0} },
        { MODKEY|ShiftMask,             XK_space,  togglefloating, {0} },
        /* vanitygaps */
        { MODKEY,                       XK_g,      togglegaps,     {0} },
        { MODKEY|ShiftMask,             XK_g,      defaultgaps,    {0} },
        { MODKEY,                       XK_equal,  incrgaps,       {.i = +1 } },
        { MODKEY,                       XK_minus,  incrgaps,       {.i = -1 } },
        { MODKEY|ShiftMask,             XK_equal,  incrogaps,      {.i = +1 } },
        { MODKEY|ShiftMask,             XK_minus,  incrogaps,      {.i = -1 } },
        { MODKEY|ControlMask,           XK_equal,  incrigaps,      {.i = +1 } },
        { MODKEY|ControlMask,           XK_minus,  incrigaps,      {.i = -1 } },
        { MODKEY|Mod1Mask,              XK_equal,  incrihgaps,     {.i = +1 } },
        { MODKEY|Mod1Mask,              XK_minus,  incrihgaps,     {.i = -1 } },
        { MODKEY|Mod1Mask|ShiftMask,    XK_equal,  incrivgaps,     {.i = +1 } },
        { MODKEY|Mod1Mask|ShiftMask,    XK_minus,  incrivgaps,     {.i = -1 } },
        { MODKEY|Mod1Mask|ControlMask,  XK_equal,  incrohgaps,     {.i = +1 } },
        { MODKEY|Mod1Mask|ControlMask,  XK_minus,  incrohgaps,     {.i = -1 } },
        { MODKEY|ControlMask|ShiftMask, XK_equal,  incrovgaps,     {.i = +1 } },
        { MODKEY|ControlMask|ShiftMask, XK_minus,  incrovgaps,     {.i = -1 } },
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
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static const Button buttons[] = {
        /* click                event mask      button          function        argument */
        { ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
        { ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[3]} },
        { ClkWinTitle,          0,              Button2,        zoom,           {0} },
        { ClkStatusText,        0,              Button1,        spawn,          {.v = statuscmd } },
        { ClkStatusText,        0,              Button2,        spawn,          {.v = statuscmd } },
        { ClkStatusText,        0,              Button3,        spawn,          {.v = statuscmd } },
        { ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
        { ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
        { ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
        { ClkTagBar,            0,              Button1,        view,           {0} },
        { ClkTagBar,            0,              Button3,        toggleview,     {0} },
        { ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
        { ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};
