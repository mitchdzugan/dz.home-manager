{
  description = "Home Manager configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zn-nix.url = "github:mitchdzugan/zn.nix";
    zn-nix.inputs.nixpkgs.follows = "nixpkgs";
    # mitch-utils.url = "github:mitchdzugan/mitch-utils.nix";
    mitch-utils.url = "path:/home/dz/Projects/mitch-utils.nix";
    nvim-config.url = "path:/home/dz/Projects/nvim-config";
    nixgl.url = "github:nix-community/nixGL";
    nixgl.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = attrs: { hmModule = ((import ./home.nix) attrs); };
}
