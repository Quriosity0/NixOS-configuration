{
  description = "Home Manager configuration of quriosity";

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
    hush.url = "github:UMCEKO/hush";
  };

  outputs = inputs@{ nixpkgs, home-manager, millennium, proxy-suite, hush, nixcord, nur, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ nur.overlays.default ];
        config.allowUnfree = true;
      };
    in
    {
      homeConfigurations."quriosity" =
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit inputs; };
          modules = [
            ./home.nix
            ./modules
          ];
        };

      nixosConfigurations."asuspc" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          { nixpkgs.overlays = [ millennium.overlays.default nur.overlays.default ]; }
          proxy-suite.nixosModules.default
          ./configuration.nix
          ./modules/proxy-suite.nix
        ];
      };
    };
}
