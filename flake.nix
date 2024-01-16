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
    , flake-compat
    , ...
    } @ inputs:
    futils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
        };
        python = pkgs.python3.withPackages (ps: with ps; [
          pygobject3
          dbus-python
        ]);
      in
      {
        formatter = pkgs.nixpkgs-fmt;
        pkgs = {
          spotify-notifix = pkgs.stdenv.mkDerivation {
            name = "spotify-notifix";
            buildInputs = [
              pkgs.gobject-introspection
            ];
            propagatedBuildInputs = [
              python
            ];
            dontUnpack = true;
            installPhase = "install -Dm755 ${./spotify-notifix.py} $out/bin/spotify-notifix";
          };
          default = self.pkgs.${system}.spotify-notifix;
        };
        defaultPackage = self.pkgs.${system}.default;
        devShells = {
          python = pkgs.mkShell rec {
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
}
