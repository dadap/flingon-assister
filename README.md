# Flingon Assister

This is a port of [boQwI'](https://github.com/de7vid/klingon-assistant) to
[Flutter](https://flutter.io/). It does not yet support all of the features of
the original boQwI' program.

"Flingon Assister" is the working title of this project. The name is a sandwich
portmanteau of "Flutter" and "Klingon Assistant".

## Getting Started

The app is not available on the App Store yet. If you would like to build it
yourself, then get yourself set up with a Flutter development environment,
and clone this project. It uses the klingon-assistant-data project as a
submodule, so make sure to include `--recurse-submodules` in your git command
line when cloning. If you forget to do that, you can do it after cloning with:
`git submodule init; git submodule update --remote`.

Make sure to generate the database before building by running:
`data/xml2json.py | bzip2 > data/qawHaq.json.bz2`
