{ pkgs, ... }:
let
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
  programs.firefox = {
    enable = true;

    profiles.default = {
      isDefault = true;
      bookmarks = [
        {
          name = "Nix";
          toolbar = true;
          bookmarks = [
            {
              name = "nixos search";
              url = "https://search.nixos.org";
            }
          ];
        }
      ];

      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        bitwarden
        ublock-origin
      ];

      settings = {
        "app.update.auto" = false;
        "browser.startup.homepage" = "about:blank";
        "browser.startup.blankWindow" = true;
        "browser.newtabpage.enabled" = false;
        "browser.places.importBookmarksHTML" = false;
        "browser.aboutwelcome.enabled" = false;
        "startup.homepage_welcome_url" = "about:blank";
        "trailhead.firstrun.didSeeAboutWelcome" = true;
        "browser.uiCustomization.state" = builtins.toJSON {
          placements = {
            widget-overflow-fixed-list = [ ];
            nav-bar = [
              "back-button"
              "forward-button"
              "stop-reload-button"
              "home-button"
              "urlbar-container"
              "downloads-button"
              "sidebar-button"
              "reset-pbm-toolbar-button"
              "ublock0_raymondhill_net-browser-action"
            ];
            toolbar-menubar = [ "menubar-items" ];
            TabsToolbar = [ "firefox-view-button" "tabbrowser-tabs" "new-tab-button" "alltabs-button" ];
            PersonalToolbar = [ "import-button" "personal-bookmarks" ];
          };
          currentVersion = 21;
        };
      };
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
}
