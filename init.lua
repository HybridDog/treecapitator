treecapitator = {}

-----------------------------------------Old Settings------------------------------------------
--local	timber_nodenames = {"default:jungletree", "default:tree", "sumpf:tree"}
--local	leaves_nodenames = {"default:leaves", "default:jungleleaves", "sumpf:leaves"}
--local	fruit_nodenames  = {"default:apple", "sumpf:tree_horizontal"}
--local	size = 2	--2*size+1


-------------------------------------------Settings--------------------------------------------
treecapitator.drop_items = true	--drop them / get them in the inventory
local trees_to_capitate = {--	trees	leaves	range	fruits
	{{"default:jungletree"}, {"default:jungleleaves"}, 3, {}},
	{{"default:tree"}, {"default:leaves"}, 2, {"default:apple"}},
	{{"sumpf:tree", "sumpf:mossytree"}, {"sumpf:leaves"}, 3, {"sumpf:tree_horizontal"}},
}
-----------------------------------------------------------------------------------------------

local function dropitem(item, posi, digger)
	local inv = digger:get_inventory()
	if (not treecapitator.drop_items)
	and inv
	and inv:room_for_item("main", item) then
		inv:add_item("main", item)
		return
	end
	minetest.env:add_item(posi, item)
end

local function gettree(trees, pos)
	for _, tree in ipairs(trees) do
		if minetest.env:get_node(pos).name == tree then
			return true
		end
	end
	return false
end

local function findtree(pos, node)
	for tr in ipairs(trees_to_capitate) do
		for _, tree in ipairs(trees_to_capitate[tr][1]) do
			if node.name == tree then
				return true
			end
		end
	end
	return false
end



minetest.register_on_dignode(function(pos, node, digger)
	if digger == nil then
		return
	end
    if digger:get_player_control().sneak
    or (not findtree(pos, node)) then
		return
	end
	local np = {x=pos.x, y=pos.y+1, z=pos.z}
	for tr in ipairs(trees_to_capitate) do
		while gettree(trees_to_capitate[tr][1], np) do
			local tree = minetest.env:get_node(np).name
			minetest.env:remove_node(np)
			dropitem(tree, np, digger)
			np.y = np.y+1
		end
		local leaves = trees_to_capitate[tr][2]
		local range = trees_to_capitate[tr][3]
		local fruits = trees_to_capitate[tr][4]
		for i = -range,range,1 do	--definition of the leavesposition
			for j = -range-1,range-1,1 do
				for k = -range,range,1 do
					p = {x=np.x+i, y=np.y+j, z=np.z+k}
					nodename = minetest.env:get_node(p).name
					local foundnode = false
					for _, leaf in ipairs(leaves) do
						if nodename == leaf then
							local leaves_drops = minetest.get_node_drops(leaf)
							for _, itemname in ipairs(leaves_drops) do
								if itemname ~= leaf then
									dropitem(itemname, p, digger)
								end
							end
							minetest.env:remove_node(p)	--remove the leaves
							foundnode = true
							break
						end
					end
					if not foundnode then
						for _, fruit in ipairs(fruits) do
							if nodename == fruit then
								dropitem(fruit, p, digger)
								minetest.env:remove_node(p)	--remove the fruit
								break
							end
						end
					end
				end
			end
		end
	end
end)

print("[treecapitator] loaded")
