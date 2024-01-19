script_flake:

{ pkgs, ... }:

{
  systemd.user.services.spotify-notifix = {
    Unit = {
      Description = "Spotify D-Bus notification Enhancer";
      StartLimitIntervalSec = 500;
      StartLimitBurst = 5;
    };

    Service = {
      Restart = "on-failure";
      RestartSec = "5s";
      Type = "simple";
      StandardOutput = "journal";
      ExecStart = "${script_flake.defaultPackage.${pkgs.system}}/bin/spotify-notifix";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
