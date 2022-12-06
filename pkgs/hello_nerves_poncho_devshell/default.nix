{pkgs}:
with pkgs; let
  erlang = erlangR25;
  elixir = (beam.packagesWith erlang).elixir_1_13;

  my-python = python39;

  python-with-my-packages = my-python.withPackages (p:
    with p; [
      numpy
      # other python packages you want
    ]);

  buildPackages = [
    elixir
    erlang

    autoconf
    automake
    bc
    cmake
    curl
    fwup
    gcc
    git
    m4
    ncurses5.dev
    nodejs
    openssl
    pkg-config
    python-with-my-packages
    python38
    rebar3
    squashfsTools
    unzip
    x11_ssh_askpass
    xz
    zstd
  ];

  devPackages = [
    nixpkgs-fmt
    fswatch
  ];
  #wxGTK28 has reached end of life on linux
  buildInputs =
    buildPackages
    ++ devPackages
    ++ lib.optionals stdenv.isLinux [inotify-tools wxGTK31] 
    ++ lib.optionals stdenv.isDarwin
    (with darwin.apple_sdk.frameworks; [CoreFoundation CoreServices wxmac]);
in
  mkShell {
    name = "nervesShell";

    inherit buildInputs;

    shellHooks = ''
      SUDO_ASKPASS=${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass
      mkdir -p .nix-mix
      mkdir -p .nix-hex
      export MIX_HOME=$PWD/.nix-mix
      export HEX_HOME=$PWD/.nix-hex
      export PATH=$MIX_HOME/bin:$PATH
      export PATH=$HEX_HOME/bin:$PATH
    '';
  }
