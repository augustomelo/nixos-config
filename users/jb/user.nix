{ pkgs, ... }:
{
  programs = {
    git.enable = true;
    bash.shellAliases = {
      la = "ls -la ";
      ll = "ls -l";
      nfu = "nix flake update --flake $HOME/workspace/personal/nixos-config/";
      nrs = "sudo nixos-rebuild switch --flake $HOME/workspace/personal/nixos-config/#";
    };
    ssh.startAgent = true;
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      8080
      9696
    ];
  };

  users = {
    mutableUsers = false;
    users.jb = {
      home = "/home/jb";
      isNormalUser = true;
      shell = pkgs.bash;
      extraGroups = [ "wheel" ];
      hashedPasswordFile = "/etc/nixos/passwd";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEGL2rZ4htp01YDa9Q6iqwcmtpkawn6VdCu25idKDHKm jb@home-server"
      ];
    };
  };
}
