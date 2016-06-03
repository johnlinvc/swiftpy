#!/bin/sh
swift build -Xswiftc "$(python2.7-config --cflags) $(python2.7-config --ldflags) -framework python -framework fundation.c"
