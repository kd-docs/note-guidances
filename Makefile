SHELL = /bin/bash
# This Makefile is used to compile the LaTeX document.
# It requires user updates bibligraphy manually in order to avoid double
# compilation every time.

default: all
	lualatex --shell-escape --interaction=nonstopmode --output-directory=build/ main.tex
	@read -n1 -p "Open it? ([n]/y)" ans ; if [ "$$ans" = "y" ]; then zathura build/main.pdf & fi

build/pages:
	mkdir -p build/pages

full: | build/pages
	lualatex --shell-escape --interaction=nonstopmode --output-directory=build/ main.tex
	biber build/main
	lualatex --shell-escape --interaction=batchmode --output-directory=build/ main.tex
	lualatex --shell-escape --interaction=batchmode --output-directory=build/ main.tex

show:
	zathura build/main.pdf &

biber:
	biber build/main

clean:
	rm -rf build

all: | build/pages

.PHONY: default all clean biber
