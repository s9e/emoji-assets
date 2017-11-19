#/bin/bash

cd "$(dirname $(dirname $0))"

git submodule update --init --recursive
npm install --prefix third_party svgo
