#!/bin/bash

set -e

SRC="src"

usage() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  run           Run Rojo Server"
    echo "  build         Builds the Game"
    echo "  install       Install all Rokit and Wally Packages"
    echo
    echo "Example:"
    echo "  $0 run              Run Rojo Server"
    echo "  $0 install          Install Packages"
    echo "  $0 build            Build to game.rbxl"
    exit 1
}

install_packages() {
    aftman install
    wally install

    rojo sourcemap --output sourcemap.json --include-non-scripts
    wally-package-types --sourcemap sourcemap.json Packages/
}

build() {
    rojo sourcemap --output sourcemap.json --include-non-scripts
    rojo build -o game.rbxl default.project.json
}

run() {
    rojo serve default.project.json \
        & rojo sourcemap --watch default.project.json --output sourcemap.json --include-non-scripts
}

if [[ -f "default.project.json" ]]; then
    if [[ $1 == "run" ]]; then
        run
        exit 0
    elif [[ $1 == "install" ]]; then
        install_packages
        exit 0
    elif [[ $1 == "build" ]]; then
        build
        exit 0
    fi
else
    echo "Project not initialized"
    exit 1
fi

echo "Invalid Arguement Passed"
usage
