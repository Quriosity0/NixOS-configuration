{
  description = "Home Manager configuration of quriosity";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/7138b26451e6ccb06b62884ce76edb46e358df75";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";

    millennium.url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";

    zapret-discord-youtube = {
      url = "github:kartavkun/zapret-discord-youtube";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, millennium, zapret-discord-youtube, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
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
          { nixpkgs.overlays = [ millennium.overlays.default ]; }
          zapret-discord-youtube.nixosModules.default
          ./configuration.nix
          ./modules/zapret.nix
        ];
      };
    };
}
