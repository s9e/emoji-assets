<?php

$dir = $_SERVER['argv'][1];
array_map('patchSVG', glob($dir . '/*.svg'));

function patchSVG($filepath)
{
	$dom = new DOMDocument;
	$dom->load($filepath);

	$svg = $dom->documentElement;
	if ($svg->hasAttribute('viewBox'))
	{
		if (!preg_match('((-?[.\\d]+)[ ,](-?[.\\d]+) ([.\\d]+)[ ,]([.\\d]+))', $svg->getAttribute('viewBox'), $m))
		{
			echo "Cannot parse viewBox in $filepath\n";

			return;
		}

		$x      = $m[1];
		$y      = $m[2];
		$width  = $m[3];
		$height = $m[4];
	}
	elseif ($svg->hasAttribute('enable-background'))
	{
		if (!preg_match('(new (-?[.\\d]+) (-?[.\\d]+) ([.\\d]+) ([.\\d]+))', $svg->getAttribute('enable-background'), $m))
		{
			echo "Cannot parse enable-background in $filepath\n";

			return;
		}

		$x      = $m[1];
		$y      = $m[2];
		$width  = $m[3];
		$height = $m[4];
	}
	elseif ($svg->hasAttribute('width') && $svg->hasAttribute('height'))
	{
		$x      = 0;
		$y      = 0;
		$width  = $svg->getAttribute('width');
		$height = $svg->getAttribute('height');
	}
	else
	{
		echo "Cannot parse dimensions in $filepath\n";

		return;
	}

	$radius = round($width * .1, 1);

	$defs     = $svg->appendChild($dom->createElement('defs'));
	$clipPath = $defs->appendChild($dom->createElement('clipPath'));
	$clipPath->setAttribute('id', 'clip-rounded-rectangle');
	$rect     = $clipPath->appendChild($dom->createElement('rect'));
	$rect->setAttribute('x',      $x);
	$rect->setAttribute('y',      $y);
	$rect->setAttribute('width',  $width);
	$rect->setAttribute('height', $height);
	$rect->setAttribute('rx',     $radius);
	$rect->setAttribute('ry',     $radius);

	$g = $dom->createElement('g');
	$g->setAttribute('clip-path', 'url(#clip-rounded-rectangle)');

	$i = $svg->childNodes->length;
	while (--$i >= 0)
	{
		$node     = $svg->childNodes[$i];
		$nodeName = $node->nodeName;
		switch ($nodeName)
		{
			case '#comment':
			case 'clipPath':
			case 'comment':
			case 'defs':
			case 'desc':
			case 'i:pgf':
			case 'linearGradient':
			case 'metadata':
			case 'sodipodi:namedview':
			case 'style':
			case 'title':
				// Do nothing
				break;

			case '#text':
			case 'circle':
			case 'ellipse':
			case 'g':
			case 'line':
			case 'path':
			case 'polygon':
			case 'polyline':
			case 'rect':
			case 'switch':
			case 'text':
			case 'use':
				$g->insertBefore($node, $g->firstChild);
				break;

			default:
				echo "Ignored $nodeName element in $filepath\n";
		}

		$svg->appendChild($g);
	}

	$rect     = $g->insertBefore($dom->createElement('rect'), $g->firstChild);
//	$rect     = $g->appendChild($dom->createElement('rect'));
	$rect->setAttribute('x',      $x);
	$rect->setAttribute('y',      $y);
	$rect->setAttribute('width',  $width);
	$rect->setAttribute('height', $height);
	$rect->setAttribute('rx',     $radius);
	$rect->setAttribute('ry',     $radius);
	$rect->setAttribute('fill',   'none');
	$rect->setAttribute('stroke', 'black');
	$rect->setAttribute('stroke-width', '2%');
	$rect->setAttribute('stroke-opacity', '.1');

	if ($height < $width)
	{
		$y -= ($width - $height) / 2;
		$height = $width;
	}
	elseif ($height > $width)
	{
		$x -= ($height - $width) / 2;
		$width = $height;
	}
	$svg->removeAttribute('width');
	$svg->removeAttribute('height');
	$svg->setAttribute('viewBox', "$x $y $width $height");

	$dom->save($filepath);
}