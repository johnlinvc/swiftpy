#!/bin/sh
swift build -Xcc "$(python2.7-config --cflags)" -Xlinker "$(python2.7-config --ldflags)"
