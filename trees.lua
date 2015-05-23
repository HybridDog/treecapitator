--[[
treecapitator.register_tree({
	trees = {<node1>, <node2>, ...},
	leaves = {<node1>, <node2>, ...},
	range = <range>,
	fruits = {<node1>, <node2>, ...},
})

trees:	the straight stem nodes with param2=0
leaves:	nodes of the tree head which only drop their main item if drop_leaf is enabled
range:	the size of the tree head
fruits:	similar to leaves but without the drop_leaf setting condition
]]

treecapitator.register_tree({
	trees = {"default:tree"},
	leaves = {"default:leaves"},
	range = 2,
	fruits = {"default:apple"}
})

treecapitator.register_tree({
	trees = {"default:pinetree"},
	leaves = {"default:pine_needles"},
	range = 6,
})

treecapitator.register_tree({
	trees = {"default:jungletree"},
	leaves = {"default:jungleleaves"},
	range = 3
})

if minetest.get_modpath("nyanland") then
	treecapitator.register_tree({
		trees = {"nyanland:mesetree", "nyanland:healstone"},
		leaves = {"nyanland:meseleaves"},
		range = 2,
		fruits = {"default:apple"}
	})
end

if minetest.get_modpath("farming_plus") then
	treecapitator.register_tree({
		trees = {"default:tree"},
		leaves = {"farming_plus:banana_leaves"},
		range = 2,
		fruits = {"farming_plus:banana"}
	})

	treecapitator.register_tree({
		trees = {"default:tree"},
		leaves = {"farming_plus:cocoa_leaves"},
		range = 2,
		fruits = {"farming_plus:cocoa"}
	})
end

if treecapitator.moretrees_support
and minetest.get_modpath("moretrees") then
	treecapitator.register_tree({
		trees = {"moretrees:acacia_trunk"},
		leaves = {"moretrees:acacia_leaves"},
		range = 10,
	})

	treecapitator.register_tree({
		trees = {"moretrees:apple_tree_trunk"},
		leaves = {"moretrees:apple_tree_leaves"},
		range = 20,
		fruits = {"default:apple"}
	})

	treecapitator.register_tree({
		trees = {"moretrees:beech_trunk"},
		leaves = {"moretrees:beech_leaves"},
		range = 8,
	})
	treecapitator.register_tree({
		trees = {"moretrees:birch_trunk"},
		leaves = {"moretrees:birch_leaves"},
		range = 8,
	})

	treecapitator.register_tree({
		trees = {"moretrees:fir_trunk"},
		leaves = {"moretrees:fir_leaves","fir_leaves_bright"},
		range = 12,
		fruits = {"moretrees:fir_cone"}
	})

	treecapitator.register_tree({
		trees = {"moretrees:jungletree_trunk"},
		leaves = {"moretrees:jungletree_leaves_green","jungletree_leaves_yellow","jungletree_leaves_red"},
		range = 8,
	})

	treecapitator.register_tree({
		trees = {"moretrees:oak_trunk"},
		leaves = {"moretrees:oak_leaves"},
		range = 8,
		fruits = {"moretrees:acorn"}
	})

	treecapitator.register_tree({
		trees = {"moretrees:palm_trunk"},
		leaves = {"moretrees:palm_leaves"},
		range = 8,
		fruits = {"moretrees:coconut"}
	})

	treecapitator.register_tree({
		trees = {"moretrees:pine_trunk"},
		leaves = {"moretrees:pine_leaves"},
		range = 8,
		fruits = {"moretrees:pine_cone"}
	})

	treecapitator.register_tree({
		trees = {"moretrees:rubber_tree_trunk","rubber_tree_trunk_empty"},
		leaves = {"moretrees:rubber_tree_leaves"},
		range = 8,
	})

	treecapitator.register_tree({
		trees = {"moretrees:sequoia_trunk"},
		leaves = {"moretrees:sequoia_leaves"},
		range = 12,
	})

	treecapitator.register_tree({
		trees = {"moretrees:spruce_trunk"},
		leaves = {"moretrees:spruce_leaves"},
		range = 10,
		fruits = {"moretrees:spruce_cone"}
	})

	treecapitator.register_tree({
		trees = {"moretrees:willow_trunk"},
		leaves = {"moretrees:willow_leaves"},
		range = 10,
	})

end
