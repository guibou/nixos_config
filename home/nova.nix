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
}
