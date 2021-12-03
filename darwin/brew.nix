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
