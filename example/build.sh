#!/bin/sh
# Builds the site twice and puts the pages in one folder ($1).
#   _config.yml            every page, with the {% privatus_analytics %} tag in the layout
#   + _config_auto.yml     /auto: automatic injection on, a layout without the tag
# Automatic injection is for the whole site, so it gets its own build.
set -e
out="$1"
bundle exec jekyll build -q -s site -d "$out"
bundle exec jekyll build -q -s site -d /tmp/auto --config site/_config.yml,site/_config_auto.yml
cp /tmp/auto/auto/index.html "$out/auto/index.html"
