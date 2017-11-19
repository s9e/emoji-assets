#/bin/bash

SRC_EMOJI_DIR="third_party/googlei18n/noto-emoji"
SRC_FLAGS_DIR="third_party/behdad/region-flags"
TRG_DIR="assets/noto"

cd "$(dirname $(dirname $0))"

function normalize {
	str="$1"
	str="${str/emoji_u/}"
	str="${str//_200d/}"
	str="${str//_/-}"

	echo "$str"
}

function translate_ris {
	str="$1"
	str="${str:0:1}-${str:1:1}"
	str="${str//A/1f1e6}"
	str="${str//B/1f1e7}"
	str="${str//C/1f1e8}"
	str="${str//D/1f1e9}"
	str="${str//E/1f1ea}"
	str="${str//F/1f1eb}"
	str="${str//G/1f1ec}"
	str="${str//H/1f1ed}"
	str="${str//I/1f1ee}"
	str="${str//J/1f1ef}"
	str="${str//K/1f1f0}"
	str="${str//L/1f1f1}"
	str="${str//M/1f1f2}"
	str="${str//N/1f1f3}"
	str="${str//O/1f1f4}"
	str="${str//P/1f1f5}"
	str="${str//Q/1f1f6}"
	str="${str//R/1f1f7}"
	str="${str//S/1f1f8}"
	str="${str//T/1f1f9}"
	str="${str//U/1f1fa}"
	str="${str//V/1f1fb}"
	str="${str//W/1f1fc}"
	str="${str//X/1f1fd}"
	str="${str//Y/1f1fe}"
	str="${str//Z/1f1ff}"

	echo "$str"
}

function translate_ris_sub {
	str="$1"
	str="${1//-/}"
	str="${str//A/-e0061}"
	str="${str//B/-e0062}"
	str="${str//C/-e0063}"
	str="${str//D/-e0064}"
	str="${str//E/-e0065}"
	str="${str//F/-e0066}"
	str="${str//G/-e0067}"
	str="${str//H/-e0068}"
	str="${str//I/-e0069}"
	str="${str//J/-e006a}"
	str="${str//K/-e006b}"
	str="${str//L/-e006c}"
	str="${str//M/-e006d}"
	str="${str//N/-e006e}"
	str="${str//O/-e006f}"
	str="${str//P/-e0070}"
	str="${str//Q/-e0071}"
	str="${str//R/-e0072}"
	str="${str//S/-e0073}"
	str="${str//T/-e0074}"
	str="${str//U/-e0075}"
	str="${str//V/-e0076}"
	str="${str//W/-e0077}"
	str="${str//X/-e0078}"
	str="${str//Y/-e0079}"
	str="${str//Z/-e007a}"

	echo "1f3f4${str}-e007f";
}

echo "Cleaning dirs..."
rm -rf "${TRG_DIR}/svg" "${TRG_DIR}/svgz"
mkdir "${TRG_DIR}/svg" "${TRG_DIR}/svgz"

echo "Copying text files..."
cp "$SRC_EMOJI_DIR/AUTHORS" "$SRC_EMOJI_DIR/LICENSE" "$TRG_DIR"

echo "Copying flags..."
for src_file in "$SRC_FLAGS_DIR/svg/"*.svg;
do
	basename="$(basename $src_file)"
	basename="${basename%.svg}"

	if [ "${#basename}" == 2 ]
	then
		trg_file="$(translate_ris $basename)"
	else
		trg_file="$(translate_ris_sub $basename)"
	fi
	trg_file="$TRG_DIR/svg/$trg_file.svg"

	cp "$src_file" "$trg_file"
done

echo "Clipping flags..."
php scripts/clip.php "$TRG_DIR/svg"

echo "Copying emoji..."
for src_file in "$SRC_EMOJI_DIR/svg/"*.svg;
do
	trg_file="$TRG_DIR/svg/$(normalize $(basename $src_file))"

	cp -f "$src_file" "$trg_file"
done

echo "Running SVGO..."
third_party/node_modules/.bin/svgo -f "$TRG_DIR/svg" --multipass -q

# https://github.com/svg/svgo/pull/790
# https://github.com/svg/svgo/issues/842
echo "Applying additional optimizations..."
sed -i -e '
	s|<title>.*</title>||;
	s| overflow="visible"||g;
	s|<defs>\(<path\) id="\([a-z]\+\)"\( d="[^"]\+"/>\)</defs>\(<clipPath id="[a-z]\+">\)<use xlink:href="#\2"/>\(</clipPath>\)|\4\1\3\5|g
	s|a[0-9]\{12,\} [0-9]\{12,\}|a0 0|g
	' \
	"$TRG_DIR/svg/"*.svg

echo "Creating SVGZ..."
zopfli -i100 "$TRG_DIR/svg/"*.svg
for src_file in "$TRG_DIR/svg/"*.gz;
do
	trg_file="$(basename $src_file)"
	trg_file="${TRG_DIR}/svgz/${trg_file%.gz}z"

	mv "$src_file" "$trg_file"
done

echo "Adding aliases..."
while read line
do
	line="${line%%#*}"
	line="$(normalize $line)"

	alias="${line%;*}"
	canonical="${line#*;}"

	if [ -n "$alias" ]
	then
		cp "$TRG_DIR/svgz/$canonical.svgz" "$TRG_DIR/svgz/$alias.svgz"
	fi
done < "$SRC_EMOJI_DIR/emoji_aliases.txt"

echo "Removing SVG dir..."
rm -rf "${TRG_DIR}/svg"

echo "Done."