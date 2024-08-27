{
  description = "Spotify DBus Notification Enhancer";
  inputs = {
    systems.url = "github:nix-systems/default-linux";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    futils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs =
    { self
    , nixpkgs
    , futils
    , ...
    } @ inputs:
    let
      inherit (nixpkgs) lib;
      linuxOuts =
        futils.lib.eachDefaultSystem (system:
          let
            pkgs = import nixpkgs {
              inherit system;
              config = { allowUnfree = true; };
            };
            python = pkgs.python3.withPackages (ps: with ps; [
              pygobject3
              pygobject-stubs
              dbus-python
            ]);
          in
          {
            formatter = pkgs.nixpkgs-fmt;
            packages = {
              spotify-notifix = pkgs.stdenv.mkDerivation {
                name = "spotify-notifix";
                buildInputs = [
                  pkgs.gobject-introspection
                ];
                propagatedBuildInputs = [
                  python
                  pkgs.gobject-introspection
                ];
                dontUnpack = true;
                installPhase = "install -Dm755 ${./spotify-notifix.py} $out/bin/spotify-notifix";
              };
              default = self.packages.${system}.spotify-notifix;
            };
            defaultPackage = self.packages.${system}.default;
            devShells = {
              python = pkgs.mkShell {
                buildInputs = [
                  pkgs.gobject-introspection
                ];
                propagatedBuildInputs = [
                  python
                ];
              };
              default = self.devShells.${system}.python;
            };
          }
        );
      agnosticOuts = {
        homeManagerModules.spotify-dbus-enhancer = import ./hm.nix self;
        homeManagerModules.default = self.homeManagerModules.spotify-dbus-enhancer;
      };
    in
    lib.recursiveUpdate linuxOuts agnosticOuts;
}
