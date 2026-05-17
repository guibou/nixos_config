{ pkgs, config, nur, ... }:
{
  programs.firefox =
    {
      enable = true;

      languagePacks = [ "en-US" "fr-FR" ];

      # Since home.stateVersion 26.05
      configPath = "${config.xdg.configHome}/mozilla/firefox";

      profiles.guillaume = {
        containersForce = true;
        containers =
          {
            work = {
              color = "orange";
              icon = "briefcase";
              id = 2;
            };
            personal = {
              color = "blue";
              icon = "fingerprint";
              id = 1;
            };
          };

        settings = {
          # Automatically enable extensions
          "autoDisableScopes" = 0;
          "sidebar.verticalTabs" = true;

          # Do not auto save on Download folder
          "browser.download.useDownloadDir" = false;
          "extensions.formautofill.addresses.enabled" = false;
          "extensions.formautofill.creditCards.enabled" = false;
          "signon.rememberSignons" = false;

          "browser.startup.homepage" = "about:blank";
          "browser.urlbar.placeholderName" = "DuckDuckGo";

          # Disable AI things
          # these flags actualy disable the AI features
          # Found there: https://www.reddit.com/r/NixOS/comments/1rkt5ag/reminder_to_declare_the_blocking_of_ai_stuff_in/
          # Note that this list may have to be updated in the future, this is
          # sad that firefox does not provide a master switch
          "browser.ml.chat.enabled" = false;
          "browser.ml.chat.page" = false;
          "browser.ml.linkPreview.enabled" = false;
          "browser.tabs.groups.smart.enabled" = false;
          "browser.tabs.groups.smart.userEnabled" = false;
          "browser.translations.enable" = false;
          "extensions.ml.enabled" = false;
          "pdfjs.enableAltText" = false;

          # these flags change the visual UI on the AI panel
          "browser.ai.control.default" = "blocked";
          "browser.ai.control.linkPreviewKeyPoints" = "blocked";
          "browser.ai.control.pdfjsAltText" = "blocked";
          "browser.ai.control.sidebarChatbot" = "blocked";
          "browser.ai.control.smartTabGroups" = "blocked";
          "browser.ai.control.translations" = "blocked";

          # TODO: session restore + addons automatic accept + remove all "startup popup"
        };
        extensions.packages = with nur.repos.rycee.firefox-addons; [
          bitwarden
          ublock-origin
          multi-account-containers
          french-dictionary
        ];
      };

    };
}

