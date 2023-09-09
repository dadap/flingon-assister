# Flingon Assister

This is a port of [boQwI'](https://github.com/de7vid/klingon-assistant) to
[Flutter](https://flutter.io/). It does not yet support all of the features of
the original boQwI' program.

This project is named "Flingon Assister" in part to distinguish it from the
"Klingon Assistant" project name of the original boQwI'. The name is a sandwich
portmanteau of "Flutter" and "Klingon Assistant".

## Getting Started

For iOS users, unless you're interested in contributing to boQwI' development or
testing out unreleased updates, you should [download it from the App Store](
https://itunes.apple.com/us/app/boqwi/id1353654291?mt=8). For Android users,
you should probably install the original boQwI' from Google Play, but if you're
curious or bored you are more than welcome to create an Android build of this
Flutter port.

If you would like to build boQwI' yourself, then get set up with a Flutter
development environment, and clone this project. It uses the
[klingon-assistant-data project](https://github.com/De7vID/klingon-assistant-data)
as a submodule, so make sure to include `--recurse-submodules` in your git
command line when cloning. If you forget to do that, you can do it after cloning
with:`git submodule init; git submodule update --remote`.

Make sure to generate the database before building by running:
`data/xml2json.py | bzip2 > qawHaq.json.bz2`
