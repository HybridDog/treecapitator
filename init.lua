treecapitator = {}


--------------------------------------Setting-----------------------------------------------

treecapitator.drop_items = false	--drop them / get them in the inventory

---------------------------------------------------------------------------------------------


treecapitator.trees = {}
treecapitator.num = 1

 --replaces not defined stuff
local function set_tree_defaults(tab)
	if not tab.trees then
		tab.trees = {"default:tree"}
	end
	if not tab.leaves then
		tab.leaves = {"default:leaves"}
	end
	if not tab.range then
		tab.range = 2
	end
	if not tab.fruits then
		tab.fruits = {}
	end
	return tab
end

function treecapitator.register_tree(tab)
	tab = set_tree_defaults(tab)
	local num = treecapitator.num
	treecapitator.trees[num] = tab
	treecapitator.num = num+1
end

dofile(minetest.get_modpath("treecapitator").."/trees.lua")


--------------------------------------------fcts----------------------------------------------


if treecapitator.drop_items then
	function treecapitator.drop_leaf(pos, item, inv)
		minetest.add_item(pos, item)
	end

	function treecapitator.destroy_node(pos, node, digger)
		local drops = minetest.get_node_drops(node.name)
		for _,item in ipairs(drops) do
			minetest.add_item(pos, item)
		end
		minetest.remove_node(pos)
	end
else
	function treecapitator.drop_leaf(pos, item, inv)
		if inv
		and inv:room_for_item("main", item) then
			inv:add_item("main", item)
		else
			minetest.add_item(pos, item)
		end
	end

	function treecapitator.destroy_node(pos, node, digger)
		minetest.node_dig(pos, node, digger)
	end
end


local function table_contains(t, v)
	for _,i in ipairs(t) do
		if i == v then
			return true
		end
	end
	return false
end

local function findtree(nodename)
	for _,tr in ipairs(treecapitator.trees) do
		if table_contains(tr.trees, nodename) then
			return true
		end
	end
	return false
end


minetest.register_on_dignode(function(pos, node, digger)
	if digger == nil then
		return
	end
    if digger:get_player_control().sneak
    or (not findtree(node.name)) then
		return
	end
	local t1 = os.clock()
	local np = {x=pos.x, y=pos.y+1, z=pos.z}
	for _,tr in ipairs(treecapitator.trees) do
		while table_contains(tr.trees, minetest.get_node(np).name) do
			local tree = minetest.get_node(np)
			treecapitator.destroy_node(np, tree, digger)
			np.y = np.y+1
		end
		local leaves = tr.leaves
--		local range = change_range(pos, tr.range, tr.trees)
		local range = tr.range
		local fruits = tr.fruits
		local inv = digger:get_inventory()
		for i = -range,range,1 do	--definition of the leavesposition
			for j = -range-1,range-1,1 do
				for k = -range,range,1 do
					p = {x=np.x+i, y=np.y+j, z=np.z+k}
					node = minetest.get_node(p)
					nodename = node.name
					local foundnode = false
					for _, leaf in ipairs(leaves) do
						if nodename == leaf then
							local leaves_drops = minetest.get_node_drops(leaf)
							for _, itemname in ipairs(leaves_drops) do
								if itemname ~= leaf then
									treecapitator.drop_leaf(p, itemname, inv)
								end
							end
							minetest.remove_node(p)	--remove the leaves
							foundnode = true
							break
						end
					end
					if not foundnode then
						for _,fruit in ipairs(fruits) do
							if nodename == fruit then
								treecapitator.destroy_node(p, node, digger) --remove the fruit
								break
							end
						end
					end
				end
			end
		end
	end
	print(string.format("[treecapitator] tree capitated at ("..pos.x.."|"..pos.y.."|"..pos.z..") after ca. %.2fs", os.clock() - t1))
end)

print("[treecapitator] loaded")
