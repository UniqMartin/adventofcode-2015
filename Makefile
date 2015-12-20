PONYC ?= ponyc

PONY_DAYS = $(patsubst %/main.pony,%,$(wildcard */main.pony))
PONY_BINS = $(patsubst %,bin-pony/%,$(PONY_DAYS))

# (all languages)

build: build-pony

clean: clean-pony

.PHONY: build clean

# Pony

build-pony: $(PONY_BINS)

bin-pony/%: %/main.pony %/*.pony
	@echo ">>> Building '$@' from ($^)"
	$(PONYC) -o bin-pony $(patsubst %/main.pony,%,$<)

clean-pony:
	rm -f $(PONY_BINS)
	rm -rf $(patsubst %,%.dSYM,$(PONY_BINS))

.PHONY: build-pony clean-pony
