{...}: {
  home.file.".config/rofi/config-wallpaper.rasi".text = ''
    @import "~/.config/rofi/config.rasi"

    * {
    	background-color: transparent;
    	text-color:       white;
    }

    window {
    	fullscreen:       true;
    	padding:          4em;
    	children:         [ wrap, listview-split];
    	spacing:          1em;
    }

    icon-current-entry {
      expand:          true;
      size:            80%;
    }

    listview-split {
      orientation: horizontal;
      spacing: 0.4em;
      children: [listview, icon-current-entry];
    }

    wrap {
    	expand: false;
    	orientation: vertical;
    	children: [ inputbar, message ];
    	border-radius: 0.4em;
    }

    icon-ib {
    	expand: false;
    	filename: "system-search";
    	vertical-align: 0.5;
    	horizontal-align: 0.5;
    	size: 1em;
    }

    inputbar {
    	spacing: 0.4em;
    	padding: 0.4em;
    	children: [ icon-ib, entry ];
    }

    entry {
    	placeholder: "Search";
    	placeholder-color: grey;
    }

    message {
    	padding: 0.4em;
    	spacing: 0.4em;
    }

    listview {
    	flow: horizontal;
    	fixed-columns: true;
    	columns: 7;
    	lines: 5;
    	spacing: 1.0em;
      columns: 4;
    }

    element {
    	orientation: vertical;
    	padding: 0.1em;
      children: [element-icon, element-text ];
    }

    element-icon {
    	size: calc(((100% - 8em) / 5 ));
    	horizontal-align: 0.5;
    	vertical-align: 0.5;
    }

    element-text {
    	horizontal-align: 0.5;
    	vertical-align: 0.5;
      padding: 0.2em;
    }
  '';
}
