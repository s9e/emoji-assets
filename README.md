This repository experimentally provides a copy of the Noto Emoji and Twitter Emoji image sets, optimized for the web.

![](https://cdn.jsdelivr.net/gh/s9e/emoji-assets/assets/noto/svgz/1f642.svgz)


## How to build

You will need Bash, php, npm and zopfli installed. Run `scripts/init.sh` to install git submodules and svgo, then run `scripts/build_noto.sh` and `scripts/build_twemoji.sh` to rebuild the files in the `assets` directory. The process is single threaded and may take several minutes.


## Assets

Images in the `assets/noto` directory are derived from the [Noto Emoji](https://github.com/googlei18n/noto-emoji) images.
Images in the `assets/twemoji` directory are derived from the [Twitter Emoji](https://github.com/twitter/twemoji) images.

Filenames have been normalized and the SVG content has been minified with [SVGO](https://github.com/svg/svgo/) before being compressed with [zopfli](https://github.com/google/zopfli).


## License

Tools in the `scripts` directory are under the [MIT license](scripts/LICENSE).
Images in the `assets/noto` directory are under the [Apache license, version 2.0](assets/noto/LICENSE) unless otherwise noted. See [assets/noto/AUTHORS](assets/noto/AUTHORS) for the list of authors. Flag images under third_party/behdad/region-flags are in the public domain or otherwise exempt from copyright ([more info](https://github.com/behdad/region-flags/blob/gh-pages/COPYING)).
Images in the `assets/twemoji` directory are licensed under [CC-BY 4.0](assets/twemoji/LICENSE-GRAPHICS), copyright 2018 Twitter, Inc and [other contributors](https://github.com/twitter/twemoji/graphs/contributors).


## Differences from Noto Emoji

- SVG content has been minified with SVGO.
- SVG files have been compressed with zopfli to produce SVGZ files.
- Filenames have been normalized to only include the characters' codepoints, excluding U+200D and U+FE0F. For instance, the image named `emoji_u26f9_200d_2640.svg` in Noto Emoji is available as `26f9-2640.svgz` in this repository.
- Country and regional flags missing from the Noto Emoji repository have been sourced from [behdad/region-flags](https://github.com/behdad/region-flags). The dimensions of the images have been modified to fit the same 1:1 aspect ratio used in Noto Emoji. The aspect ratio of individual flags has been preserved. Flags images were modified to have rounded corners.


## Differences from Twitter Emoji

- SVG content has been minified with SVGO.
- SVG files have been compressed with zopfli to produce SVGZ files.
- Filenames have been normalized to use 4- and 5- digits hex values, and exclude `200f` and `fe0f`. For instance, the image named `a9.svg` in Noto Emoji is available as `00a9.svgz` in this repository.


## Contributions

This repository is not open for external contributions. If you have a suggestion that pertains exclusively to this repository, you can open a new issue to discuss it. If you have a suggestion or a pull request that pertains to the art, please direct it to their relevant author.
