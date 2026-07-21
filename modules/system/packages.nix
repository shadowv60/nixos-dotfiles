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
    parallel
    zed-editor
    # inputs.self.packages.${pkgs.system}.spotiflac
    unrar
    thunar
  ];
  userPackages = with pkgs; [
    localsend
    inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default
    inputs.self.packages.${pkgs.system}.ab-download-manager
    # inputs.prismlauncher-cracked.packages.${pkgs.system}.default
    btop
    mpc
    grim
    slurp
    heroic
    scrot
    xclip
    redshift
    wlsunset
    hyprsunset
    xwallpaper
    picom
    docker-compose
    lazydocker
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
