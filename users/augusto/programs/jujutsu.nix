{
  ...
}:
{
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        email = "4723788+augustomelo@users.noreply.github.com";
        name = "Augusto Melo";
      };
      "--scope" = [
        {
          "--when"."commands" = [ "status" ];
          ui.paginate = "never";
        }
        {
          "--when"."commands" = [
            "diff"
            "show"
          ];
          ui = {
            pager = "delta";
            diff-formatter = ":git";
          };
        }
      ];
    };
  };
}
