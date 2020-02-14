# Registering a Tree

We need to register trees so that they are known to the treecapitator mod.
Since this mod detects neighbouring trees and should ignore user-placed trunks,
the we should define a tree as strictly as possible.

I have grouped the tree definitions to different types because, for example,
an apple tree requires a different detection algorithm than a palm tree.

## Default Tree

This is probably the most common type of tree in minetest.

```lua
treecapitator.register_tree({
	type = "default",
	trees = {<node1>, <node2>, ...},
	leaves = {<node1>, <node2>, ...},
	range = <range>,
	range_up = <range>,
	range_down = <range>,
	fruits = {<node1>, <node2>, ...},
	trunk_fruit_vertical = <some_boolean>,
	cutting_leaves = <leaves_count>,
	stem_type = <some_string>,
	stem_height_min = <height>,
	requisite_leaves = {<node1>, <node2>, ...},
})
```

* Nodes the tree consists of
  * `trees`
    The trunk nodes of the straight stem.
    Rotated trunks (param2 > 0) are usually ignored.
  * `leaves`
    Nodes of the tree head which represent leaves. <br/>
    In comparison to `fruits`, these nodes are affected
    by the drop_leaf setting.
  * `fruits`
    Like `leaves` but unaffected by the drop_leaf setting. <br/>
    This list can also contain trunk nodes which are spread around
    in the tree head.
  * `trunk_fruit_vertical`
    If set to true, a trunk node which is in `trees` and `fruits` is removed
    even if it is not rotated (param2 > 0).
  * `requisite_leaves`
    If defined, abort capitating if one of the nodes in this list were not
    found in the tree head. <br/>
    We can use this if, for example, the tree head always
    has green and red leaves and never has only one of them.
* Possible tree sizes
  * `range`
    The size of the AABB around the biggest possible tree head.
    `range_up` and `range_down` can override the size in +Y and -Y
    directions. <br/>
    Note that if the tree has a thick stem, the range needs to be
    a bit bigger because the tree head centre can be offset. <br/>
    Example: `range = 2` represents a 5x5x5 cube.
  * `range_up`, defaults to `range`
    Head size in +Y direction, ranging from the highest trunk node to
    the top of the tree head.
  * `range_down`, defaults to `range`
    Like `range_up` but in -Y direction.
  * `stem_type`
    We can ignore this, or set it to `"2x2"` or `"+"`. <br/>
    `"2x2"` represents a 4 nodes thick stem, `"+"` represents a 5
    nodes thick stem which looks like a plus when viewed from above,
    and no stem type represents a simple 1 node thick stem.
  * `stem_height_min`
    This value determines the minimum number of trunk nodes
    the stem consists of; it is only used to identify
    neighbouring trees, which should be preserved.
* Other parameters
  * `cutting_leaves`, deprecated
    used as workaround for moretrees#34;
    only enable this for buggy trees where leaves can be in the stem


## Acacia Tree


## Palm Tree


## Moretrees Tree

This type represents a complex tree from moretrees mod.
The tree can have long branches and other things
which the default tree type algorithm cannot easily detect.
The algorithm for this type is relatively simple, so for a good tree detection,
we should use the default type instead if possible.


```lua
treecapitator.register_tree({
	type = "moretrees",
	trees = {<node1>, <node2>, ...},
	leaves = {<node1>, <node2>, ...},
	range = <range>,
	fruits = {<node1>, <node2>, ...},
	height = <height>,
	max_nodes = <max_nodes>,
	num_trunks_min = <some_number>,
	num_trunks_max = <some_number>,
	num_leaves_min = <some_number>,
	num_leaves_max = <some_number>,
})
```

Many parameters mean the same as the default type tree parameters.
* `height`
  maximum tree height
* `max_nodes`
  maximum number of nodes the tree is allowed to consist of
* num_trunks_min…


# Other Functions and Variables

* `treecapitator.capitation_allowed(pos, player)`
  Returns true if the player `player` is allowed to remove the tree
  at `pos`. <br/>
  We can override this function so that capitation transpires only
  under certain contitions, e.g. only if the player has a chainsaw.
* `treecapitator.capitation_usually_disallowed`
  The value returned by the initial `treecapitator.capitation_allowed`
  function. <br/>
  We can use this if multiple mods add a tool which allows capitating trees,
  i.e. if those mods override `treecapitator.capitation_allowed`.
* `treecapitator.no_hand_capitation`
  If set to true, players cannot capitate trees with the bare hand.
* `treecapitator.capitate_tree(pos, player)`
  This function tests if the player can capitate a tree,
  e.g. it calls `treecapitator.capitation_allowed`,
  and then capitates the tree if possible. <br/>
  It is usually invoked in the trees' trunk nodes' `after_dig_node`
  node definition field.
  The `after_dig_node`s are added/overridden automatically
  after registering a tree.


# To Do

The doc is not finished.
I invite the person who reads this to have a look at init.lua and trees.lua,
and help to continue the API documentation.

