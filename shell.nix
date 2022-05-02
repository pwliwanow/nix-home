{ pkgs }:
let
  isDarwin = pkgs.stdenvNoCC.isDarwin;
  configuration =
    if isDarwin then
      "$HOME/.config/.nixpkgs/darwin/default.nix"
    else
      "/etc/nixos/configuration.nix";

  systemSetup = ''
    set -e
    echo >&2 "Installing Nix-Darwin..."
    # setup /run directory for darwin system installations
    if ! grep -q '^run\b' /etc/synthetic.conf 2>/dev/null; then
        echo "setting up /etc/synthetic.conf..."
        echo -e "run\tprivate/var/run" | sudo tee -a /etc/synthetic.conf >/dev/null
        /System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -B &>/dev/null \
            || /System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -t &>/dev/null \
            || echo "warning: failed to execute apfs.util"
    fi
    if ! test -L /run; then
        echo "setting up /run..."
        sudo ln -sfn private/var/run /run
    fi
  '';

  darwinBuild = ''
    CONFIG=''${1?"Config name is required"}
    ${pkgs.nix}/bin/nix build ".#darwinConfigurations.''${CONFIG}.system" \
      --experimental-features "flakes nix-command" --show-trace
  '';

  darwinInstall = pkgs.writeShellScriptBin "darwinInstall" ''
    ${systemSetup}
    ${darwinBuild}
    CONFIG=''${1?"Config name is required"}
    ./result/sw/bin/darwin-rebuild switch --flake ".#''${CONFIG}"
  '';

  darwinTest = pkgs.writeShellScriptBin "darwinTest" ''
    ${darwinBuild}
  '';

  homebrewInstall = pkgs.writeShellScriptBin "homebrewInstall" ''
    ${pkgs.bash}/bin/bash -c "$(${pkgs.curl}/bin/curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  '';

in
pkgs.mkShell {
  buildInputs = [ darwinTest darwinInstall homebrewInstall ];
}
