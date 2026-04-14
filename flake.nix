# /etc/nixos/flake.nix
{
  description = "Ryan's NixOS Flake Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    whisper-dictation.url = "github:jacopone/whisper-dictation";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
    };
  };

  outputs = { self, nixpkgs, home-manager, whisper-dictation, ... }@inputs: {
    nixosConfigurations."ryan-Desktop" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      # 透過 specialArgs 將 inputs 傳遞給其他 nix 檔案
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; }; # 將 inputs 傳遞給 home.nix
          home-manager.users.ryan = import ./home.nix;
        }
      ];
    };
  };
}
