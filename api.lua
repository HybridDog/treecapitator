-- the table containing the tree definitions
treecapitator.trees = {}

-- test if trunk nodes were redefined
local after_dig_nodes = {}
minetest.after(2, function()
	for i = 1,#after_dig_nodes do
		local nodename = after_dig_nodes[i]
		if not minetest.registered_nodes[nodename].after_dig_node then
			error(nodename .. " didn't keep after_dig_node.")
		end
	end
	after_dig_nodes = nil
end)

-- wrapping is necessary, someone may overwrite treecapitator.capitate_tree
local function after_dig_wrap(pos, _,_, digger)
	treecapitator.capitate_tree(pos, digger)
end

-- For the usage of this function, see trees.lua.
function treecapitator.register_tree(tr)
	for name,value in pairs(treecapitator.default_tree) do
		if tr[name] == nil then
			tr[name] = value	--replaces not defined stuff
		end
	end
	treecapitator.trees[#treecapitator.trees+1] = tr
	if treecapitator.after_register[tr.type] then
		treecapitator.after_register[tr.type](tr)
	end

	for i = 1,#tr.trees do
		local nodename = tr.trees[i]
		local data = minetest.registered_nodes[nodename]
		if not data then
			error(nodename .. " has to be registered before calling " ..
				"treecapitator.register_tree.")
		end
		local func = after_dig_wrap
		local prev_after_dig = data.after_dig_node
		if prev_after_dig then
			func = function(pos, oldnode, oldmetadata, digger)
				prev_after_dig(pos, oldnode, oldmetadata, digger)
				treecapitator.capitate_tree(pos, digger)
			end
		end
		minetest.override_item(nodename, {after_dig_node = func})
		after_dig_nodes[#after_dig_nodes+1] = nodename
	end
end
