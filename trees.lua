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
