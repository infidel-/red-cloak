#VERSION := $(shell cat VERSION)

all: clean html5-mydebug

html5-mydebug:
	haxe project_js.hxml -debug -D mydebug --connect 6000

html5:
	haxe project_js.hxml --connect 6000

clean:
