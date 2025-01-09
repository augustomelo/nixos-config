{ ... }:
{
  # Create a user with my name
  # Set the defalt shell, home and password
  # https://github.com/mitchellh/nixos-config/blob/main/users/mitchellh/nixos.nix
  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.mutableUsers = false;
  # To generate a hashed password run mkpasswd
  # https://search.nixos.org/options?channel=24.11&show=users.users.%3Cname%3E.hashedPassword&from=0&size=50&sort=relevance&type=packages&query=users.users
  users.users.nix = {
    isNormalUser = true;
    description = "nix";
    extraGroups = [ "networkmanager" "wheel" ];
    packages =  [ ];
  };
}
