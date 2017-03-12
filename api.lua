-- the table where the trees are stored at
treecapitator.trees = {}

-- a table of trunks which couldn't be redefined
treecapitator.rest_tree_nodes = {}

--adds trunks to rest_tree_nodes if they were overwritten by other mods
local tmp_trees = {}
local function test_overwritten(tree)
	tmp_trees[#tmp_trees+1] = tree
end

minetest.after(0, function()
	for _,tree in pairs(tmp_trees) do
		if not minetest.registered_nodes[tree].after_dig_node then
			minetest.log("error", "[treecapitator] Error: Overwriting "
				.. tree .. " went wrong.")
			treecapitator.rest_tree_nodes[#treecapitator.rest_tree_nodes+1] = tree
		end
	end
	tmp_trees = nil
end)

-- the function to overide trunks
local override
if minetest.override_item then
	function override(name)
		minetest.override_item(name, {
			after_dig_node = function(pos, _, _, digger)
				treecapitator.capitate_tree(pos, 0, digger)
			end
		})
	end
else
	minetest.log("deprecated", "minetest.override_item isn't supported")
	table.copy = table.copy or function(tab)
		local tab2 = {}
		for n,i in pairs(tab) do
			tab2[n] = i
		end
		return tab2
	end
	function override(name, data)
		data = table.copy(data)
		data.after_dig_node = function(pos, _, _, digger)
			treecapitator.capitate_tree(pos, 0, digger)
		end
		minetest.register_node(":"..name, data)
	end
end

--the function to register trees to become capitated
local num = 1
function treecapitator.register_tree(tab)
	for name,value in pairs(treecapitator.default_tree) do
		tab[name] = tab[name] or value	--replaces not defined stuff
	end
	treecapitator.trees[num] = tab
	num = num+1

	for _,tree in pairs(tab.trees) do
		local data = minetest.registered_nodes[tree]
		if not data then
			minetest.log("info", "[treecapitator] Info: "
				.. tree .. " isn't registered yet.")
			treecapitator.rest_tree_nodes[#treecapitator.rest_tree_nodes+1] = tree
		else
			if data.after_dig_node then
				minetest.log("info", "[treecapitator] Info: " .. tree
					.. " already has an after_dig_node.")
				treecapitator.rest_tree_nodes[#treecapitator.rest_tree_nodes+1] = tree
			else
				override(tree, data)
				test_overwritten(tree)
			end
		end
	end
end

--use register_on_dignode if trunks are left, this doesnt work at this time l think…
if treecapitator.rest_tree_nodes[1] then
	minetest.register_on_dignode(treecapitator.capitate_tree)
end
