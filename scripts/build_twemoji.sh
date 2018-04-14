#/bin/bash

SRC_EMOJI_DIR="third_party/twitter/twemoji"
TRG_DIR="assets/twemoji"

cd "$(dirname $(dirname $0))"

function normalize {
	str="$1"
	str="${str//-200d/}"
	str="${str//-fe0f/}"
	if [ "${str:2:1}" == '-' ] || [ "${str:2:1}" == '.' ]
	then
		str="00$str";
	fi

	echo "$str"
}

echo "Cleaning dirs..."
rm -rf "${TRG_DIR}/svg" "${TRG_DIR}/svgz"
mkdir "${TRG_DIR}/svg" "${TRG_DIR}/svgz"

echo "Copying text files..."
cp "$SRC_EMOJI_DIR/AUTHORS" "$SRC_EMOJI_DIR/LICENSE-GRAPHICS" "$TRG_DIR"

echo "Copying emoji..."
for src_file in "$SRC_EMOJI_DIR/2/svg/"*.svg;
do
	trg_file="$TRG_DIR/svg/$(normalize $(basename $src_file))"

	cp -f "$src_file" "$trg_file"
done

echo "Running SVGO..."
third_party/node_modules/.bin/svgo -f "$TRG_DIR/svg" --multipass -q

echo "Creating SVGZ..."
zopfli -i100 "$TRG_DIR/svg/"*.svg
for src_file in "$TRG_DIR/svg/"*.gz;
do
	trg_file="$(basename $src_file)"
	trg_file="${TRG_DIR}/svgz/${trg_file%.gz}z"

	mv "$src_file" "$trg_file"
done

echo "Removing SVG dir..."
rm -rf "${TRG_DIR}/svg"

echo "Done."