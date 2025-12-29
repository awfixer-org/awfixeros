{ inputs, system, pkgs, config, lib, snowflake, ... }:

{
  modules.axylos.axylosModuleManager.enable = false;
  modules.axylos.nixosConfEditor.enable = false;
}
