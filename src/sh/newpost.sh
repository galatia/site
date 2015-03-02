#!/bin/bash

echo What is the post title?

read title

strippedtitle=$(echo "$title" | tr -d '[:punct:]' | tr ' [:upper:]' '-[:lower:]')

dir=`date +%F`-$strippedtitle

cd ~/site/rsrc/posts/

if [ -d "$dir" ]; then
    echo "Error: $dir already exists"
    cd $dir
    exit 1
fi

mkdir $dir
echo "Created dir ~/site/rsrc/posts/$dir"
cd $dir

echo "return {" >> meta.lua
echo "    section = {\"\"}," >> meta.lua
echo "    title   = \"$title\"," >> meta.lua
echo "    date    = \"`date '+%F %H:%M %z'`\"," >> meta.lua
echo "    authors = {\"\"}," >> meta.lua
echo "    tags    = {}," >> meta.lua
echo "    published = false" >> meta.lua
echo "}" >> meta.lua

echo "<!--$title" >> index.md
echo "============-->" >> index.md

vim meta.lua

if [ -d "/Applications/Byword.app" ]; then
    open -a "Byword" index.md
else
    vim index.md
fi
