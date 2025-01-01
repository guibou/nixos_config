{
  /*
    aws eks update-kubeconfig --region eu-central-1 --profile=nova-staging --name jk-qa --alias jk-qa
    aws eks update-kubeconfig --region eu-central-1 --profile nova-staging --name jk-staging --alias jk-staging
    aws eks update-kubeconfig --region eu-central-1 --profile nova-jinko --name jk-preprod --alias jk-preprod
    aws eks update-kubeconfig --region eu-central-1 --profile nova-jinko --name jk-prod --alias jk-prod

    kubectl config set-context jk-preprod --namespace jinko-preprod
    kubectl config set-context jk-prod --namespace jinko-prod
  */
  programs.awscli = {
    enable = true;
    settings = {
      "nix-daemon" = {
        region = "eu-central-1";
      };

      "default" = {
        region = "eu-central-1";
      };

      "nova-jinko" = {
        region = "eu-central-1";
      };
    };
  };

  programs.firefox.profiles.guillaume = {
    bookmarks = [
      {
        name = "Logs - Prod";
        url = "https://app.datadoghq.eu/logs?query=kube_namespace%3Ajinko-prod%20service%3Awebservice";
      }
      {
        name = "H24 screen";
        url = "https://app.datadoghq.eu/dashboard/pbt-sg7-kgq/h24-screen-any-env?fromUser=false&refresh_mode=sliding";
      }
      {
        name = "Epics";
        url = "https://git.novadiscovery.net/groups/jinko/-/epics/?state=opened&page=1&sort=start_date_desc&author_username=guillaume.bouchard";
      }
      {
        name = "Issue board";
        url = "https://git.novadiscovery.net/groups/jinko/-/boards/10?assignee_username=guillaume.bouchard";
      }
    ];
  };
}
