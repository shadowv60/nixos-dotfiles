{ pkgs, ... }:
{
  users.users.wolk = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
      "audio"
      # "docker"
      "kvm"
      "libvirtd"
    ];
    shell = pkgs.fish;
  };
  time.timeZone = "Asia/Kolkata";
  services.xserver.xkb = {
    layout = "us";
    variant = "";
    options = "caps:escape";
  };
  console.useXkbConfig = true;
  fonts.packages = with pkgs; [
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    nerd-fonts.symbols-only
  ];
}
