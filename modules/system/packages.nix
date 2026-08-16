{ pkgs, inputs, ... }:
{
  systemPackages = with pkgs; [
    wget
    git
    swaybg
    playerctl
    wl-clipboard
    libmtp
    android-tools
    tree
    appimage-run
    p7zip
    parallel
    unrar
    thunar
  ];
  userPackages = with pkgs; [
    localsend
    # inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.spotiflac
    inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default
    inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.ab-download-manager
    # inputs.prismlauncher-cracked.packages.${pkgs.stdenv.hostPlatform.system}.default
    btop
    mpc
    grim
    slurp
    heroic
    alacritty
    scrot
    xclip
    flac
    redshift
    opustags
    wlsunset
    hyprsunset
    xwallpaper
    picom
    docker-compose
    lazydocker
    picard
    android-file-transfer
    qbittorrent
    telegram-desktop
    vlc
    mcomix
    jdk
    opus-tools
  ];
  nixLdLibraries = with pkgs; [
    stdenv.cc.cc
    zlib
    fuse3
    icu
    nss
    openssl
    curl
    expat
  ];
}
