local load_time_start = os.clock()
treecapitator = {}


--------------------------------------Setting-----------------------------------------------

treecapitator.drop_items = false	--drop them / get them in the inventory
treecapitator.drop_leaf = false

---------------------------------------------------------------------------------------------


treecapitator.trees = {}
local num = 1

 --replaces not defined stuff
local function set_tree_defaults(tab)
	tab.trees = tab.trees or {"default:tree"}
	tab.leaves = tab.leaves or {"default:leaves"}
	tab.range = tab.range or 2
	tab.fruits = tab.fruits or {}
	return tab
end

function treecapitator.register_tree(tab)
	tab = set_tree_defaults(tab)
	treecapitator.trees[num] = tab
	num = num+1
end

dofile(minetest.get_modpath("treecapitator").."/trees.lua")


--------------------------------------------fcts----------------------------------------------

local destroy_node, drop_leaf, remove_leaf
if treecapitator.drop_items then
	function drop_leaf(pos, item, inv)
		minetest.add_item(pos, item)
	end

	function destroy_node(pos, node, digger)
		local drops = minetest.get_node_drops(node.name)
		for _,item in ipairs(drops) do
			minetest.add_item(pos, item)
		end
		minetest.remove_node(pos)
	end
else
	function drop_leaf(pos, item, inv)
		if inv
		and inv:room_for_item("main", item) then
			inv:add_item("main", item)
		else
			minetest.add_item(pos, item)
		end
	end

	function destroy_node(pos, node, digger)
		minetest.node_dig(pos, node, digger)
	end
end

if not treecapitator.drop_leaf then
	function remove_leaf(p, leaf, inv)
		local leaves_drops = minetest.get_node_drops(leaf)
		for _, itemname in ipairs(leaves_drops) do
			if itemname ~= leaf then
				drop_leaf(p, itemname, inv)
			end
		end
		minetest.remove_node(p)	--remove the leaves
	end
else
	function remove_leaf(p, _, _, node, digger)
		destroy_node(p, node, digger)
	end
end

table.icontains = table.icontains or function(t, v)
	for _,i in ipairs(t) do
		if i == v then
			return true
		end
	end
	return false
end

local function findtree(nodename)
	for _,tr in ipairs(treecapitator.trees) do
		if table.icontains(tr.trees, nodename) then
			return true
		end
	end
	return false
end

local function find_next_trees(range, pos, trees)
	local r = 2*range
	local maxx, maxz = r, r
	local minx, minz = -maxx, -maxz
	for i = -r, r do
		for j = -r, r do
			for h = -1,1 do
				if table.icontains(trees, minetest.get_node({x=pos.x+j, y=pos.y+h, z=pos.z+i}).name) then
					if j > 0 then
						maxx = math.min(maxx, j)
					elseif j < 0 then
						minx = math.max(minx, j)
					end
					if i > 0 then
						maxz = math.min(maxz, i)
					elseif i < 0 then
						minz = math.max(minz, i)
					end
					break
				end
			end
		end
	end
	maxx = maxx-range
	maxz = maxz-range
	minx = minx+range
	minz = minz+range
	return minx, minz, maxx, maxz
end


minetest.register_on_dignode(function(pos, node, digger)
	if digger == nil then
		return
	end
    if digger:get_player_control().sneak
    or not findtree(node.name) then
		return
	end
	local t1 = os.clock()
	local np = {x=pos.x, y=pos.y+1, z=pos.z}
	for _,tr in ipairs(treecapitator.trees) do
		local nd = minetest.get_node(np)
		local trees = tr.trees
		local tree_found = table.icontains(trees, nd.name)
		if tree_found then
			local tab, n = {}, 1
			while tree_found do
				tab[n] = {vector.new(np), nd}
				n = n+1
				np.y = np.y+1
				nd = minetest.get_node(np)
				tree_found = table.icontains(trees, nd.name)
			end
			local leaves = tr.leaves
			local fruits = tr.fruits
			if not table.icontains(leaves, nd.name)
			and not table.icontains(fruits, nd.name) then
				return
			end
			for _,i in ipairs(tab) do
				destroy_node(i[1], i[2], digger)
			end
--			local range = change_range(pos, tr.range, tr.trees)
			local range = tr.range
			local minx, minz, maxx, maxz = find_next_trees(range, pos, trees)
			local inv = digger:get_inventory()
			for i = minz, maxz do	--definition of the leavesposition
				for j = -range-1, range-1 do
					for k = minx, maxx do
						local p = {x=np.x+k, y=np.y+j, z=np.z+i}
						local node = minetest.get_node(p)
						local nodename = node.name
						local foundnode = false
						for _, leaf in ipairs(leaves) do
							if nodename == leaf then
								remove_leaf(p, leaf, inv, node, digger)
								foundnode = true
								break
							end
						end
						if not foundnode then
							for _,fruit in ipairs(fruits) do
								if nodename == fruit then
									destroy_node(p, node, digger) --remove the fruit
									break
								end
							end
						end
					end
				end
			end
		end
	end
	print(string.format("[treecapitator] tree capitated at ("..pos.x.."|"..pos.y.."|"..pos.z..") after ca. %.2fs", os.clock() - t1))
end)

print(string.format("[treecapitator] loaded after ca. %.2fs", os.clock() - load_time_start))
