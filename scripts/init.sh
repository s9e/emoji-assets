#/bin/bash

EMOJI_DIR="third_party/googlei18n/noto-emoji"

cd "$(dirname $(dirname $0))"

if [ -d "$EMOJI_DIR" ];
then
	GIT_DIR="$EMOJI_DIR/.git" git pull
else
	git clone --depth=1 https://github.com/googlei18n/noto-emoji.git "$EMOJI_DIR"
fi

npm install --prefix third_party "git+https://git@github.com/JoshyPHP/svgo.git#patched"
#npm install --prefix third_party "git+https://git@github.com/JoshyPHP/svgo.git#patched" twemoji
