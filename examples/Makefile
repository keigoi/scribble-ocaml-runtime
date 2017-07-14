OCAMLC=ocamlfind ocamlc -thread -package session-ocaml,session-ocaml.ppx,session-ocaml.ppx_lens -rectypes -short-paths
OCAMLOPT=ocamlfind ocamlc -thread -package session-ocaml -rectypes -short-paths
OCAMLMKTOP=ocamlfind ocamlmktop -thread -package session-ocaml -rectypes
OCAMLDEP=ocamlfind ocamldep -package session-ocaml

EXAMPLES=booking_example explicit_connection_example fase17/travel_example

EXAMPLES_BYTE = $(EXAMPLES:%=%.byte)


all: $(EXAMPLES_BYTE)

fase17/travel_example.byte: fase17/travel.cmo fase17/travel_example.cmo
	$(OCAMLC) -linkpkg -o $@ $^

explicit_connection_example.byte: explicit_connection.cmo explicit_connection_example.cmo
	$(OCAMLC) -linkpkg -o $@ $^

booking_example.byte: booking.cmo booking_example.cmo
	$(OCAMLC) -linkpkg -o $@ $^

ex_single2.byte: ex_single1.cmo ex_single2.cmo
	$(OCAMLC) -linkpkg -o $@ $^

ex_multi1.byte: ex_single1.cmo ex_single2.cmo ex_multi1.cmo
	$(OCAMLC) -linkpkg -o $@ $^

%.byte: %.cmo
	$(OCAMLC) -linkpkg -o $@ $^


# Common rules
.SUFFIXES: .ml .mli .cmo .cmi .cmx

.ml.cmo:
	$(OCAMLC) -I `dirname $<` -c $<

.mli.cmi:
	$(OCAMLC) -c $<

.ml.cmx:
	$(OCAMLOPT) -c $<

# Clean up
clean:
	rm -f *.top *.native *.byte
	rm -f *.cm[ioaxt] *.cmax *.cmti *.o *.annot

# Dependencies
depend:
	$(OCAMLDEP) $(INCLUDES) *.mli *.ml > .depend

include .depend
