# nes.cr

<img src="https://cloud.githubusercontent.com/assets/1090631/11979320/2cd2f75c-a971-11e5-8170-1b2f0fad207c.png" width="250">

## Compile

```
$ make
```

### On OSX

```sh
$ brew install sfml
# Apply https://github.com/oprypin/crsfml/issues/30#issuecomment-470306277
$ shards
$ cd ./lib/crsfml/voidcsfml

$ sfml=(/usr/local/Cellar/sfml/2.*)
$ cmake -DCMAKE_MODULE_PATH="$sfml/share/SFML/cmake/Modules" . && make

$ cd ../../../ # back to nes.cr
$ CRYSTAL_LIBRARY_PATH="$(pwd)/lib/crsfml/voidcsfml/lib:$(crystal env CRYSTAL_LIBRARY_PATH)" make
$ install_name_tool -add_rpath $(pwd)/lib/crsfml/voidcsfml/lib nes
```

## Run

```
./nes rom_file.nes
```

## Controls:

* Arrows: arrows
* Z: A
* X: B
* O: Start
* P: Select

## TODO

* Audio (implement Nes APU)
* More mappers (currently NROM and UNROM are supported)

## Issues

Some graphical issues (vblank handling in PPU?)
