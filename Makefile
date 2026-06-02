.PHONY: all build run test prove clean

all: build

build:
	alr build

run: build
	alr run

test: run

prove:
	alr gnatprove

clean:
	alr clean
	rm -rf obj/
