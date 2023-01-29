{ ... }:
{
  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "zap";
      autoUpdate = false;
      upgrade = true;
    };
    global.brewfile = true;
    global.lockfiles = false;

    brews = [
      "gptfdisk"
      "docker-compose"
      "awscurl"
      "doctl"
      "clang-format"
      # "k9s"
      # "awscli"
    ];
    # extraConfig = ''
    #     cask_args appdir: "~/BrewApplications", require_sha: true
    # '';
    casks = [
      "conduktor"
      "multipass"
      # "google-cloud-sdk"
    ];
    taps = [
      "homebrew/cask"
      "conduktor/brew"
    ];
  };
}
