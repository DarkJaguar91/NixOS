{ lib, modulesPath }:
let
  listNixFiles = path:
    lib.concatLists (
      lib.mapAttrsToList (name: type:
        if type == "directory" then
          listNixFiles (path + "/${name}")
        else if type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix" then
          [ (path + "/${name}") ]
        else
          []
      ) (builtins.readDir path)
    );
in
{
  load = categories:
    lib.concatLists (
      map (cat: listNixFiles (modulesPath + "/${cat}")) categories
    );
}
