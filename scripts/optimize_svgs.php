<?php

if (!isset($_SERVER['argv'][1]))
{
	die("No dir\n");
}
foreach (glob($_SERVER['argv'][1] . '/*.svg') as $filepath)
{
	$original  = file_get_contents($filepath);
	$optimized = optimize($original);
	if ($original !== $optimized)
	{
		file_put_contents($filepath, $optimized);
	}
}

// TODO: moving all gradients that are not clipped to the top improves group merges
function optimize($svg)
{
	$svg = preg_replace('(<title>.*?</title>)',                       '', $svg);
	$svg = str_replace(' xmlns:xlink="http://www.w3.org/1999/xlink"', '', $svg);
	$svg = str_replace(' overflow="visible"',                         '', $svg);

	// https://github.com/svg/svgo/issues/842
	$svg = preg_replace('(a[0-9]{12,} [0-9]{12,})', 'a0 0', $svg);

	// Fold a shape used in a clipPath into the clipPath itself
	$svg = preg_replace(
		'(<defs>(<[a-z]+) id="([a-z]+)"([^>]*/>)</defs>(<clipPath id="[a-z]+">)<use xlink:href="#\\2"/>(</clipPath>))',
		'$4$1$3$5',
		$svg
	);

	// Re-add the xlink namespace if necessary
	if (strpos($svg, 'xlink:') !== false)
	{
		$svg = preg_replace('(<svg[^>]+)', '$0 xmlns:xlink="http://www.w3.org/1999/xlink"', $svg, 1);
	}

	// Wrap every element with a clip-path attribute into a group
	$svg = preg_replace('((<[^>]*)( clip-path="[^"]+")([^>]*/>))', '<g$2>$1$3</g>', $svg);

	// Merge consecutive groups
	if (strpos($svg, '</g><g') !== false)
	{
		$svg = mergeGroups($svg);
	}

	// Remove groups with a single element
	$svg = preg_replace('(<g( clip-path="[^"]+")>(<[^>]+)/></g>)', '$2$1/>', $svg);

	return $svg;
}

function getAttributes(DOMElement $element)
{
	$attributes = [];
	foreach ($element->attributes as $attribute)
	{
		$attributes[$attribute->nodeName] = $attribute->nodeValue;
	}

	return $attributes;
}

function groupsMatch(DOMElement $g1, DOMElement $g2)
{
	return getAttributes($g1) == getAttributes($g2);
}

function mergeGroups($svg)
{
	$dom = new DOMDocument;
	if (!$dom->loadXML($svg))
	{
		die($svg);
	}
	foreach ($dom->getElementsByTagName('g') as $g)
	{
		while ($g->nextSibling instanceof DOMElement && groupsMatch($g, $g->nextSibling))
		{
			while ($g->nextSibling->firstChild)
			{
				$g->appendChild($g->nextSibling->firstChild);
			}
			$g->parentNode->removeChild($g->nextSibling);
		}
	}

	return $dom->saveXML($dom->documentElement);
}
