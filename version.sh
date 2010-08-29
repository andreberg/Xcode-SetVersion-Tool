#!/bin/sh

SVN="false"

if [[ ! -e Versioning/setversion ]]; then
    gcc -o Versioning/setversion -w -framework Foundation -framework CoreServices Versioning/setversion.m
fi

if [[ $SVN == "false" ]]; then
   Versioning/setversion Info.plist
else
   REV="`svn info | grep Revision | cut -f 2 -d ':' | cut -f 2 -d ' '`"
   Versioning/setversion Info.plist "" $REV
fi
