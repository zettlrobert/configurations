# Nix from Nothing

## Resources

[Zero to Nix](https://zero-to-nix.com/)
[Nix Pills](https://nixos.org/guides/nix-pills/)

There is a nix configuration that is located in either `/etc/nix/nix.conf` or `/home/.config/nix/nix.conf`.
To have access to the modern stuff we have to enable `experiemntal-features`.

```nix
# nix.conf
experimental-features = nix-command flakes
```

## The Nix Language

- every nix file has one expression
- command to evaluate nix code `nix eval --file ./path-to-file`
- every nix command has one expression
- nix has builtins like map, filter and other helpers
- they are located in nixpkgs.lib

```nix
#number
42

# string
"string"

# boolean
true

# attribute sets (objects/dictionaries)
{
    name = "value";
}

# lists - there are no  commas, space separates the values
[ 1 2 3 ]

# multi line strings
''
    between double quotes
''

```

### Let Bindings

If we want to create variables, we use let bindings.

```nix
let
    myNumber = 42;
in
```

### Functions

In nix all functions take _one_ argument, string interpolation can be achieved with `${identifier}`

```nix
let
    greet = name: "Hello, ${name}";
in

    greet "Chat" # Returns "Hello, Chat"
```

In nix to provide multiple arguments to a function we make use of `currying`, provide a function to a function.

Supply the first function with an argument, supply it to the second one to have access to both arguments inside the closure.

```nix
let
    greet = greeting: name: "${greeting}, ${name}!";
in

greet "Howdy" "Chat" # returns: Howdy, Chat!
```

### Attribute Sets inside Functions

A function with an attribute set we want to return after doing something

```nix
let
    makeSecret = secret: {
        mySuperSecretValue = secret;
    };
in
#    makeSecret "superSecret"

# Supply an attribute set to a function
    makeSecret { key = "my_secret"; value = "superSecret" };

# Retruns: { mySuperSecretValue = { key = "my_secret"; value = "superSecret"; }; }
```

Nix has build in support to pull out values from attribute sets when used as arguments

```nix
let
    makeSecret = { key, value } : { # ... has to be added to tell nix that it can have more attribute sets but we will not use them
       secret: value;
    }
in

    makeSecret { key = "my_secret"; value = "superSecret" };

# Returns { secret = "superSecret" }
```

We can also set the attribute name with string interpolation `${key}`

There is a shorthand `inherit` to avoid writing out argument lists in nix.

## Nix Imports

In order to import a nix file into a nix file.

```nix
# Assuming that other-file.nix contains the above greeter function
let
    myLibrary = import ./other-file.nix;
in

    myLibrary.greet "Chat"
```

Import nix pkgs from git we could either download it or use the channels from our nix environment `NIX_PATH` which gives access to nix packages.
Imagine directories with nix files that are pulled in via environment.

Nix comes with a default configuration `/etc/nix/inputs/nixpkgs/default.nix`

```nix
let
    pkgs = import <nixpkgs> {}; # Call with empty attribute set to tell it to set itself up
in
    pkgs.lib
```

## Nix Repl

`nix repl`

Nix repl can be used to evaluate nix specific functionality

## Create First Nix Package

```nix
builtins.derivation {
    name = "my-derivation";
    system = "x86_64-linux"; # Find available systems in nix-repl `pkgs.lib.platforms`

    builder = "/bin/sh";
    args = [ "-c" "echo Hello" > $out" ]; # Passed to the builder (give sh a command to run)
}
```

Calling eval on the above returns a big attribute set, the result of the derivation(action of obtaining something from a source or origin).

- create a derivation
- nix produces a derivation file
- pkgs are a place to but build files
- derivation contain one additional information `out` which refers to a specific folder in a hash-nix-derivation-name
- `nix-store --realise /nix/store/hash-deriviaton`
- using a derivation function directly is very tedious and not much we can do without a lot of work
- all of that work has already been done

```nix
let
    pkgs = import <nixpkgs> {};
in
    pkgs.runCommand "my-derivation" {} ''
    echo Hello > $out
''

```

- `nix build --file ./file-name`
- will result in a result that links to the nix/store
- cat result will print 'Hello'
- nix packages mostly use the `pkgs.stdenv.mkDerivation` function

```nix
# nix build --file ./path-to-file
let
    pkgs = import <nixpkgs> {};
in
    # Split in nix phases to bulild, test, adjust...
    pkgs.stdenv.mkDerivation {
        name = "my-derivation";

        src = ./.;

        installPhase = ''
            echo Hello > $out
        '';
    }
```

- `mkDerivation` wraps the default derivation
- `pkgs.stdenv.runCommand` for example is used to run shell scripts

## Module System

- in nix-repl
- nix provides a generic way to provide configuration that get's type checked and collapsed into the module

```nix
    modules = { options.a.enable = lib.mkEnableOption "A"; }

    result = lib.evalModules { modules = [ modulea ]; }

    # Call with
    modulea = {options.a.enable = lib.mkEnableOption "A"; }
```

- modules potentially take three things
- options - let us specify names
- config - things get unique we can set information
- imports




