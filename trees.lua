--[[
treecapitator.register_tree({
	trees = {<node1>, <node2>, ...},
	leaves = {<node1>, <node2>, ...},
	range = <range>,
	fruits = {<node1>, <node2>, ...},
})
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

treecapitator.register_tree({
	trees = {"sumpf:tree", "sumpf:mossytree"},
	leaves = {"sumpf:leaves"},
	range = 3,
	fruits = {"sumpf:tree_horizontal"}
})

treecapitator.register_tree({
	trees = {"nyanland:mesetree", "nyanland:healstone"},
	leaves = {"nyanland:meseleaves"},
	range = 2,
	fruits = {"default:apple"}
})
