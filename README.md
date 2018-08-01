[Mod] treecapitator [treecapitator]

This mod is makes digging a trunk node of a tree destroy the whole tree
including the leaves and the fruits. There are many settings, such as dropping
no leaves but only saplings (as leafdecay does it).<br/>
Holding shift you can avoid its function to dig the single trunk node.<br/>
Neighbour trees are detected and preserved.<br/>
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
* fix mgv7 default apple tree neighbour tree detection, there sometimes is a
	sheet removed
* use range_up and range_down for other trees too for greater precision in
	neighbour detection
* improve moretrees support (see issue #2)
* moretrees acacia
* more precise neighbour detection for moretrees (cedar), fix moretree
	jungletree ignoring default jungletrees' leaves
* technic chainsaw
* proper documentation
* Test if pine trees are different on v6 and non-v6 mapgen
* Add a priority and priority condition to allow handling cone pine trees
	differently
