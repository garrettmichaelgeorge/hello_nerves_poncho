{ pkgs ? import <nixpkgs> { } }:

let
  erlang = pkgs.erlangR25;
  elixir = (pkgs.beam.packagesWith erlang).elixir_1_14;

  python = pkgs.python39.withPackages (pythonPkgs: with pythonPkgs; [
    numpy
    # Add other python packages here
  ]);

  buildPackages = [
    elixir
    erlang
    python

    pkgs.autoconf
    pkgs.automake
    pkgs.coreutils-prefixed
    pkgs.bc
    pkgs.cmake
    pkgs.curl
    pkgs.fwup
    pkgs.gcc
    pkgs.git
    pkgs.m4
    pkgs.ncurses5.dev
    pkgs.nodejs
    pkgs.openssl
    pkgs.pkg-config
    pkgs.rebar3
    pkgs.squashfsTools
    pkgs.unzip
    pkgs.x11_ssh_askpass
    pkgs.xz
    pkgs.yarn
    pkgs.zstd
  ];

  devPackages = [
    pkgs.nixpkgs-fmt
    pkgs.fswatch
    pkgs.mosquitto
    pkgs.efm-langserver
    pkgs.rnix-lsp
  ];

  buildInputs = with pkgs;
    buildPackages
    ++ devPackages
    ++ lib.optionals stdenv.isLinux [ inotify-tools wxGTK32 ]
    ++ lib.optionals stdenv.isDarwin
      (with darwin.apple_sdk.frameworks; [ CoreFoundation CoreServices libiconv ]);

in
pkgs.mkShell {
  name = "nerves-shell";

  inherit buildInputs;

  shellHooks = ''
    mkdir -p .nix-mix .nix-hex
    export MIX_HOME=$PWD/.nix-mix
    export HEX_HOME=$PWD/.nix-mix
    export MIX_PATH="${pkgs.beam.packages.erlang.hex}/lib/erlang/lib/hex/ebin"
    export PATH=$MIX_HOME/bin:$HEX_HOME/bin:$PATH

    # SUDO_ASKPASS=${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass

    export LANG=en_US.utf-8
    export ERL_AFLAGS="-kernel shell_history enabled"

    export DYLD_FALLBACK_LIBRARY_PATH=${pkgs.zstd}:$DYLD_FALLBACK_LIBRARY_PATH

    setup() {
      mix local.hex --force
      mix local.rebar --force
      mix archive.install --force hex nerves_bootstrap
    }

    echo 'Try `help` for options'
    help() {
      echo 'Setup new environment: > setup'
      echo '> MIX_TARGET=bbb mix deps.get && mix firmware'
    }
  '';
}
