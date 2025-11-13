{ config, lib, pkgs, ... }:
{
  launchd.daemons.nix-daemon.command = lib.mkForce (pkgs.writeShellScript "nix-daemon-wrapper" ''
    if [ -f /etc/nix/secrets.env ]; then
      set -a
      source /etc/nix/secrets.env
      set +a
    fi
    exec ${lib.getExe' config.nix.package "nix-daemon"}
  '');
}
