{ ... }:

{
  imports = [
    ./wm
    ./services.nix # We will create this
    ./users.nix # We will create this
    ./boot.nix # We will create this
    # ./vm.nix
    ./hardware.nix
    ./waydroid.nix
    ./zram.nix
    ./nix.nix
    ./dns.nix
  ];
}
