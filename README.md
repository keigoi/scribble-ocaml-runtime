# A runtime for scribble-ocaml

Currently, no documentation available. Please see [examples/](examples) folder.
For Scribble, consult the [Scribble official website](http://www.scribble.org/).

## How to try it

Prepare OCaml 4.02.1 or later and install ```findlib```, ```ocamlbuild```, ```ppx_tools```, and ```[linocaml](https://github.com/keigoi/linocaml)```.
We recommend to use ```opam``` and OCaml 4.03.0.

Install the compiler and prerequisite libraries.

    opam switch 4.03.0
    eval `opam config env`
    opam install ocamlfind ocamlbuild ppx_tools

And install [linocaml](https://github.com/keigoi/linocaml).

    git clone https://github.com/keigoi/linocaml.git
    cd linocaml
    ./configure --prefix=$(dirname `which ocaml`)/..
    make
    make install

Then clone the repository and type following at the top directory:

    git clone https://github.com/keigoi/scribble-ocaml-runtime.git
    cd scribble-ocaml-runtime
    ./configure --prefix=$(dirname `which ocaml`)/..
    make
    make install

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
