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

if minetest.get_modpath("moretrees") then
	treecapitator.register_tree({
		trees = {"moretrees:acacia"},
		leaves = {"moretrees:acacia_leaves"},
		range = 10,
	})

	treecapitator.register_tree({
		trees = {"moretrees:apple_tree"},
		leaves = {"moretrees:apple_tree_leaves"},
		range = 20,
		fruits = {"default:apple"}
	})

	treecapitator.register_tree({
		trees = {"moretrees:beech"},
		leaves = {"moretrees:beech_leaves"},
		range = 8,
	})
	treecapitator.register_tree({
		trees = {"moretrees:birch"},
		leaves = {"moretrees:birch_leaves"},
		range = 8,
	})

	treecapitator.register_tree({
		trees = {"moretrees:fir"},
		leaves = {"moretrees:fir_leaves"},
		range = 12,
		fruits = {"moretrees:fir_cone"}
	})

	treecapitator.register_tree({
		trees = {"moretrees:jungletree"},
		leaves = {"moretrees:jungletree_leaves"},
		range = 8,
	})

	treecapitator.register_tree({
		trees = {"moretrees:oak"},
		leaves = {"moretrees:oak_leaves"},
		range = 8,
		fruits = {"moretrees:acorn"}
	})

	treecapitator.register_tree({
		trees = {"moretrees:palm"},
		leaves = {"moretrees:palm_leaves"},
		range = 8,
		fruits = {"moretrees:coconut"}
	})

	treecapitator.register_tree({
		trees = {"moretrees:pine"},
		leaves = {"moretrees:pine_leaves"},
		range = 8,
		fruits = {"moretrees:pine_cone"}
	})

	treecapitator.register_tree({
		trees = {"moretrees:rubber_tree"},
		leaves = {"moretrees:rubber_tree_leaves"},
		range = 8,
	})

	treecapitator.register_tree({
		trees = {"moretrees:sequoia"},
		leaves = {"moretrees:sequoia_leaves"},
		range = 12,
		fruits = {"moretrees:banana"}
	})

	treecapitator.register_tree({
		trees = {"moretrees:spruce"},
		leaves = {"moretrees:spruce_leaves"},
		range = 10,
		fruits = {"moretrees:spruce_cone"}
	})

	treecapitator.register_tree({
		trees = {"moretrees:willow"},
		leaves = {"moretrees:willow_leaves"},
		range = 12,
	})

end
