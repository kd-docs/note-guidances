SRC_TEX=$(shell find . -name '*.tex')
SRC_BIB=$(shell find . -name '*.bib')
SRC=$(SRC_TEX) $(SRC_BIB)
SHELL=/bin/bash

VERBOSE ?= 0
ifeq ($(VERBOSE),0)  # default
	REDIR_EVERYTHING = >/dev/null
	REDIR_WARN = >/dev/null
	REDIR_INFO = >/dev/null
else ifeq ($(VERBOSE),1)  # with warnings
	REDIR_EVERYTHING = >/dev/null
	REDIR_INFO = >/dev/null
	REDIR_WARN =
else ifeq ($(VERBOSE),2)  # with info
	REDIR_EVERYTHING = >/dev/null
	REDIR_WARN = 
	REDIR_INFO =
else ifeq ($(VERBOSE),3)  # with everything
	REDIR_EVERYTHING = 
	REDIR_WARN = 
	REDIR_INFO =
endif


LATEX_FLAGS ?= 
LATEX_ENVS ?=
override LATEX_FLAGS += --shell-escape -interaction=nonstopmode -halt-on-error

BUILD_TARGET = $(if $(SRC_BIB),with-bib,without-bib)

pdf: build/main.pdf ;

build/%.pdf: %-build-$(BUILD_TARGET) ;

LOG_DIGEST = $(shell which ppdflatex) -b -q --input -
EXECUTE_ONCE = $(LATEX_ENVS) xelatex $(LATEX_FLAGS) -output-directory=build/
%-build-without-bib: %.tex $(SRC) | build
	# build $<, no bib file found
	@$(EXECUTE_ONCE) $< $(REDIR_EVERYTHING) || ($(MAKE) show-logs && exit 1)
	@$(EXECUTE_ONCE) $< | $(LOG_DIGEST)

%-build-with-bib: %.tex $(SRC) | build
	# building aux for $<
	@$(EXECUTE_ONCE) $< $(REDIR_EVERYTHING) || ($(MAKE) show-logs && exit 1)

	# building bbl for $<
	$(eval aux=build/$(patsubst %.tex,%.aux,$<))
	$(eval bcf=build/$(patsubst %.tex,%.bcf,$<))
	@if [ -e $(bcf) ] ; then \
		echo "bcf file $(bcf) exists" $(REDIR_WARN) ; \
		biber $(bcf); \
	else \
		echo "bcf file not exists" $(REDIR_WARN) ; \
		bibtex $(aux); \
	fi

	# building pdf for $<, second run
	@$(EXECUTE_ONCE) $< $(REDIR_EVERYTHING)
	# building pdf for $<, final run
	@$(EXECUTE_ONCE) $< | $(LOG_DIGEST)


build: 
	mkdir build
	mkdir -p build/pages

.PHONY: tidy-bib tidy-bib-keys

tidy-bibs: $(SRC_BIB)
	for bib in $^ ; do \
		bibtex-tidy --curly --numeric --align=13 --blank-lines --sort=key \
		--duplicates=key --merge=combine --strip-enclosing-braces --drop-all-caps \
		--no-escape --sort-fields --trailing-commas --encode-urls --max-authors=3 \
		--wrap=80 --modify $$bib ; \
	done

tidy-bib-keys: $(SRC_BIB)
	for bib in $^ ; do \
		bibtex-tidy --generate-keys --modify $$bib ; \
	done

.PHONY: show-logs last-warning last-warnings tell-warning tell-warnings

show-logs \
last-warning \
last-warnings \
tell-warning \
tell-warnings: 
	@echo "last warnings:"
	@echo
	@ppdflatex --input build/main.log

.PHONY: clean show

show: build/main.pdf
	rifle build/main.pdf ||\
	xdg-open build/main.pdf ||\
	open build/main.pdf

clean:
	rm -rf build

