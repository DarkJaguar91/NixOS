_:

{
  xdg.configFile."mango/config.conf".text = ''
    # More options: https://github.com/DreamMaoMao/mango/wiki/

    # Autostart
    exec=noctalia-shell

    # Window effect (configured for Noctalia shell integration)
    # Mango handles blur/shadows; Noctalia's own shadow rendering is disabled
    blur=1
    blur_layer=1
    blur_optimized=0
    blur_params_num_passes=2
    blur_params_radius=5
    blur_params_noise=0.02
    blur_params_brightness=0.9
    blur_params_contrast=0.9
    blur_params_saturation=1.0

    shadows=1
    layer_shadows=1
    shadow_only_floating=1
    shadows_size=12
    shadows_blur=15
    shadows_position_x=2
    shadows_position_y=2
    shadowscolor=0x000000ff

    border_radius=6
    no_radius_when_single=0
    focused_opacity=1.0
    unfocused_opacity=1.0
    layer_animations=0

    # Animation Configuration (support type: zoom, slide)
    # tag_animation_direction: 1-horizontal, 0-vertical
    animations=1
    animation_type_open=slide
    animation_type_close=slide
    animation_fade_in=1
    animation_fade_out=1
    tag_animation_direction=1
    zoom_initial_ratio=0.4
    zoom_end_ratio=0.8
    fadein_begin_opacity=0.5
    fadeout_begin_opacity=0.8
    animation_duration_move=500
    animation_duration_open=400
    animation_duration_tag=350
    animation_duration_close=800
    animation_duration_focus=0
    animation_curve_open=0.46,1.0,0.29,1
    animation_curve_move=0.46,1.0,0.29,1
    animation_curve_tag=0.46,1.0,0.29,1
    animation_curve_close=0.08,0.92,0,1
    animation_curve_focus=0.46,1.0,0.29,1
    animation_curve_opafadeout=0.5,0.5,0.5,0.5
    animation_curve_opafadein=0.46,1.0,0.29,1

    # Scroller Layout
    scroller_structs=20
    scroller_default_proportion=0.8
    scroller_focus_center=0
    scroller_prefer_center=0
    edge_scroller_pointer_focus=1
    scroller_default_proportion_single=1.0
    scroller_proportion_preset=0.5,0.8,1.0

    # Master-Stack Layout
    new_is_master=1
    default_mfact=0.55
    default_nmaster=1
    smartgaps=0

    # Overview
    hotarea_size=10
    enable_hotarea=1
    ov_tab_mode=0
    overviewgappi=5
    overviewgappo=30

    # Misc
    no_border_when_single=0
    axis_bind_apply_timeout=100
    focus_on_activate=1
    idleinhibit_ignore_visible=0
    sloppyfocus=1
    warpcursor=1
    focus_cross_monitor=0
    focus_cross_tag=0
    enable_floating_snap=0
    snap_distance=30
    cursor_size=24
    drag_tile_to_tile=1

    # Keyboard
    repeat_rate=25
    repeat_delay=600
    numlockon=0
    xkb_rules_layout=us

    # Trackpad (requires relogin to apply)
    disable_trackpad=0
    tap_to_click=1
    tap_and_drag=1
    drag_lock=1
    trackpad_natural_scrolling=0
    disable_while_typing=1
    left_handed=0
    middle_button_emulation=0
    swipe_min_threshold=1

    # Mouse (requires relogin to apply)
    mouse_natural_scrolling=0

    # Appearance
    gappih=5
    gappiv=5
    gappoh=10
    gappov=10
    scratchpad_width_ratio=0.8
    scratchpad_height_ratio=0.9
    borderpx=4
    rootcolor=0x201b14ff
    bordercolor=0x444444ff
    focuscolor=0xc9b890ff
    maximizescreencolor=0x89aa61ff
    urgentcolor=0xad401fff
    scratchpadcolor=0x516c93ff
    globalcolor=0xb153a7ff
    overlaycolor=0x14a57cff

    # Tag layouts (tile, scroller, grid, deck, monocle, center_tile, vertical_tile, vertical_scroller)
    tagrule=id:1,layout_name:tile
    tagrule=id:2,layout_name:tile
    tagrule=id:3,layout_name:tile
    tagrule=id:4,layout_name:tile
    tagrule=id:5,layout_name:tile
    tagrule=id:6,layout_name:tile
    tagrule=id:7,layout_name:tile
    tagrule=id:8,layout_name:tile
    tagrule=id:9,layout_name:tile

    # Key Bindings
    # mod keys: super, ctrl, alt, shift, none

    bind=SUPER,r,reload_config

    # Noctalia shell
    bind=SUPER,space,spawn,noctalia-shell ipc call launcher toggle
    bind=SUPER,s,spawn,noctalia-shell ipc call controlCenter toggle
    bind=SUPER,comma,spawn,noctalia-shell ipc call settings toggle

    # Terminal
    bind=Alt,Return,spawn,kitty

    # Exit / close
    bind=SUPER,m,quit
    bind=ALT,q,killclient,

    # Focus
    bind=SUPER,Tab,focusstack,next
    bind=ALT,Left,focusdir,left
    bind=ALT,Right,focusdir,right
    bind=ALT,Up,focusdir,up
    bind=ALT,Down,focusdir,down
    bind=ALT,h,focusdir,left
    bind=ALT,l,focusdir,right
    bind=ALT,k,focusdir,up
    bind=ALT,j,focusdir,down

    # Swap
    bind=SUPER+SHIFT,Up,exchange_client,up
    bind=SUPER+SHIFT,Down,exchange_client,down
    bind=SUPER+SHIFT,Left,exchange_client,left
    bind=SUPER+SHIFT,Right,exchange_client,right
    bind=SUPER+SHIFT,k,exchange_client,up
    bind=SUPER+SHIFT,j,exchange_client,down
    bind=SUPER+SHIFT,h,exchange_client,left
    bind=SUPER+SHIFT,l,exchange_client,right

    # Window state
    bind=SUPER,g,toggleglobal,
    bind=ALT,Tab,toggleoverview,
    bind=ALT,backslash,togglefloating,
    bind=ALT,a,togglemaximizescreen,
    bind=ALT,f,togglefullscreen,
    bind=ALT+SHIFT,f,togglefakefullscreen,
    bind=SUPER,i,minimized,
    bind=SUPER,o,toggleoverlay,
    bind=SUPER+SHIFT,I,restore_minimized
    bind=ALT,z,toggle_scratchpad

    # Scroller layout
    bind=ALT,e,set_proportion,1.0
    bind=ALT,x,switch_proportion_preset,

    # Switch layout
    bind=SUPER,n,switch_layout

    # Tag navigation
    bind=SUPER,Left,viewtoleft,0
    bind=CTRL,Left,viewtoleft_have_client,0
    bind=SUPER,Right,viewtoright,0
    bind=CTRL,Right,viewtoright_have_client,0
    bind=CTRL+SUPER,Left,tagtoleft,0
    bind=CTRL+SUPER,Right,tagtoright,0
    bind=SUPER,h,viewtoleft,0
    bind=CTRL,h,viewtoleft_have_client,0
    bind=SUPER,l,viewtoright,0
    bind=CTRL,l,viewtoright_have_client,0
    bind=CTRL+SUPER,h,tagtoleft,0
    bind=CTRL+SUPER,l,tagtoright,0

    bind=Ctrl,1,view,1,0
    bind=Ctrl,2,view,2,0
    bind=Ctrl,3,view,3,0
    bind=Ctrl,4,view,4,0
    bind=Ctrl,5,view,5,0
    bind=Ctrl,6,view,6,0
    bind=Ctrl,7,view,7,0
    bind=Ctrl,8,view,8,0
    bind=Ctrl,9,view,9,0

    bind=Alt,1,tag,1,0
    bind=Alt,2,tag,2,0
    bind=Alt,3,tag,3,0
    bind=Alt,4,tag,4,0
    bind=Alt,5,tag,5,0
    bind=Alt,6,tag,6,0
    bind=Alt,7,tag,7,0
    bind=Alt,8,tag,8,0
    bind=Alt,9,tag,9,0

    # Monitor
    bind=alt+shift,Left,focusmon,left
    bind=alt+shift,Right,focusmon,right
    bind=SUPER+Alt,Left,tagmon,left
    bind=SUPER+Alt,Right,tagmon,right
    bind=alt+shift,h,focusmon,left
    bind=alt+shift,l,focusmon,right
    bind=SUPER+Alt,h,tagmon,left
    bind=SUPER+Alt,l,tagmon,right

    # Gaps
    bind=ALT+SHIFT,X,incgaps,1
    bind=ALT+SHIFT,Z,incgaps,-1
    bind=ALT+SHIFT,R,togglegaps

    # Move/resize floating windows
    bind=CTRL+SHIFT,Up,movewin,+0,-50
    bind=CTRL+SHIFT,Down,movewin,+0,+50
    bind=CTRL+SHIFT,Left,movewin,-50,+0
    bind=CTRL+SHIFT,Right,movewin,+50,+0
    bind=CTRL+SHIFT,k,movewin,+0,-50
    bind=CTRL+SHIFT,j,movewin,+0,+50
    bind=CTRL+SHIFT,h,movewin,-50,+0
    bind=CTRL+SHIFT,l,movewin,+50,+0

    bind=CTRL+ALT,Up,resizewin,+0,-50
    bind=CTRL+ALT,Down,resizewin,+0,+50
    bind=CTRL+ALT,Left,resizewin,-50,+0
    bind=CTRL+ALT,Right,resizewin,+50,+0
    bind=CTRL+ALT,k,resizewin,+0,-50
    bind=CTRL+ALT,j,resizewin,+0,+50
    bind=CTRL+ALT,h,resizewin,-50,+0
    bind=CTRL+ALT,l,resizewin,+50,+0

    # Media keys (handled by Noctalia)
    bind=NONE,XF86AudioRaiseVolume,spawn,noctalia-shell ipc call volume increase
    bind=NONE,XF86AudioLowerVolume,spawn,noctalia-shell ipc call volume decrease
    bind=NONE,XF86AudioMute,spawn,noctalia-shell ipc call volume muteOutput
    bind=NONE,XF86MonBrightnessUp,spawn,noctalia-shell ipc call brightness increase
    bind=NONE,XF86MonBrightnessDown,spawn,noctalia-shell ipc call brightness decrease

    # Mouse bindings
    mousebind=SUPER,btn_left,moveresize,curmove
    mousebind=NONE,btn_middle,togglemaximizescreen,0
    mousebind=SUPER,btn_right,moveresize,curresize

    # Axis bindings
    axisbind=SUPER,UP,viewtoleft_have_client
    axisbind=SUPER,DOWN,viewtoright_have_client

    # Layer rules
    layerrule=animation_type_open:zoom,layer_name:noctalia
    layerrule=animation_type_close:zoom,layer_name:noctalia
  '';

  xdg.configFile."noctalia/settings.json".text = builtins.toJSON {
    settingsVersion = 0;
    bar = {
      barType = "simple";
      position = "top";
      monitors = [ ];
      density = "default";
      showOutline = false;
      showCapsule = true;
      capsuleOpacity = 1;
      capsuleColorKey = "none";
      widgetSpacing = 6;
      contentPadding = 2;
      fontScale = 1;
      enableExclusionZoneInset = true;
      backgroundOpacity = 0.93;
      useSeparateOpacity = false;
      marginVertical = 4;
      marginHorizontal = 4;
      frameThickness = 8;
      frameRadius = 12;
      outerCorners = true;
      hideOnOverview = false;
      displayMode = "always_visible";
      autoHideDelay = 500;
      autoShowDelay = 150;
      showOnWorkspaceSwitch = true;
      widgets = {
        left = [
          { id = "Launcher"; }
          { id = "Clock"; }
          { id = "SystemMonitor"; }
          { id = "ActiveWindow"; }
          { id = "MediaMini"; }
        ];
        center = [
          { id = "Workspace"; }
        ];
        right = [
          { id = "Tray"; }
          { id = "NotificationHistory"; }
          { id = "Battery"; }
          { id = "Volume"; }
          { id = "Brightness"; }
          { id = "ControlCenter"; }
        ];
      };
      mouseWheelAction = "none";
      reverseScroll = false;
      mouseWheelWrap = true;
      middleClickAction = "none";
      middleClickFollowMouse = false;
      middleClickCommand = "";
      rightClickAction = "controlCenter";
      rightClickFollowMouse = true;
      rightClickCommand = "";
      screenOverrides = [ ];
    };
    general = {
      avatarImage = "";
      dimmerOpacity = 0.2;
      showScreenCorners = false;
      forceBlackScreenCorners = false;
      scaleRatio = 1;
      radiusRatio = 1;
      iRadiusRatio = 1;
      boxRadiusRatio = 1;
      screenRadiusRatio = 1;
      animationSpeed = 1;
      animationDisabled = false;
      compactLockScreen = false;
      lockScreenAnimations = false;
      lockOnSuspend = true;
      showSessionButtonsOnLockScreen = true;
      showHibernateOnLockScreen = false;
      enableLockScreenMediaControls = false;
      enableShadows = false;
      enableBlurBehind = false;
      shadowDirection = "bottom_right";
      shadowOffsetX = 2;
      shadowOffsetY = 3;
      language = "";
      allowPanelsOnScreenWithoutBar = true;
      showChangelogOnStartup = true;
      telemetryEnabled = false;
      enableLockScreenCountdown = true;
      lockScreenCountdownDuration = 10000;
      autoStartAuth = false;
      allowPasswordWithFprintd = false;
      clockStyle = "custom";
      clockFormat = "hh\\nmm";
      passwordChars = false;
      lockScreenMonitors = [ ];
      lockScreenBlur = 0;
      lockScreenTint = 0;
      keybinds = {
        keyUp = [ "Up" ];
        keyDown = [ "Down" ];
        keyLeft = [ "Left" ];
        keyRight = [ "Right" ];
        keyEnter = [
          "Return"
          "Enter"
        ];
        keyEscape = [ "Esc" ];
        keyRemove = [ "Del" ];
      };
      reverseScroll = false;
      smoothScrollEnabled = true;
    };
    ui = {
      fontDefault = "";
      fontFixed = "";
      fontDefaultScale = 1;
      fontFixedScale = 1;
      tooltipsEnabled = true;
      scrollbarAlwaysVisible = true;
      boxBorderEnabled = false;
      panelBackgroundOpacity = 0.93;
      translucentWidgets = false;
      panelsAttachedToBar = true;
      settingsPanelMode = "attached";
      settingsPanelSideBarCardStyle = false;
    };
    location = {
      name = "";
      weatherEnabled = true;
      weatherShowEffects = true;
      weatherTaliaMascotAlways = false;
      useFahrenheit = false;
      use12hourFormat = false;
      showWeekNumberInCalendar = false;
      showCalendarEvents = true;
      showCalendarWeather = true;
      analogClockInCalendar = false;
      firstDayOfWeek = -1;
      hideWeatherTimezone = false;
      hideWeatherCityName = false;
      autoLocate = true;
    };
    wallpaper = {
      enabled = true;
      overviewEnabled = false;
      directory = "";
      monitorDirectories = [ ];
      enableMultiMonitorDirectories = false;
      showHiddenFiles = false;
      viewMode = "single";
      setWallpaperOnAllMonitors = true;
      linkLightAndDarkWallpapers = true;
      fillMode = "crop";
      fillColor = "#000000";
      useSolidColor = false;
      solidColor = "#1a1a2e";
      automationEnabled = false;
      wallpaperChangeMode = "random";
      randomIntervalSec = 300;
      transitionDuration = 1500;
      transitionType = [
        "fade"
        "disc"
        "stripes"
        "wipe"
        "pixelate"
        "honeycomb"
      ];
      skipStartupTransition = false;
      transitionEdgeSmoothness = 0.05;
      panelPosition = "follow_bar";
      hideWallpaperFilenames = false;
      useOriginalImages = false;
      overviewBlur = 0.4;
      overviewTint = 0.6;
      useWallhaven = false;
      wallhavenQuery = "";
      wallhavenSorting = "relevance";
      wallhavenOrder = "desc";
      wallhavenCategories = "111";
      wallhavenPurity = "100";
      wallhavenRatios = "";
      wallhavenApiKey = "";
      wallhavenResolutionMode = "atleast";
      wallhavenResolutionWidth = "";
      wallhavenResolutionHeight = "";
      sortOrder = "name";
      favorites = [ ];
    };
    appLauncher = {
      enableClipboardHistory = false;
      autoPasteClipboard = false;
      enableClipPreview = true;
      clipboardWrapText = true;
      enableClipboardSmartIcons = true;
      enableClipboardChips = true;
      clipboardWatchTextCommand = "wl-paste --type text --watch cliphist store";
      clipboardWatchImageCommand = "wl-paste --type image --watch cliphist store";
      position = "center";
      pinnedApps = [ ];
      sortByMostUsed = true;
      terminalCommand = "kitty";
      customLaunchPrefixEnabled = false;
      customLaunchPrefix = "";
      viewMode = "list";
      showCategories = true;
      iconMode = "tabler";
      showIconBackground = false;
      enableSettingsSearch = true;
      enableWindowsSearch = true;
      enableSessionSearch = true;
      ignoreMouseInput = false;
      screenshotAnnotationTool = "";
      overviewLayer = false;
      density = "default";
    };
    colorSchemes = {
      useWallpaperColors = false;
      predefinedScheme = "Noctalia (default)";
      darkMode = true;
      schedulingMode = "off";
      manualSunrise = "06:30";
      manualSunset = "18:30";
      generationMethod = "tonal-spot";
      monitorForColors = "";
      syncGsettings = true;
    };
    dock = {
      enabled = true;
      position = "bottom";
      displayMode = "auto_hide";
      dockType = "floating";
      backgroundOpacity = 1;
      floatingRatio = 1;
      size = 1;
      onlySameOutput = true;
      monitors = [ ];
      pinnedApps = [ ];
      colorizeIcons = false;
      showLauncherIcon = false;
      launcherPosition = "end";
      launcherUseDistroLogo = false;
      launcherIcon = "";
      launcherIconColor = "none";
      pinnedStatic = false;
      inactiveIndicators = false;
      groupApps = false;
      groupContextMenuMode = "extended";
      groupClickAction = "cycle";
      groupIndicatorStyle = "dots";
      deadOpacity = 0.6;
      animationSpeed = 1;
      sitOnFrame = false;
      showDockIndicator = false;
      indicatorThickness = 3;
      indicatorColor = "primary";
      indicatorOpacity = 0.6;
    };
    notifications = {
      enabled = true;
      enableMarkdown = false;
      density = "default";
      monitors = [ ];
      location = "top_right";
      overlayLayer = true;
      backgroundOpacity = 1;
      respectExpireTimeout = false;
      lowUrgencyDuration = 3;
      normalUrgencyDuration = 8;
      criticalUrgencyDuration = 15;
      clearDismissed = true;
      saveToHistory = {
        low = true;
        normal = true;
        critical = true;
      };
      sounds = {
        enabled = false;
        volume = 0.5;
        separateSounds = false;
        criticalSoundFile = "";
        normalSoundFile = "";
        lowSoundFile = "";
        excludedApps = "discord,firefox,chrome,chromium,edge";
      };
      enableMediaToast = false;
      enableKeyboardLayoutToast = true;
      enableBatteryToast = true;
    };
    idle = {
      enabled = false;
      screenOffTimeout = 600;
      lockTimeout = 660;
      suspendTimeout = 1800;
      fadeDuration = 5;
      screenOffCommand = "";
      lockCommand = "";
      suspendCommand = "";
      resumeScreenOffCommand = "";
      resumeLockCommand = "";
      resumeSuspendCommand = "";
      customCommands = "[]";
    };
  };
}
