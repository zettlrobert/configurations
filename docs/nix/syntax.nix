# a nix file has a singular expression
# let in to create variable bindings
# if we want to evaluate a file `nix eval --file ./syntax.nix` --> returns result of expression
# there are attribute sets like dictionaries (objects)
# "hello " + x.name for string concatenation 
# "string interpolation ${x.name}"
# lists are space separated values x = [ 1 2 3 ]
# each function takes only one argument: greet = name: "Hello ${name}" --> greet "Chat"
# to import files lib = import.other-file.nix ->  lives in let in --> lib.greet to access the function  other-file
# a derivation is the most fundamental part of doing stuff in nix (BASE but not used because there is a whole lot of work to build something)
# use the abstraction layers on top of derivations that comes with nixpkgs 
# pkgs = import <nixpkgs> --> refers to our nix PATH
# regular nix installations use nix channels
# nix flakes use 'inputs' `ls $NIX_PATH`
# from nixpkgs we can access attributes like `stdenv` that has the helpful function `mkDerivation` that is an abstraction for the raw derivation function
# the `nix build` command is used to build a derivation
# this will result in a `result` file that is the default output
# we can have multiple outs they can either be files or directories
# a built package get's linked into a local directory
