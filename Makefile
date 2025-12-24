OCAMLC = ocamlc
INCLUDES = -I src

# Main executable
TARGET = prfo2025
SRCS = src/dyngraph.ml src/analyse.ml src/main.ml
OBJS = $(SRCS:.ml=.cmo)

# Test executable
TEST_TARGET = run_tests
TEST_SRCS = test/test_best_path.ml
TESTS_FILES = $(wildcard test/base_phase3_*.txt)

all: $(TARGET)

$(TARGET): $(OBJS)
	$(OCAMLC) $(INCLUDES) -o $@ $(OBJS)

test: $(TARGET)
	for f in $(TESTS_FILES); do \
		echo ; \
		echo test : $$f ; \
		./$(TARGET) $$f ; \
		echo ; \
	done

# Generic rules
%.cmi: %.mli
	$(OCAMLC) $(INCLUDES) -c $<

%.cmo: %.ml
	$(OCAMLC) $(INCLUDES) -c $<

# Dependencies
src/dyngraph.cmi:
src/dyngraph.cmo: src/dyngraph.cmi

src/analyse.cmi:
src/analyse.cmo: src/analyse.cmi

src/main.cmo: src/analyse.cmo src/dyngraph.cmo

clean:
	rm -f src/*.cm[iox] src/*.o test/*.cm[iox] test/*.o $(TARGET) $(TEST_TARGET)

.PHONY: all clean test
