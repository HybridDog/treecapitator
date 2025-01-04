With the treecapitator mod for Luanti,
when a player digs part of a tree's stem, the whole tree is felled at once.

There are many settings, for example an option to control whether leaves are
dropped, too, or only saplings, resembling leafdecay behaviour.
Support for moretrees is disabled by default and can be enabled with a setting.

If players want to dig single trunk nodes instead of whole trees, they can hold
the shift key.
When felling a tree, neighbouring trees are detected and left unharmed.

This mod is based on Jeja's timber mod, however, the code was revised over and
over, so it became a different mod (according to the
[broom theory](https://www.youtube.com/watch?v=51n-EBigXmg) that is).<br/>
[There I got the name.](http://www.minecraftforum.net/topic/1009577-147-daftpvfs-mods-treecapitator-ingameinfo-crystalwing-startinginv-floatingruins/)

**Depends:** see [depends.txt](https://raw.githubusercontent.com/HybridDog/treecapitator/master/depends.txt)<br/>
**License:** see [LICENSE.txt](https://raw.githubusercontent.com/HybridDog/treecapitator/master/LICENSE.txt)<br/>
**Download:** [zip](https://github.com/HybridDog/treecapitator/archive/master.zip), [tar.gz](https://github.com/HybridDog/treecapitator/archive/master.tar.gz)

![I'm a screenshot!](https://forum.minetest.net/download/file.php?id=571)<br/>
↑ you can only see the animation if your browser supports apng

If you got ideas or found bugs, please tell them to me.

[How to install a mod?](http://wiki.minetest.net/Installing_Mods)


[13.04.2015] Added in trees for moretrees, working out getting proper naming
	for capitating to work.

﻿[14.03.2015] Added sound of a falling tree (taken from there
	http://www.freesound.org/people/ecfike/sounds/139952/).
	Made "drop_items" and "drop_leaf" both "true" by default. (mintpick)

TODO:
* fix neighbour tree detection, wrong nodes become dug (test with vertical
	trunk fruit),
	pertains to non-v6 apple tree and jungle tree
* use range_up and range_down for other trees too for greater precision in
	neighbour detection
* improve moretrees support (see issue #2)
* moretrees acacia
* more precise neighbour detection for moretrees (cedar), fix moretree
	jungletree ignoring default jungletrees' leaves
* technic chainsaw
* Test if pine trees are different on v6 and non-v6 mapgen
* Add a priority and priority condition to allow handling cone pine trees
	differently
* Get rid of the cutting_leaves arguments because the problem is fixed in
	minetest
* consider neighbour tree's stem and not only head during neighbour detection
* add dfs head search (and a parameter to enable it)
* continue the documentation
