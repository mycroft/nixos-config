{ config, pkgs, lib, ... }:
let
  username = "mycroft";
  homeDirectory = "/home/${username}";

  lockCommand = "${pkgs.swaylock}/bin/swaylock -f -c 000000";

  lockFalse = {
    Value = false;
    Status = "locked";
  };

  lockEmpty = {
    Value = "";
    Status = "locked";
  };
in
{
  imports = lib.concatMap import [
    ./modules
  ];

  home = {
    inherit username homeDirectory;

    sessionVariables = {
      XDG_SESSION_TYPE = "wayland";
      XDG_CURRENT_DESKTOP = "sway";
      XKB_DEFAULT_OPTIONS =
        "caps:ctrl_modifier,compose:ralt,grp:win_space_toggle";
    };

    packages = with pkgs; [
      # basic tools
      eza
      bat
      fd
      fzf

      # fish
      fishPlugins.fzf
      fishPlugins.bobthefish

      libnotify
      swaylock-effects
    ];

    # This value determines the home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update home Manager without changing this value. See
    # the home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "23.11";
  };

  programs = {
    alacritty = {
      enable = true;

      settings = {
        colors = {
          bright = {
            black = "0x7f7f7f";
            blue = "0x5c5cff";
            cyan = "0x00ffff";
            green = "0x00ff00";
            magenta = "0xff00ff";
            red = "0xff0000";
            white = "0xffffff";
            yellow = "0xffff00";
          };
          normal = {
            black = "0x000000";
            blue = "0x0d73cc";
            cyan = "0x00cdcd";
            green = "0x00cd00";
            magenta = "0xcd00cd";
            red = "0xcd0000";
            white = "0xe5e5e5";
            yellow = "0xcdcd00";
          };
          primary = {
            background = "0x000000";
            foreground = "0xffffff";
          };
        };
        font = {
          size = 11;
          bold = { style = "Bold"; };
          glyph_offset = {
            x = 0;
            y = 0;
          };
          italic = { style = "Italic"; };
          normal = {
            family = "monospace";
            style = "Regular";
          };
          offset = {
            x = 0;
            y = 0;
          };
        };
        selection = {
          # save_to_clipboard = true;
          semantic_escape_chars = '',│`|:"' ()[]{}<>\t^'';
        };
        window = {
          decorations = "full";
          opacity = 0.9;
        };
      };
    };

    firefox = {
      enable = true;

      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        DontCheckDefaultBrowser = true;
        DisablePocket = true;
        SearchBar = "unified";

        Preferences = {
          # Privacy
          "extensions.pocket.enabled" = lockFalse;
          "browser.newtabpage.pinned" = lockEmpty;
          "browser.topsites.contile.enabled" = lockFalse;
          "browser.newtabpage.activity-stream.showSponsored" = lockFalse;
          "browser.newtabpage.activity-stream.system.showSponsored" = lockFalse;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" =
            lockFalse;
          # Misc
          "ui.key.menuAccessKeyFocuses" = lockFalse;
          "browser.translations.automaticallyPopup" = lockFalse;
          "browser.translations.panelShown" = lockFalse;

          # Restore previous session
          "browser.startup.page" = {
            Value = 3;
            Status = "locked";
          };
        };
      };
    };

    fish = {
      enable = true;

      interactiveShellInit = ''
        # Change fzf behavior
        bind \ct transpose-chars
        bind \cg transpose-words

        # Was \ct, but conflict with bash' transpose-chars
        bind \cf fzf-file-widget
        bind \cr fzf-history-widget

        fish_add_path -p $KREW_ROOT/bin
      '';

      shellInit = ''
        function fish_greeting
          # Remove bobthefish default greetings
        end

        set -g theme_display_date no
        set -g theme_display_cmd_duration no
        set -g theme_display_k8s_context yes
        set -g theme_display_k8s_namespace no
      '';

      shellAbbrs = {
        l = "eza --bytes --git --group --long -snew --group-directories-first";
        ls = "eza";
        ll = "eza --bytes --git --group --long -snew --group-directories-first";
        la = "eza --bytes --git --group --long -snew --group-directories-first -a";
        lt = "eza --bytes --git --group --long -snew --group-directories-first --tree --level=2";
        lta = "eza --bytes --git --group --long -snew --group-directories-first --tree --level=2 -a";
        cat = "bat -p";
        k = "kubectl";
        kns = "kubectl-ns";
        kctx = "kubectl-ctx";
        cd = "z";
        dc = "z";
      };
    };

    # Let home Manager install and manage itself.
    home-manager.enable = true;

    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
  };

  dconf.settings = {
    "org/gnome/desktop/background" = {
      picture-uri-dark =
        "file://${pkgs.nixos-artwork.wallpapers.nineish-dark-gray.src}";
    };
    "org/gnome/desktop/interface" = { color-scheme = "prefer-dark"; };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome.gnome-themes-extra;
    };
  };

  qt.enable = true;
  qt.style = { name = "adwaita-dark"; };

  services.dunst = {
    enable = true;
  };

  services.swayidle = {
    enable = true;
    systemdTarget = "sway-session.target";
    timeouts = [{
      timeout = 1770;
      command = "${pkgs.libnotify}/bin/notify-send 'locking in 30 seconds' -t 30000";
    }
      {
        timeout = 1800;
        command = "${pkgs.systemd}/bin/loginctl lock-session";
      }];
    events = [{
      event = "lock";
      command = lockCommand;
    }];
  };

  systemd.user.services.swayidle.Service = { RestartSec = 5; };

  wayland.windowManager.sway = {
    enable = true;
    config = rec {
      defaultWorkspace = "workspace number 1";

      input."type:keyboard" = {
        xkb_layout = "us";
        xkb_options = "caps:ctrl_modifier,compose:ralt,grp:win_space_toggle";
      };

      keybindings = lib.mkOptionDefault {
        "${modifier}+0" = "workspace number 10";
        "${modifier}+Shift+0" = "move container to workspace number 10";

        "${modifier}+Shift+l" = "exec ${lockCommand}";
        "${modifier}+Shift+r" = "reload";
        "${modifier}+Tab" = "workspace back_and_forth";
      };

      modifier = "Mod1";

      output."*" = {
        bg = "${pkgs.nixos-artwork.wallpapers.nineish-dark-gray.src} fill";
      };

      terminal = "${pkgs.alacritty}/bin/alacritty";
    };
  };
}
