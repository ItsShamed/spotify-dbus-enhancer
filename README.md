# Spotify D-Bus notification Enhancer

Goofy script to enhance the useless notifications sent by Spotify on Linux.

Don't exepect this script to work properly tho.

## Dependencies

To be able to run this script, you need the following Python packages:
- dbus-python
- PyGObject

### Arch Linux

On Arch Linux, it is recommended to use `pacman` instead of `pip` to install
Python packages. In which case you can install the dependencies like so:

```console
sudo pacman -S python-gobject dbus-python
```

### Nix / NixOS

This repo uses Nix flakes and has compatibility for non-flakes systems and
exposes the script as a package as well as a systemd user service via an Home
Manager module.

#### Flakes

Add this repo to your flake inputs and either add import the module or add
the script to your packages.

<sub>`flake.nix`</sub>
```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    home-manager.url = "github:nix-community/home-manager/release-23.11";

    spotify-notifyx = {
      url = "github:ItsShamed/spotify-dbus-enhancer/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, spotify-notifyx, ... } @ inputs:
  {
    homeConfigurations.user = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        system = "x86_64-linux"; # or aarch64-linux
      };

      extraSpecialArgs = { inherit inputs; };

      modules = [
        # Add the module or...
        (spotify-notifyx.homeManagerModules.default spotify-notifyx)
      ];
    };
  };
}
```

<sub>`home.nix`</sub>
```nix
{ pkgs, inputs, ... }:

{
  # ... install the package
  home.packages = [
    inputs.spotify-notifyx.defaultPackage.${pkgs.system}
  ];
  # ...
}
```

#### Without Flakes

```nix
{ pkgs, ... }:

let
  spotify-notifix = import (builtins.fetchTarball "https://github.com/ItsShamed/spotify-dbus-enhancer/archive/master.tar.gz");
in
{
  # Import module
  imports = [
    (spotify-notifix.homeManagerModules.default spotify-notifix)
  ];

  # Or add package
  home.packages = [
    spotify-notifix.defaultPackage.${pkgs.system}
  ];
}
```

# License

This software is licensed under the *"Do What The F*ck You Want"* public license.
See the [LICENSE](/license) file to learn more.
