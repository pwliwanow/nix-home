{ ... }:
{
  homebrew = {
    enable = true;
    autoUpdate = false;
    cleanup = "zap";
    global.brewfile = true;
    global.noLock = true;

    brews = [
      "ammonite-repl"
      "awscurl"
      "docker-compose"
      "go"
      "gptfdisk"
      "kafka"
      "npm"
      "postgresql"
      "yarn"
      "zookeeper"
    ];
    # extraConfig = ''
    #     cask_args appdir: "~/BrewApplications", require_sha: true
    # '';
    casks = [
      "conduktor"
      "multipass"
      "google-cloud-sdk"
    ];
    taps = [
      "homebrew/cask"
      "homebrew/services"
      "conduktor/brew"
    ];
  };
}
