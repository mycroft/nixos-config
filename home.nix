{ config, pkgs, lib, ... }:
let
  username = "mycroft";
  homeDirectory = "/home/${username}";

  lockCommand = "${pkgs.swaylock}/bin/swaylock -f -c 000000";

  lockTrue = {
    Value = true;
    Status = "locked";
  };

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

      libnotify
      swaylock-effects
      wl-clipboard
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
    firefox = {
      enable = true;

      profiles.default = {
        isDefault = true;
        bookmarks = [
          {
            name = "nixos search";
            toolbar = true;
            bookmarks = [
              {
                url = "https://search.nixos.org";
              }
            ];
          }
        ];

        settings = { };
      };

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

          "browser.search.suggest.enabled" = lockFalse;
          "browser.search.suggest.enabled.private" = lockFalse;
          "browser.urllab.showSuggestionsFirst" = lockFalse;
          "browser.urlbar.suggest.searches" = lockFalse;
          "browser.urlbar.suggest.bookmark" = lockFalse;
          "browser.urlbar.suggest.clipboard" = lockFalse;
          "browser.urlbar.suggest.engines" = lockFalse;
          "browser.urlbar.suggest.history" = lockTrue;
          "browser.urlbar.suggest.openpage" = lockFalse;
          "browser.urlbar.suggest.topsites" = lockFalse;

          # Restore previous session
          "browser.startup.page" = {
            Value = 3;
            Status = "locked";
          };
        };
      };
    };

    go.enable = true;

    vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        golang.go
      ];
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
