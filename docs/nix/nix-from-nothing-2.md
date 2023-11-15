# Nix From Nothing 2

## Flakes

- a nix flake contains the metadata for a project
- flakes have inputs and outputs
- inputs are the things required to build the outputs
- inputs lets us create an attribute set of different inputs
- outputs is a function that takes inputs and uses them
- in outputs we get inputs as argument
- output returns an attribute set
- attribute set has a formal schema
- there are certain attribute keys nix is aware of
- nix-rpl :lf load flake, specify flake
- nix-rpl: inputs.nixpkgs is its own separate flake and has inputs and outputs
- build a specific package from a flake, specify (location . and specified attribute to build)`nix build .#hello`
- when nix manages dependencies of a flake, it looks at a url and pulls it and creates a flake.lock
- flake.lock specified the version, the hash of the contents, flake is now reproducible
- we can not have nested attribute sets inside of `x86_64-linux` (host)
- useful command `nix flake show`, displays all of the outputs for a flake
- if we export for a single system we can use a variable to specify a system

```nix
{
    inputs = {
        nixpkgs = {
            url = "github:nixos/nixpkgs/nixos-22.11" # specified locked down version
        }
    }

    outputs = flakeinputs: { # the argument attribute flakeinputs can be named anything it contains the inputs
        # export a package
        packages = {
            x86_64-linux  = {# specify outputs for different systems
                # specify all packages for this system
                # hello program from nixpkgs
                hello = inputs.nixpkgs.legacyPackages.x86_64-linux.hello; # the name for the package could be anything
            };
            aarch-linux = { # to build for an arm system example
                hello = inputs.nixpkgs.legacyPackages.aarch64.hello; # the name for the package could be anything
            }
        };
    };
}
```

Simplified code without retyping system over and over again

```nix
{
    inputs = {
        nixpkgs = {
            url = "github:nixos/nixpkgs/nixos-22.11";
        };
    };

    outputs = flakeinputs:
        let
            # specify system for reuseability
            system = "x86_64-linux";
            pkgs = inputs.nixpkgs.legacyPackages.${system};
        in
        {
            packages.${system} = {
                hello = pkgs.hello;
            };
        };
    };
}
```

---

## Creating a own Derivation - Writing a Textfile

- to build the flake with our derivation
- `nix build .#myderivation`
- the result will point to the created derivation (file with hello world)
- we can build our own packages that can be reproduced by everyone

```nix
{
    inputs = {
        nixpkgs = {
            url = "github:nixos/nixpkgs/nixos-22.11";
        };
    };

    outputs = flakeinputs:
        let
            # specify system for reuseability
            system = "x86_64-linux";
            pkgs = inputs.nixpkgs.legacyPackages.${system};
        in
        {
            packages.${system} = {
                myderivation = pkgs.stdenv.mkDerivation { #writing out a text file containing hello world
                    name = "my-derivation";

                    src = ./.;

                    installPhase = ''
                        echo HELLO WORLD > $out
                    ''
                };
            };
        };
    };
}
```

- we can tell nix to build and run a package from a remote location

### Commands

- `nix flake show` -> shows output of a flake
- `nix build .#cowsay` -> build the output of a flake
- `nix run github:snowfallorg/cowsay#cowsay` -> builds and executes the binary

#### Build Derivations

- `buildInputs = [];` -> are packages that are available during build of the package
- package where the result is the output of a script
- `installPhase = '' hello > $out ''`

- `nativeBuildInputs` are inputs that are available on the runtime side, the system the code executes on (also available during build)

- in the install phase copy the file into the out directory (needs to be passed with source)

- `dontFixup` ->(do not use unless absolutely necessary) if we tell make derivation to not fix up automatically it will not do extra work to ensure that things work - not everything necessarily will point to the nix store

### Nix Development Shells

- devShells are structured like packages
- an attribute set with a property for each supported system
- each system has it's own set of packages
- EXCEPT they are not necessarily packages but development shells
- we specify a shell by giving it an attribute name
- and a value of pkgs.mkShell
- we pass `buildInputs = [ pkgs.hello ];` to make the hello package available
- `nix develop .#attributename` runs the specified shell based on the specified attribute name
- entering a development shell allows us to get a bash session with all the specified inputs (hello package, rustc)
- there is a shorthand for the common syntax that runs nix something and points to the flake location
- if something is not named nix will default to `nix develop .#default`
- there are _other_ outputs besides packages and dev shells
- for example(things nix knows about):
  - overlays
  - nixosConfigurations
  - checks.${system} (little programs that can invalidate flakes (lint))
  - darwinConfigurations
  - apps.${system}
  - formatter
  - nixosModules
  - templates
- the nix schema defining outputs can be found in the [nix wiki](https://www.youtube.com/redirect?event=live_chat&redir_token=QUFFLUhqbl9XUlc0SzVmUmt2MGNyZFFGeU92dDh4d2dLQXxBQ3Jtc0ttc1k3SkFJczAwU0JGX1hyeThIXzExa3BkNEJMM0RTQ0gzaWpCZWxuSXZJdVBWcGQ2WWdOR0lpUnYtWExFWTIxQW5YQW9MSm1mN1NjU0dfV2hsVjQtakxiRFpPalNhZE5nOTF2Y2JlODJnSmtyRWdoWQ&q=https%3A%2F%2Fnixos.wiki%2Fwiki%2FFlakes%23Flake_schema)
- `nix flake show` will error if it does not know about something
- `nix flake check` does verify against the schema

```nix
{
    inputs = {
        nixpkgs = {
            url = "github:nixos/nixpkgs/nixos-22.11";
        };
    };

    outputs = inputs:
        let
            system = "x86_64-linux";
            pkgs = inputs.nixpkgs.legacyPackages.${system};
        in
        {
            packages.${system} = { };

            devShells.${system} = {
                buildInputs = [ pkgs.hello pkgs.rustc];
            }
        }
}
```

### Useful Things for Flakes

- if we want to support multiple systems
- we need a way to provide outputs for every system
- `nix flake update` to update the lock file (this is required when a input changes)
- `nix-repl` inputs.flake-utils gives us a lot of utils for our flake
- the nix-utils.lib is an attribute set of useful helper functions
- functions that let us specify outputs per system and merges them all together
- `defaultSystems`
- `lib.eachDefaultSystem` helper is a function takes in the default systems (four different platforms are supported)
- To specify the systems we want to specify(example below)
- inputs.flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system: {
- to support all systems we can use the `allSystems` helper on the flake-utils.lib
- works the same for all other modules
- to use the our own package in a devShell we can either extract it out or we can make a recursive attribute set
- add `rec` to make the outputs recursive (after variable set)

```nix
{
    inputs = {
        nixpkgs = {
            url = "github:nixos/nixpkgs/nixos-22.11";
        };

        # Flake Utils
        flake-utils = {
            url = "github:numtide/flake-utils";
        };
    };

    # Inputs now contain flake-utils
    outputs = inputs:
        let
            systems = ["x86_64-linux" "aarch64-linux"];
            pkgs = inputs.nixpkgs.legacyPackages.${system};
        in
        inputs.flake-utils.lib.eachDefaultSystem (system: {
            # flake utils will do the hard work of inserting the appropriate system
            packages = {
                hello = inputs.nixpkgs.legacyPackages.${system}.hello;
            }
            # nix flake show will show us that we now support all of the four default systems
        })
}
```

### Make Flake

- to create a flake we have to do two things
- flake utils needs to know about the inputs and about the flake itself
- when you destructure the inputs all attributes need to be mentioned (...) is required if we need more
- the self input refers to the flake itself (lazy recursive evaluation in functional programming, flake outputs and metadata)
- falke utils plus is going to generate the flake output, because the inputs for the flake as well as the outputs are provided
- the following can be simplified
- flake utils plus is now gnerating the output
- flake utils plus will let us use a function to specify what to put on an output set
- the channels attribute contains the packages (falke utils plus)
- flake utils plus will look at inputs and make them avaialble in the channels output

```nix
{
    inputs = {
        nixpkgs = {
            url = "github:nixos/nixpkgs/nixos-22.11";
        };

        # Flake Utils
        flake-utils = {
            url = "github:numtide/flake-utils";
        };

        # Flake Utils Plus
        flake-utils-plus = {
            url = "github:gytis-ivaskevicuius/flake-utils-plus";
        };
    };

    # Inputs now contain flake-utils
    outputs = { nixpkgs, flake-utils-plus, self }: flake-utils-plus.lib.mkFlake {
        inputs = {
            nixpkgs = nixpkgs;
            flake-utils-plus = flake-utils-plus;
        };

        self = self;
    }
}
```

simplified

```nix
{
    inputs = {
        nixpkgs = {
            url = "github:nixos/nixpkgs/nixos-22.11";
        };

        flake-utils-plus = {
            url = "github:gytis-ivaskevicuius/flake-utils-plus";
        };
    };

    outputs = { nixpkgs, flake-utils-plus, self }:
        flake-utils-plus.lib.mkFlake {
            inherit inputs self;

        outputsBuilder = channels: {
            packages = {
                # hello
            };
        };
    };
}
```

### Flake creation with Nix Templates (01h:39min)

- `nix flake init` initializes a basic flake
- `nix init --pick` - that tool is not necessary available, created by Jake Hamilton
- initialize a template of the flake using flake-utils plus `nix init -t <point-to-flake:github:numtide/flake-utils/falke.nix>`
- `nix init -t github:snowfallorg/templates#empty` (not official nix)
  - creates a new flake
  - with nixpkgs
  - nixos-unstable
  - snowfall-lib (uses flake utils plus under the hood) [snowfall](https://snowfall.org/)
  - instead of specifying packages and shells it is done in a directory structure
  - create a directory `packages/my-hello/default.nix` (by default nix looks for default.nix when importing form a directory)
  - we are going to create a package in the `default.nix` file
  - create a function that returns a derivation

flake.nix generate with snowfall template

```nix
{
    description = "My Nix flake";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
        unstable.url = "github:nixos/nixpkgs/nixos-unstable";
        snowfall-lib.url = {
            url: "github:snowfallorg/templates#snowfall";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = inputs:
        inputs.snowfall-lib.mkFlake {
            inherit inputs;

            overlay-package-namespace = "mypackages";

            src = ./.;
        };
}
```

default.nix

```nix
{hello, ....}:

hello

```
