{
  description = "Home Manager configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs";
    nixgl.url = "github:nix-community/nixGL";
    nixgl.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.url = "github:nix-community/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";
    zn-nix.url = "github:mitchdzugan/zn.nix";
    zn-nix.inputs.nixpkgs.follows = "nixpkgs";
    ztr.url = "github:mitchdzugan/ztr";
    ztr.inputs.nixpkgs.follows = "nixpkgs";
    zkg.url = "github:mitchdzugan/zkg";
    zkg.inputs.nixpkgs.follows = "nixpkgs";
    zkm.url = "github:mitchdzugan/zkm";
    zkm.inputs.nixpkgs.follows = "nixpkgs";
    # mitch-utils.url = "path:/home/dz/Projects/mitch-utils.nix";
    # mitch-utils.url = "path:/VOID/proj/mitch-utils.nix";
    mitch-utils.url = "github:mitchdzugan/mitch-utils.nix";
    # nvim-config.url = "path:/home/dz/Projects/nvim-config";
    # nvim-config.url = "path:/VOID/proj/nvim-config";
    nvim-config.url = "github:mitchdzugan/nvim-config";
  };

  outputs = attrs: ({ hmModule = ((import ./home.nix) attrs); } // (
    attrs.flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = attrs.nixpkgs.legacyPackages.${system};
        zn = attrs.zn-nix.mk-zn system;
      in {
        packages.default = zn.writeBashScriptBin "dz-hm" ''
          function echoThis {
            cat << EOF
            {
              username = "dz";
              homeDirectory = "/home/dz";
              stateVersion = "25.11";
              checkouts = {
                dz-home-manager = "/home/dz/Projects/dz.home-manager/";
                dz-nvim-config = "/home/dz/Projects/nvim-config/";
              };
              defaultNixGLWrapper = "mesa";
            }
          EOF
          }

          function echoFlake {
            cat << EOF
            {
              description = "Home Manager configuration";
              inputs = {
                nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
                home-manager.url = "github:nix-community/home-manager";
                home-manager.inputs.nixpkgs.follows = "nixpkgs";
          EOF
            if [[ "$1" != "" ]]; then
              echo 'dz-home-manager.url = "github:mitchdzugan/dz.home-manager";'
            else
              echo "dz-home-manager.url = \"path:$DZ_HOME_MANAGER_CHECKOUT_PATH\";"
            fi
            cat << EOF
                dz-home-manager.inputs.nixpkgs.follows = "nixpkgs";
              };
              outputs = { nixpkgs, home-manager, dz-home-manager, ... }: {
                homeConfigurations."dz" = home-manager.lib.homeManagerConfiguration {
                  pkgs = nixpkgs.legacyPackages.x86_64-linux;
                  modules = [(dz-home-manager.hmModule (import ./this.nix))];
                };
              };
            }
          EOF
          }

          function setThis {
            if [[ -f "$HOME/.config/home-manager/this.nix" ]]; then
              echo "$HOME/.config/home-manager/this.nix already exists" >&2
              echo "  not overwriting" >&2
            else
              echo "creating $HOME/.config/home-manager/this.nix" >&2
              echoThis > "$HOME/.config/home-manager/this.nix"
            fi
          }

          function setFlake {
            echoFlake $1 > "$HOME/.config/home-manager/flake.nix"
          }

          function upAndSwitch {
            nix flake update
            home-manager switch "$@"
          }

          mkdir -p ~/.config/home-manager
          cd ~/.config/home-manager
          if [[ "$1" == "init" ]]; then
            setFlake
            setThis
          elif [[ "$1" == "switch" ]]; then
            setFlake
            upAndSwitch "$@"
          elif [[ "$1" == "switch-using-public" ]]; then
            setFlake no
            upAndSwitch "$@"
          else
            echo "USAGE: dz-hm CMD" >&2
            echo "    CMD: init | switch | switch-using-public" >&2
            exit 1
          fi
        '';
      }
    )
  ));
}
