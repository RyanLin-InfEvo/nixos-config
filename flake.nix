# /etc/nixos/flake.nix
{
  description = "Ryan's NixOS Flake Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";

    whisper-dictation.url = "github:jacopone/whisper-dictation";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixpkgs-master, home-manager, whisper-dictation, ... }@inputs: {
    nixosConfigurations."ryan-Desktop" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      # 透過 specialArgs 將 inputs 傳遞給其他 nix 檔案
      specialArgs = {
        inherit inputs;
        unstable = import nixpkgs-unstable {
            system = "x86_64-linux";
            config.allowUnfree = true;
        };
        master = import nixpkgs-master {
            system = "x86_64-linux";
            config.allowUnfree = true;
        };
      };
      modules = [
        ./hosts/ryan-Desktop
      ];
    };

    nixosConfigurations."ryan-dynabook" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = {
        inherit inputs;
        unstable = import nixpkgs-unstable {
            system = "x86_64-linux";
            config.allowUnfree = true;
        };
        master = import nixpkgs-master {
            system = "x86_64-linux";
            config.allowUnfree = true;
        };
      };
      modules = [
        ./hosts/ryan-dynabook
      ];
    };
    homeConfigurations."ryan" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
      extraSpecialArgs = {
        inherit inputs;
        unstable = import nixpkgs-unstable {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        master = import nixpkgs-master {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };
      modules = [ ./home.nix ];
    };
  };
}
