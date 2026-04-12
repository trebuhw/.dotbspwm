{ config, pkgs, ... }:

{
  imports =
    [ # Dołącz wyniki hardware-configuration.nix
      ./hardware-configuration.nix
    ];

  # =========================================================
  # Bootloader
  # =========================================================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # =========================================================
  # Sieć
  # =========================================================
  networking.hostName = "archos"; # zmień wg potrzeb
  networking.networkmanager.enable = true;

  # =========================================================
  # Lokalizacja i strefa czasowa
  # =========================================================
  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "pl_PL.UTF-8";
  console = {
    font   = "Lat2-Terminus16";
    keyMap = "pl";
  };

  # =========================================================
  # X11 / bspwm
  # =========================================================
  services.xserver = {
    enable = true;

    # Układ klawiatury
    xkb.layout  = "pl";
    xkb.variant = "";

    # bspwm jako window manager
    windowManager.bspwm.enable = true;

    # Wyłącz domyślny desktop manager (używamy SDDM)
    desktopManager.xterm.enable = false;
  };

  # =========================================================
  # SDDM – display manager
  # =========================================================
  services.displayManager.sddm = {
    enable    = true;
    wayland.enable = false; # bspwm działa na X11
    # Jeśli chcesz użyć własnego motywu simple-sddm:
    # theme = "simple-sddm";
    # (motyw musisz dostarczyć przez extraPackages lub overlay)
  };

  # =========================================================
  # Dźwięk – PipeWire (zastępuje PulseAudio)
  # =========================================================
  security.rtkit.enable = true;
  services.pipewire = {
    enable            = true;
    alsa.enable       = true;
    alsa.support32Bit = true;
    pulse.enable      = true; # kompatybilność z pulsemixer
  };

  # =========================================================
  # TLP – zarządzanie energią (laptopy)
  # =========================================================
  services.tlp = {
    enable = true;
    # Tutaj możesz wkleić zawartość swojego tlp.conf jako atrybuty NixOS:
    # settings = {
    #   CPU_SCALING_GOVERNOR_ON_AC  = "performance";
    #   CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    # };
  };

  # =========================================================
  # Czujniki temperatury
  # =========================================================
  hardware.sensor.iio.enable = true; # dla nowszych układów
  # lm_sensors – aktywowane przez nixos-generate-config lub ręcznie:
  # hardware.cpu.intel.updateMicrocode = true;

  # =========================================================
  # Użytkownik — ZMIEŃ "archos" na swój login
  # =========================================================
  users.users.archos = {
    isNormalUser = true;
    description  = "Archos";
    extraGroups  = [ "networkmanager" "wheel" "audio" "video" ];
    shell        = pkgs.fish;  # domyślna powłoka = fish
  };

  # =========================================================
  # Fish shell (wymagane, gdy shell = pkgs.fish)
  # =========================================================
  programs.fish.enable = true;

  # =========================================================
  # Pakiety systemowe
  # Odpowiedniki paczek z pacman / AUR
  # =========================================================
  environment.systemPackages = with pkgs; [

    # ----- terminale / shell -----
    ghostty
    fish
    tmux
    starship

    # ----- edytory -----
    neovim
    vim
    geany
    # geany-plugins -- dostępne jako osobna paczka:
    geany-with-vte  # lub użyj: (pkgs.geany.override { ... })

    # ----- przeglądarka / WWW -----
    firefox
    chromium

    # ----- WM / compositor / bar -----
    bspwm
    sxhkd
    picom
    polybar
    rofi
    dunst
    feh
    nsxiv

    # ----- pliki / menedżer -----
    thunar
    xfce.thunar-archive-plugin
    xfce.thunar-volman
    gvfs
    tumbler
    xarchiver
    trash-cli
    tree
    yazi

    # ----- narzędzia systemowe -----
    bat
    btop
    eza
    fastfetch
    lm_sensors
    numlockx
    pulsemixer
    zoxide
    stow
    unzip
    xclip
    xdg-user-dirs

    # ----- PDF / dokumenty -----
    zathura

    # ----- czcionki / GTK -----
    nwg-look

    # ----- Qt (wymagane przez SDDM) -----
    qt5.qtquickcontrols2
    qt5.qtgraphicaleffects
    qt5.qtsvg

    # ----- X utilities -----
    xorg.xrandr
    xorg.xsetroot

    # ----- git / AUR (na NixOS używasz nix flakes / home-manager zamiast yay) -----
    git

    # ----- inne -----
    tlp          # CLI tlp
  ];

  # =========================================================
  # XDG user dirs (uruchamiane przy logowaniu)
  # =========================================================
  # xdg-user-dirs-update jest wbudowane w pakiet xdg-user-dirs;
  # NixOS uruchomi to automatycznie przez pam/env.

  # =========================================================
  # Czcionki
  # =========================================================
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" ]; })
    ];
    fontconfig.defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" ];
      sansSerif = [ "Noto Sans" ];
      serif     = [ "Noto Serif" ];
    };
  };

  # =========================================================
  # Dotfiles – uwaga dla NixOS
  # =========================================================
  # Na NixOS zaleca się Home Manager zamiast GNU Stow.
  # Jeśli chcesz nadal używać stow, uruchom go ręcznie po
  # zalogowaniu lub dodaj aktywację przez systemd user service.
  #
  # Przykład z Home Manager (osobny plik home.nix):
  #   home-manager.users.archos = import ./home.nix;

  # =========================================================
  # Zmienne środowiskowe (opcjonalne)
  # =========================================================
  environment.sessionVariables = {
    EDITOR  = "nvim";
    BROWSER = "firefox";
    TERM    = "ghostty";
  };

  # =========================================================
  # Wersja stanu konfiguracji NixOS – NIE ZMIENIAJ
  # =========================================================
  system.stateVersion = "24.11"; # dostosuj do swojej instalacji
}
