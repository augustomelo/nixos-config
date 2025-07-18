{
  ...
}:
{
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      font-size = 22;
      cursor-style = "block";
      link-url = true;
      mouse-hide-while-typing = true;
      shell-integration-features = "no-cursor";
      theme = "catppuccin-macchiato";
      title = "ghostty";
      window-decoration = false;
    };
  };
}
