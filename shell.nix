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

  # Ensure upstream nix can fetch Determinate Nix from cache during first build.
  # After the first successful switch, nix-darwin manages /etc/nix/nix.conf.
  bootstrapDeterminateNix = ''
    if ! nix --version 2>/dev/null | grep -q 'Determinate'; then
      NEEDS_RESTART=false
      if ! grep -q 'install.determinate.systems' /etc/nix/nix.conf 2>/dev/null; then
        echo >&2 "Adding Determinate Nix substituter to /etc/nix/nix.conf..."
        sudo mkdir -p /etc/nix
        echo 'extra-substituters = https://install.determinate.systems' | sudo tee -a /etc/nix/nix.conf >/dev/null
        echo 'extra-trusted-public-keys = cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM=' | sudo tee -a /etc/nix/nix.conf >/dev/null
        NEEDS_RESTART=true
      fi
      if ! grep -q 'experimental-features' /etc/nix/nix.conf 2>/dev/null; then
        echo >&2 "Adding experimental-features to /etc/nix/nix.conf..."
        echo 'experimental-features = nix-command flakes' | sudo tee -a /etc/nix/nix.conf >/dev/null
        NEEDS_RESTART=true
      fi
      if [ "$NEEDS_RESTART" = true ]; then
        sudo launchctl kickstart -k system/org.nixos.nix-daemon
        sleep 2
      fi
    fi
  '';

  darwinBuild = ''
    CONFIG=''${1?"Config name is required"}
    ${pkgs.nix}/bin/nix build ".#darwinConfigurations.''${CONFIG}.system" \
      --experimental-features "flakes nix-command" --show-trace
  '';

  darwinInstall = pkgs.writeShellScriptBin "darwinInstall" ''
    ${systemSetup}
    ${bootstrapDeterminateNix}
    ${darwinBuild}
    CONFIG=''${1?"Config name is required"}
    sudo ./result/sw/bin/darwin-rebuild switch --flake ".#''${CONFIG}"
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
