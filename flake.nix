{
  description = "wolk's nixos config";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    xlibre-overlay = {
      url = "git+https://codeberg.org/takagemacoed/xlibre-overlay?ref=dev-for-26.05";
    };
    # prismlauncher-cracked.url = "github:Diegiwg/PrismLauncher-Cracked";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    # mangowm = {
    #   url = "github:mangowm/mango";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    ab-download-manager-src = {
      url = "https://github.com/amir1376/ab-download-manager/releases/download/v1.8.7/ABDownloadManager_1.8.7_linux_x64.tar.gz";
      flake = false;
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ab-download-manager-src,
      # prismlauncher-cracked,
      # mangowm,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system} = {
        ab-download-manager = pkgs.callPackage ./pkgs/ab-download-manager.nix {
          srcOverride = ab-download-manager-src;
        };
        default = self.packages.${system}.ab-download-manager;
      };
      nixosConfigurations.nixos-btw = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          { nixpkgs.hostPlatform = system; }
          ./hosts/nixos-btw
          home-manager.nixosModules.home-manager
          # mangowm.nixosModules.mango
          {
            home-manager = {
              extraSpecialArgs = { inherit inputs; };
              useGlobalPkgs = true;
              useUserPackages = true;
              users.wolk = import ./home.nix;
              backupFileExtension = "backup";
            };
          }
        ];
      };
    };
}
