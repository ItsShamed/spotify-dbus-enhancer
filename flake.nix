{
  description = "Spotify DBus Notification Enhancer";
  inputs = {
    systems.url = "github:nix-systems/default-linux";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    futils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    devenv.url = "github:cachix/devenv";
  };

  outputs =
    { self
    , nixpkgs
    , futils

    , devenv
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
          in
          {
            formatter = pkgs.nixpkgs-fmt;
            apps = {
              spotify-notifix = futils.lib.mkApp {
                drv = self.packages.${system}.spotify-notifix;
              };
              default = self.apps.${system}.spotify-notifix;
            };
            packages = {
              spotify-notifix = pkgs.stdenv.mkDerivation {
                name = "spotify-notifix";
                src = self;
                nativeBuildInputs = with pkgs; [
                  meson
                  ninja
                  pkg-config
                  vala
                ];

                buildInputs = with pkgs; [
                  dbus
                  glib
                  gobject-introspection
                ];

                propagatedBuildInputs = with pkgs; [
                  gobject-introspection
                ];

                meta = with lib; {
                  description = "Daemon that enhance Spotify notifications";
                  homepage = "https://github.com/ItsShamed/spotify-dbus-enhancer";
                  license = licenses.mit;
                  maintainers = [ ];
                  mainProgram = "spotify-notifix";
                  platforms = platforms.unix;
                };
              };
              devenv-up = self.devShells.${system}.default.config.procfileScript;
              devenv-test = self.devShells.${system}.default.config.test;
              default = self.packages.${system}.spotify-notifix;
            };
            defaultPackage = self.packages.${system}.default;
            devShells = {
              vala = devenv.lib.mkShell {
                inherit inputs pkgs;
                modules = [
                  ./devenv.nix
                ];
              };
              default = self.devShells.${system}.vala;
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
