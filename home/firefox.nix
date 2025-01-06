{ pkgs, config, nur, ... }:
{
  programs.firefox =
    {
      enable = true;

      languagePacks = [ "en-US" "fr-FR" ];

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

          # TODO: session restore + addons automatic accept + remove all "startup popup"
        };
        extensions = with nur.repos.rycee.firefox-addons; [
          bitwarden
          ublock-origin
          multi-account-containers
          french-dictionary
        ];
      };

    };
}

