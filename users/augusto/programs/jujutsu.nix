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
      ui.default-command = [ "log" ];
      "--scope" = [
        {
          "--when"."commands" = [
            "log"
            "status"
          ];
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
