# Spotify D-Bus notification Enhancer

Goofy program to enhance the useless notifications sent by Spotify on Linux.

## Dependencies

## Building

This program is written in the Vala language, which makes interface with DBus
much easier. This project uses Meson to compile the program.

To be able to compile, you need the dependencies listed in the `meson.build`
file, namely:
- `glib-2.0` (base Vala requirement)
- `gobject-2.0` (base Vala requirement)
- `gio-2.0` (DBus interfacing)

Then prepare the meson project:

```sh
meson setup build
```

> [!TIP]
> Use the `--buildtype=release` to build in release mode

Then compile:

```
meson compile -C build
```

### Nix / NixOS

This repo uses Nix flakes and has compatibility for non-flakes systems and
exposes the script as a package as well as a systemd user service via an Home
Manager module.

#### Flakes

Add this repo to your flake inputs and either add import the module or add
the program to your packages.

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
        spotify-notifyx.homeManagerModules.default
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
    spotify-notifix.homeManagerModules.default
  ];

  # Or add package
  home.packages = [
    spotify-notifix.defaultPackage.${pkgs.system}
  ];
}
```

## How does it works?

The programs listens on a D-Bus Session Bus for method calls to
`org.freedesktop.Notifications.Notify`, and only matches notifications which
have the appname "Spotify".

Once a notification is matched, the program will check on Spotify's MPris
instance to get all necessary metadata. It will then edit the matched
notification with better formatting, and resend the call with the same
`replaces_id` parameter, which will flawlessly replace the notification.

## History

This used to be a simple Python script that used the `dbus-python` and
`PyGObject` librairies. But at that time I didn't knew much about how D-Bus
worked and juste copy-pasted code from the Internet.

On top of that due to how poor it was written (and beacause it's Python),
the filter would take too long to process and resend the notification to the
point where you would actually see the notification being edited live.

Since `27c1443c`, this has been rewritten in Vala, because it's a GLib and D-Bus
oriented language that fits much more for this purpose.

## License

This software is licensed under the MIT license.
See the [LICENSE](/LICENSE) file to learn more.
