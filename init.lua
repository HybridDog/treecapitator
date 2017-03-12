local load_time_start = minetest.get_us_time()


------------------------------------- Settings ---------------------------------

-- default settings
treecapitator = {
	drop_items = false,
	drop_leaf = false,
	play_sound = true,
	moretrees_support = false,
	delay = 0,
	default_tree = {	--replaces not defined stuff (see below)
		trees = {"default:tree"},
		leaves = {"default:leaves"},
		range = 2,
		fruits = {},
		type = "default",
	},
}

-- load custom settings
for name,v in pairs(treecapitator) do
	local setting = "treecapitator." .. name
	--local typ = type(v)
	local neuv
	if type(v) == "boolean" then
		neuv = minetest.setting_getbool(setting)
	else--if typ == "number" then
		neuv = tonumber(minetest.setting_get(setting))
	end
	if neuv ~= nil then
		treecapitator[name] = neuv
	end
end


-------------------------- Common functions ------------------------------------

local poshash = minetest.hash_node_position

--~ local function hash2(x, y)
	--~ return y * 0x10000 + x
--~ end

-- don't use minetest.get_node more times for the same position (caching)
local known_nodes
local function clean_cache()
	known_nodes = {}
	setmetatable(known_nodes, {__mode = "kv"})
end
clean_cache()

local function remove_node(pos)
	known_nodes[poshash(pos)] = {name="air", param2=0}
	minetest.remove_node(pos)
	minetest.check_for_falling(pos)
end

local function get_node(pos)
	local vi = poshash(pos)
	local node = known_nodes[vi]
	if node then
		return node
	end
	node = minetest.get_node(pos)
	known_nodes[vi] = node
	return node
end

--definitions of functions for the destruction of nodes
local destroy_node, drop_leaf, remove_leaf
if treecapitator.drop_items then
	function drop_leaf(pos, item)
		minetest.add_item(pos, item)
	end

	function destroy_node(pos, node)
		local drops = minetest.get_node_drops(node.name)
		for _,item in pairs(drops) do
			minetest.add_item(pos, item)
		end
		remove_node(pos)
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

	destroy_node = function(pos, node, digger)
		known_nodes[poshash(pos)] = {name="air", param2=0}
		minetest.node_dig(pos, node, digger)
	end
end

if not treecapitator.drop_leaf then
	function remove_leaf(pos, node, inv)
		local leaves_drops = minetest.get_node_drops(node.name)
		for _, itemname in pairs(leaves_drops) do
			if itemname ~= node.name then
				drop_leaf(pos, itemname, inv)
			end
		end
		remove_node(pos)	--remove the leaves
	end
else
	function remove_leaf(pos, node, _, digger)
		destroy_node(pos, node, digger)
	end
end


table_contains = function(t, v)
	for i = 1,#t do
		if t[i] == v then
			return true
		end
	end
	return false
end


-- the functions for the available types
local capitate_funcs = {}


------------------------ Function for regular trees ----------------------------

-- tests if the node is a trunk which could belong to the same tree sort
local function is_trunk_of_tree(trees, node)
	return table_contains(trees, node.name)
		and node.param2 == 0
end

-- test if the trunk node there is the top trunk node of a neighbour tree
-- if so, constrain the possible leaves positions
local function get_a_tree(pos, tab, tr, i,h,j)
	local p = {x=pos.x+j, y=pos.y+h, z=pos.z+i}

	-- tests if a trunk is at the current pos and below it
	local nd = get_node(p)
	if not is_trunk_of_tree(tr.trees, nd)
	or not is_trunk_of_tree(tr.trees, get_node{x=p.x, y=p.y-1, z=p.z}) then
		return false
	end

	-- search for a leaves or fruit node next to the trunk
	local leaf = get_node{x=p.x, y=p.y+1, z=p.z}.name
	if not table_contains(tr.leaves, leaf)
	and not table_contains(tr.fruits, leaf) then
		local leaf = get_node{x=p.x, y=p.y, z=p.z+1}.name
		if not table_contains(tr.leaves, leaf)
		and not table_contains(tr.fruits, leaf) then
			return false
		end
	end

	local r = tr.range
	local r_up = tr.range_up or r
	local r_down = tr.range_down or r

	-- tag places which should not be removed
	local z1 = math.max(-r + i, -r)
	local z2 = math.min(r + i, r)
	local y1 = math.max(-r_down + h, -r_down)
	local y2 = math.min(r_up + h, r_up)
	local x1 = math.max(-r + j, -r)
	local x2 = math.min(r + j, r)
	for z = z1,z2 do
		for y = y1,y2 do
			local i = poshash{x=x1, y=y, z=z}
			for _ = x1,x2 do
				tab[i] = true
				i = i+1
			end
		end
	end
	return true
end

--returns positions for leaves allowed to be dug
local function find_valid_head_ps(pos, tr)
	local r = tr.range
	local r_up = tr.range_up or r
	local r_down = tr.range_down or r

	-- firstly, detect neighbour trees of the same sort to not hurt them
	local tab = {}
	local rx2 = 2 * r
	local rupdown = r_up + r_down
	for z = -rx2, rx2 do
		for x = -rx2, rx2 do
			local bot = -rupdown
			if z == 0
			and x == 0 then
				-- only detect neighbours
				bot = 1
			end
			for y = rupdown, bot, -1 do
				if get_a_tree(pos, tab, tr, x,y,z) then
					break
				end
			end
		end
	end
	-- now, get the head positions without the neighbouring trees
	local tab2,n = {},1
	for z = -r,r do
		for x = -r,r do
			local bot = -r_down
			if x == 0
			and z == 0 then
				-- avoid adding the stem
				bot = 1
			end
			for y = bot,r_up do
				local p = {x=x, y=y, z=z}
				if not tab[poshash(p)] then
					tab2[n] = p
					n = n+1
				end
			end
		end
	end
	return tab2, n-1
end

function capitate_funcs.default(pos, tr, node_above, digger)
	local trees = tr.trees

	-- get the stem trunks
	local trunks, n = {{{x=pos.x, y=pos.y+1, z=pos.z}, node_above}}, 2
	local np = {x=pos.x, y=pos.y+2, z=pos.z}
	local nd = get_node(np)
	while table_contains(trees, nd.name) and nd.param2 == 0 do
		trunks[n] = {vector.new(np), nd}
		n = n+1
		np.y = np.y+1
		nd = get_node(np)
	end
	np.y = np.y-1

	local leaves = tr.leaves
	local fruits = tr.fruits

	-- abort if the tree lacks leaves/fruits
	if not table_contains(leaves, nd.name)
	and not table_contains(fruits, nd.name) then
		local leaf = get_node{x=np.x, y=np.y, z=np.z+1}.name
		if not table_contains(leaves, leaf)
		and not table_contains(fruits, leaf) then
			return
		end
	end

	-- play the sound, then dig the stem
	if treecapitator.play_sound then
		minetest.sound_play("tree_falling", {pos = pos, max_hear_distance = 32})
	end

	-- get leaves, fruits and stem fruits
	local head_ps
	head_ps,n = find_valid_head_ps(np, tr)
	local leaves_toremove = {}
	local fruits_toremove = {}
	for i = 1,n do
		local p = vector.add(np, head_ps[i])
		local node = get_node(p)
		local nodename = node.name
		local is_trunk = table_contains(trees, nodename)
		if node.param2 ~= 0
		or not is_trunk then
			if table_contains(leaves, nodename) then
				leaves_toremove[#leaves_toremove+1] = {p, node}
			elseif table_contains(fruits, nodename) then
				fruits_toremove[#fruits_toremove+1] = {p, node}
			end
		elseif is_trunk
		and tr.trunk_fruit_vertical
		and table_contains(fruits, nodename)
		and not table_contains(trees, get_node{x=p.x, y=p.y+1, z=p.z})
		and not table_contains(trees, get_node{x=p.x, y=p.y-1, z=p.z}) then
			trunks[#trunks+1] = {p, node}
		end
	end

	-- remove fruits at first due to attachment (somehow still doesn't work)
	for i = 1,#fruits_toremove do
		destroy_node(fruits_toremove[i][1], fruits_toremove[i][2], digger)
	end
	local inv = digger:get_inventory()
	for i = 1,#leaves_toremove do
		remove_leaf(leaves_toremove[i][1], leaves_toremove[i][2], inv, digger)
	end
	for i = 1,#trunks do
		destroy_node(trunks[i][1], trunks[i][2], digger)
	end
	return true
end


--------------------- Acacia tree function -------------------------------------

function capitate_funcs.acacia(pos, tr, node_above, digger)
	local trunk = tr.trees[1]

	-- fill tab with the stem trunks
	local tab, n = {{{x=pos.x, y=pos.y+1, z=pos.z}, node_above}}, 2
	local np = {x=pos.x, y=pos.y+2, z=pos.z}
	local nd = get_node(np)
	while trunk == nd.name
	and nd.param2 < 4 do
		tab[n] = {vector.new(np), nd}
		n = n+1
		np.y = np.y+1
		nd = get_node(np)
	end
	np.y = np.y-1

	for z = -1,1,2 do
		for x = -1,1,2 do
			-- add the other trunks to tab
			local p = vector.new(np)
			p.x = p.x+x
			p.z = p.z+z
			local nd = get_node(p)
			if nd.name ~= trunk then
				p.y = p.y+1
				nd = get_node(p)
				if nd.name ~= trunk then
					return
				end
			end
			tab[n] = {vector.new(p), nd}

			p.x = p.x+x
			p.z = p.z+z
			p.y = p.y+1

			if get_node(p).name ~= trunk then
				return
			end
			tab[n+1] = {vector.new(p), nd}
			n = n+2

			-- get neighbouring acacia trunks for delimiting
			local no_rms = {}
			for z = -4,4 do
				for x = -4,4 do
					if math.abs(x+z) ~= 8
					and (x ~= 0 or z ~= 0) then
						if get_node{x=p.x+x, y=p.y, z=p.z+z}.name == trunk
						and get_node{x=p.x+x, y=p.y+1, z=p.z+z}.name == tr.leaf then
							for z = math.max(-4, z-2), math.min(4, z+2) do
								for x = math.max(-4, x-2), math.min(4, x+2) do
									no_rms[(z+4)*9 + x+4] = true
								end
							end
						end
					end
				end
			end

			-- remove leaves
			local inv = digger:get_inventory()
			p.y = p.y+1
			local i = 0
			for z = -4,4 do
				for x = -4,4 do
					if not no_rms[i] then
						local p = {x=p.x+x, y=p.y, z=p.z+z}
						local node = get_node(p)
						if node.name == tr.leaf then
							remove_leaf(p, node, inv, digger)
						end
					end
					i = i+1
				end
			end
		end
	end

	-- play the sound, then dig the stem
	if treecapitator.play_sound then
		minetest.sound_play("tree_falling", {pos = pos, max_hear_distance = 32})
	end
	for i = 1,n-1 do
		local pos,node = unpack(tab[i])
		destroy_node(pos, node, digger)
	end
	return true
end


---------------------- A moretrees capitation function -------------------------

-- table iteration instead of recursion
local function get_tab(pos, func, max)
	local todo = {pos}
	local n = 1
	local tab_avoid = {[poshash(pos)] = true}
	local tab_done,num = {pos},2
	while n ~= 0 do
		local p = todo[n]
		n = n-1
		--[[
		for i = -1,1,2 do
			for _,p2 in pairs{
				{x=p.x+i, y=p.y, z=p.z},
				{x=p.x, y=p.y+i, z=p.z},
				{x=p.x, y=p.y, z=p.z+i},
			} do]]
		for i = -1,1 do
			for j = -1,1 do
				for k = -1,1 do
					local p2 = {x=p.x+i, y=p.y+j, z=p.z+k}
					local vi = poshash(p2)
					if not tab_avoid[vi]
					and func(p2) then
						n = n+1
						todo[n] = p2

						tab_avoid[vi] = true

						tab_done[num] = p2
						num = num+1

						if max
						and num > max then
							return false
						end
					end
				end
			end
		end
	end
	return tab_done
end

function capitate_funcs.moretrees(pos, tr, _, digger)
	local trees = tr.trees
	local leaves = tr.leaves
	local fruits = tr.fruits
	local minx = pos.x-tr.range
	local maxx = pos.x+tr.range
	local minz = pos.z-tr.range
	local maxz = pos.z+tr.range
	local maxy = pos.y+tr.height
	local num_trunks = 0
	local num_leaves = 0
	local ps = get_tab({x=pos.x, y=pos.y+1, z=pos.z}, function(pos)
		if pos.x < minx
		or pos.x > maxx
		or pos.z < minz
		or pos.z > maxz
		or pos.y > maxy then
			return false
		end
		local nam = get_node(pos).name
		if table_contains(trees, nam) then
			num_trunks = num_trunks+1
		elseif table_contains(leaves, nam) then
			num_leaves = num_leaves+1
		elseif not table_contains(fruits, nam) then
			return false
		end
		return true
	end, tr.max_nodes)
	if not ps then
		print"no ps found"
		return
	end
	if num_trunks < tr.num_trunks_min
	or num_trunks > tr.num_trunks_max then
		print("wrong trunks num: "..num_trunks)
		return
	end
	if num_leaves < tr.num_leaves_min
	or num_leaves > tr.num_leaves_max then
		print("wrong leaves num: "..num_leaves)
		return
	end
	if treecapitator.play_sound then
		minetest.sound_play("tree_falling", {pos = pos, max_hear_distance = 32})
	end
	local inv = digger:get_inventory()
	for _,p in pairs(ps) do
		local node = get_node(p)
		local nodename = node.name
		if table_contains(leaves, nodename) then
			remove_leaf(p, node, inv, digger)
		else
			destroy_node(p, node, digger)
		end
	end
	return true
end


--------------------------- api interface --------------------------------------

-- the function which is used for capitating the api
local capitating = false	--necessary if minetest.node_dig is used
function treecapitator.capitate_tree(pos, digger)
	if capitating
	or not digger
	or digger:get_player_control().sneak then
		return
	end
	local t1 = minetest.get_us_time()
	capitating = true
	local node_above = get_node{x=pos.x, y=pos.y+1, z=pos.z}
	for i = 1,#treecapitator.trees do
		local tr = treecapitator.trees[i]
		if table_contains(tr.trees, node_above.name)
		and node_above.param2 < 4
		and capitate_funcs[tr.type](pos, tr, node_above, digger) then
			break
		end
	end
	clean_cache()
	capitating = false
	minetest.log("info", "[treecapitator] tree capitated at (" ..
		pos.x .. "|" .. pos.y .. "|" .. pos.z .. ") after ca. " ..
		(minetest.get_us_time() - t1) / 1000000 .. " s")
end

-- delayed capitating
local delay = treecapitator.delay
if delay > 0 then
	local oldfunc = treecapitator.capitate_tree
	function treecapitator.capitate_tree(...)
		minetest.after(delay, function(...)
			oldfunc(...)
		end, ...)
	end
end


local path = minetest.get_modpath"treecapitator" .. DIR_DELIM
dofile(path .. "api.lua")
dofile(path .. "trees.lua")


local time = (minetest.get_us_time() - load_time_start) / 1000000
local msg = "[treecapitator] loaded after ca. " .. time .. " seconds."
if time > 0.01 then
	print(msg)
else
	minetest.log("info", msg)
end
