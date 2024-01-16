{ buildPythonPackages, dbus-python, pygobject3 }:

buildPythonPackage rec {
  pname = "spotify-notifix";
  version = "0;1";
  src = ./src;

  propagatedBuildInputs = [
    dbus-python
    pygobject3
  ];
};
