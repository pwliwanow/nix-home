{ ... }:
{
  homebrew = {
    enable = true;
    autoUpdate = false;
    cleanup = "zap";
    global.brewfile = true;
    global.noLock = true;

    brews = [
      "gptfdisk"
      "docker-compose"
      "k9s"
      "colima"
      "k3d"
      "awscurl"
      "doctl"
      # "awscli"
    ];
    # extraConfig = ''
    #     cask_args appdir: "~/BrewApplications", require_sha: true
    # '';
    casks = [
      "conduktor"
      "multipass"
    ];
    taps = [
      "homebrew/cask"
      "conduktor/brew"
    ];
  };
}
