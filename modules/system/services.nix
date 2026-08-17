{ pkgs, ... }:
{
  services.gvfs.enable = true;
  services.printing.enable = true;
  services.openssh.enable = true;
  services.displayManager.sessionPackages = [ pkgs.hyprland ];
  services.displayManager.ly.enable = true;
  # virtualisation.docker.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 53317 ];
    allowedUDPPorts = [ 53317 ];
  };
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    jack.enable = true;
    wireplumber.extraConfig = {
      "10-default-profile" = {
        "monitor.alsa.rules" = [
          {
            matches = [ { "device.name" = "alsa_card.pci-0000_00_1f.3"; } ];
            actions = {
              update-props = {
                "api.acp.auto-profile" = true;
                "api.acp.auto-port" = true;
              };
            };
          }
        ];
      };
    };
  };
  programs.appimage = {
    enable = true;
    binfmt = true;
  };
  programs.fish.enable = true;
  programs.dconf.enable = true;
  programs.firefox.enable = true;
  programs.xwayland.enable = true;

  nixpkgs.overlays = [
    (final: prev: {
      openldap = prev.openldap.overrideAttrs (_: {
        doCheck = false;
      });
    })
  ];
}
