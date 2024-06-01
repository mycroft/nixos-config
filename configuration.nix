# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-c8d6a570-e80f-4d3f-8681-82dc95e00c73".device = "/dev/disk/by-uuid/c8d6a570-e80f-4d3f-8681-82dc95e00c73";
  networking.hostName = "saisei"; # Define your hostname.
  networking.domain = "lan.mkz.me";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.wireless.iwd.enable = true;

  boot.loader.systemd-boot.configurationLimit = 5;
  boot.kernel.sysctl = { "vm.swappiness" = 10; };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd"; #wpa_supplicant";
  # Note: networkmanager is not compatible with wpa_supplicant so using iwd is required here.
  # To add a network, just "nmcli device wifi connect <ssid> password <password>

  # Enable the Flakes feature and the accompanying new nix command-line tool
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Configure keymap in X11
  services.xserver = {
    enable = true;
    xkb = {
      variant = "";
      layout = "us";
    };
    displayManager = {
      gdm = {
        enable = true;
        wayland = true;
        autoSuspend = false;
      };
    };
  };

  services.displayManager = {
    autoLogin = {
      enable = false;
      user = "mycroft";
    };
    defaultSession = "sway";
  };

  fonts = {
    enableDefaultPackages = true;
    fontconfig = {
      enable = true;
      defaultFonts.monospace = [
        # Use `fc-list : family style` to find fonts
        "Hack Nerd Font Mono"
        # "Noto Sans Mono"
        "Noto Color Emoji"
        "Noto Emoji"
      ];
    };
    packages = with pkgs; [
      noto-fonts
      noto-fonts-emoji
      noto-fonts-color-emoji
      noto-fonts-monochrome-emoji

      nerdfonts
    ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mycroft = {
    isNormalUser = true;
    description = "Patrick MARIE";
    extraGroups = [ "networkmanager" "wheel" ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMek8Cn3KNlEeHP2f9vZCbx/hzNc3xzJI9+2FM7Mbx5y mycroft@nee.mkz.me"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIASLd/ou8xDr81AKt37sMTad2jKNyRqF614kdJG829zp mycroft@glitter.mkz.me"
    ];

    shell = pkgs.fish;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    neovim
    wget
    curl
    nixfmt-classic
  ];

  programs.bash.shellAliases = {
    l = "ls -alh";
    ll = "ls -l";
    ls = "ls --color=tty";
  };

  programs.fish = {
    enable = true;
  };

  programs.neovim = {
    enable = true;
    vimAlias = true;
    viAlias = true;

    configure = {
      customRC = ''
        set mouse=
      '';
    };
  };

  programs.ssh.startAgent = true;

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # Set the default editor to vim
  environment.variables.EDITOR = "nvim";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11";

  security.sudo.wheelNeedsPassword = false;
  security.pam.services.su.requireWheel = true;

  systemd.user.services.xdg-desktop-portal-wlr.serviceConfig = {
    RestartSec = 5;
  };
}
