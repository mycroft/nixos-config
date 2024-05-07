{ pkgs, specialArgs, ... }:
{
  programs.git = {
    enable = true;
    userName = "Patrick Marie";
    userEmail = "pm@mkz.me";
  };
}
