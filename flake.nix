{
  description = "Qurioisty's configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    proxy-suite = {
      url = "github:FUFSoB/proxy-suite-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    nixcord = {
      url = "github:4evy/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    millennium.url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";
  };

  outputs = inputs@{ nixpkgs, home-manager, millennium, proxy-suite, nixcord, nur, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ nur.overlays.default ];
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations."asuspc" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          { nixpkgs.overlays = [ millennium.overlays.default nur.overlays.default ]; }
          proxy-suite.nixosModules.default
          { imports = builtins.attrValues nur.legacyPackages.${system}.repos.quriosity.nixosModules; }
          ./configuration.nix
          ./modules/proxy-suite.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.quriosity = import ./home.nix;
          }
        ];
      };
    };
}
