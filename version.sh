#!/bin/sh

# Shows a possibility how setversion can be used to update Info.plist based on SVN revision data

SVN="false"

if [[ ! -e setversion ]]; then
    gcc -o setversion -w -framework Foundation -framework CoreServices setversion.m
fi

if [[ $SVN == "false" ]]; then
   setversion Info.plist
else
   REV="`svn info | grep Revision | cut -f 2 -d ':' | cut -f 2 -d ' '`"
   setversion Info.plist "" $REV
fi
