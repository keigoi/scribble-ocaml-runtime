# A runtime for scribble-ocaml

Currently, no documentation available. Please see [examples/](examples) folder.
For Scribble, consult the [Scribble official website](http://www.scribble.org/).

## How to try it

Prepare OCaml 4.02.1 or later and install ```findlib```, ```ocamlbuild```, ```ppx_tools```, and ```[linocaml](https://github.com/keigoi/linocaml)```.
We recommend to use ```opam``` and OCaml 4.03.0.

Install the compiler and prerequisite libraries and tools.

    # Install git and mercurial
    brew install git mercurial # or equivalent. For Debian-based systems, do "apt install git mercurial"

    # Install opam
    wget https://raw.github.com/ocaml/opam/master/shell/opam_installer.sh -O - | sh -s /usr/local/bin

    opam switch 4.05.0
    eval `opam config env`

    # install prerequisites of ppx_implicits
    opam pin add omake 0.10.2
    opam install ocaml-compiler-libs ppx_deriving.4.2.1 re.1.7.1 ppxx.2.3.0 typpx.1.4.1

    # install ppx_implicits
    hg clone https://bitbucket.org/camlspotter/ppx_implicits
    cd ppx_implicits
    hg update 152cc81d7e87
    ocaml setup.ml -configure --prefix `opam config var prefix`
    ocaml setup.ml -build
    ocaml setup.ml -install

    opam pin remove omake
    opam upgrade

    opam install ocamlfind opam-installer jbuilder lwt.3.1.0 ppx_deriving.4.2.1

And install [linocaml](https://github.com/keigoi/linocaml).

    git clone https://github.com/keigoi/linocaml.git
    cd linocaml
    jbuilder build && jbuilder install

Then clone the repository and type following at the top directory:

    git clone https://github.com/keigoi/scribble-ocaml-runtime.git
    cd scribble-ocaml-runtime
    jbuilder build && jbuilder install

Then you can play with ```scribble-ocaml-runtime```:

    cd examples
    make                       # build examples
    rlwrap ocaml -short-paths  # play with OCaml toplevel (utop will also do).
                               # rlwrap is a readline wrapper (recommended)

Argument ```-short-paths``` is optional (it makes ```ocaml``` show the shortest path for each type).
Note that [.ocamlinit](examples/.ocamlinit) file automatically pre-loads all required packages into OCaml toplevel and sets -rectypes option.
It also does ```open Session```.

If things seem broken, try ```git clean -fdx```then ```make``` (WARNING: this command erases all files except the original distribution).
Also, you can uninstall manually by ```ocamlfind remove scribble-ocaml-runtime```.

## TODO

* See [issues](https://github.com/keigoi/scribble-ocaml-runtime/issues).

----
author: Keigo IMAI (@keigoi on Twitter / keigoi __AT__ gifu-u.ac.jp)
