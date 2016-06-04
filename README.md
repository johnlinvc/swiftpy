# Swiftpy : embedding Python in Swift

## Requirements

- OSX 10.11.4
- Swift toolchain swift-DEVELOPMENT-SNAPSHOT-2016-05-31-a-osx
- Python 2.7.10_2 (installed with home brew)

## Building

```bash
git checkout develop
./build.sh
```

run demo

```bash
./build.sh
.build/debug/SwiftpyDemo
```

## Features

- run python code from string
- load python module
- call function on python objects with normal args(no kargs)
- convert String between Swift & Python
- getting/setting attr from object

## Usage

see [Demo](src/SwiftpyDemo/main.swift)

## Todos

- run python code from file
- automagic conversion between Swift & Python
- call function with keyword args
- test system
