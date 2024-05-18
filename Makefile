SHELL = /bin/bash

default: all
	xelatex --shell-escape --output-directory=build/ main.tex
	@read -n1 -p "Open it? ([n]/y)" ans ; if [ "$$ans" = "y" ]; then zathura build/main.pdf & fi

show:
	zathura build/main.pdf

biber:
	biber build/main

bib: biber

build/pages:
	mkdir -p build/pages

clean:
	rm -rf build

all: build/pages

.PHONY: default all clean biber bib
