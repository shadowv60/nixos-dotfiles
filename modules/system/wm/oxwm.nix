{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    oxwm
  ];

  services.xserver.windowManager.session = [
    {
      name = "oxwm";
      start = ''
        oxwm &
        waitPID=$!
      '';
    }
  ];
}
