{
  description = "Tokenizers";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    naersk.url = "github:nix-community/naersk";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, naersk, ... }:
    let systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
        forAllSystems = f: builtins.listToAttrs (map (name: { inherit name; value = f name; }) systems);
        overlay = final: prev: {
          tokenizersPackages = import ./nix/rust.nix {
            pkgs = final.pkgs;
            stdenv = final.pkgs.stdenv;
          };
        };
    in {
      packages = forAllSystems (system:
        let pkgs = import nixpkgs {
              overlays = [
                overlay
                naersk.overlay
              ];
              inherit system;
            };
        in {
          tokenizers = pkgs.tokenizersPackages.tokenizers;
          tokenizers-haskell = pkgs.tokenizersPackages.tokenizers-haskell;
        }
      );
      overlays.default = overlay;
      defaultPackage = forAllSystems (system: self.packages.${system}.tokenizers-haskell);
#      lib = pkgs;
    };
}
