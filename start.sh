#!/bin/sh
brew install hugo
rm -rf public/
git submodule add -b master https://github.com/dfernandezramos/dfernandezramos.github.io.git public