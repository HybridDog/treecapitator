-- the table containing the tree definitions
treecapitator.trees = {}

-- For the usage of this function, see trees.lua.
local after_dig_wrap
local after_dig_nodes = {}
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
		if prev_after_dig
		and not after_dig_nodes[nodename] then
			func = function(pos, oldnode, oldmetadata, digger)
				prev_after_dig(pos, oldnode, oldmetadata, digger)
				treecapitator.capitate_tree(pos, digger)
			end
		end
		minetest.override_item(nodename, {after_dig_node = func})
		after_dig_nodes[nodename] = true
	end
end

function treecapitator.capitation_allowed()
	return not treecapitator.capitation_usually_disallowed
end


-- Example of overriding this function
if treecapitator.no_hand_capitation then
	-- disallow capitating trees if no proper tool is used
	treecapitator.capitation_usually_disallowed = true
	local allowed = treecapitator.capitation_allowed
	function treecapitator.capitation_allowed(pos, digger)
		local def = minetest.registered_nodes[
			minetest.get_node{x=pos.x, y=pos.y+1, z=pos.z}.name
		]
		return def and def.groups and minetest.get_dig_params(def.groups,
			digger:get_wielded_item():get_tool_capabilities()).wear > 0
			or allowed(pos, digger)
	end
end

-- test if trunk nodes were redefined
minetest.after(2, function()
	for nodename in pairs(after_dig_nodes) do
		if not minetest.registered_nodes[nodename].after_dig_node then
			error(nodename .. " didn't keep after_dig_node.")
		end
	end
	after_dig_nodes = nil
end)

-- wrapping is necessary, someone may overwrite treecapitator.capitate_tree
function after_dig_wrap(pos, _,_, digger)
	treecapitator.capitate_tree(pos, digger)
end
