{ pkgs, ... }:
{
  # Create a user with my name
  # Set the defalt shell, home and password
  # https://github.com/mitchellh/nixos-config/blob/main/users/mitchellh/nixos.nix
  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.mutableUsers = false;
  # To generate a hashed password run mkpasswd
  # https://search.nixos.org/options?channel=24.11&show=users.users.%3Cname%3E.hashedPassword&from=0&size=50&sort=relevance&type=packages&query=users.users

  programs.zsh.enable = true;

  users.mutableUsers = false;

  users.users.augusto = {
    home = "/home/augusto";
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" ];
    hashedPassword = "$y$j9T$5qUofB6UibbNyT6gQ7nDX/$QpaTGYmim85ItVepaLalPmtPg1D/A6eFJj6YsCWMQfB";
  };
}
