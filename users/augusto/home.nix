{
  pkgs,
  username,
  ...
}: {

  home = {
    homeDirectory = "/home/${username}";
    stateVersion = "24.11";
    username = username;

    packages = with pkgs; [
      home-manager
    ];
  };

  programs = {
    ghostty = {
      enable = true;
    };
  };
}

