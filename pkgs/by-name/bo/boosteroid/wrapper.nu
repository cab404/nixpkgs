#!/usr/bin/env nu

# This script needs to be located in /nix/store/**/libexec/
let storePath = $env.FILE_PWD | path dirname
let origBinPath = $storePath + "/bin/Boosteroid"

let configDir = ($env.XDG_CONFIG_HOME? | default ($env.HOME + "/.config")) + "/Boosteroid Games S.R.L./"
let binFile = $configDir + "nixCurrentBin"

print $binFile
if not ($binFile | path exists) {
    ln -s $origBinPath $binFile
}

# Launching
run-external $binFile

# If an update was downloaded, apply it
if ("/tmp/boosteroid.tar" | path exists) {
    print "Found an update archive, patching!"
    rm $binFile

    with-env {
        NIXPKGS_ALLOW_UNFREE: 1,
        NIX_PATH: "nixpkgs=/home/cab/data/cab/nixpkgs"
    } {
        cd $configDir
        # let output = nix-build -E '(import <nixpkgs> {}).boosteroid.overrideAttrs { updateTar = /tmp/boosteroid.tar; }'
        let output = nix-build -E '(import /home/cab/data/cab/nixpkgs {}).boosteroid.override { updateTar = /tmp/boosteroid.tar; }'
        rm -f /tmp/boosteroid.tar $binFile
        ln -fs ($output + "/bin/Boosteroid") ($binFile)
        print $"New version installed ($output)"
        exec $env.CURRENT_FILE
    }

}
