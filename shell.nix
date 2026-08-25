# shell.nix — development environment for SockOS

{ pkgs ? import <nixpkgs> { } }:

let
  crossPkgs = pkgs.pkgsCross.x86_64-embedded;
  crossTools = [
    crossPkgs.buildPackages.gcc
    crossPkgs.buildPackages.binutils

  ];
in
pkgs.mkShell {
  name = "sockos-dev";

  nativeBuildInputs = crossTools ++ (with pkgs; [
    gnumake
    nasm
    xorriso
    mtools
    qemu
    gdb
    file
  ]);

  hardeningDisable = [ "all" ];

}
