local load_time_start = minetest.get_us_time()


------------------------------------- Settings ---------------------------------

-- default settings
treecapitator = {
	drop_items = false,
	drop_leaf = false,
	play_sound = true,
	moretrees_support = false,
	no_hand_capitation = false,
	delay = 0,
	stem_height_min = 3,
	default_tree = {	--replaces not defined stuff (see below)
		trees = {"default:tree"},
		leaves = {"default:leaves"},
		range = 2,
		fruits = {},
		type = "default",
	},
	after_register = {},
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

local function hash2(x, y)
	return y * 0x10000 + x
end

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
	if minetest.setting_getbool"creative_mode" then
		function drop_leaf(_, item, inv)
			if inv
			and inv:room_for_item("main", item)
			and not inv:contains_item("main", item) then
				inv:add_item("main", item)
			end
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
	return node.param2 == 0
		and trees ^ node.name
end

-- test if the trunk node there is the top trunk node of a neighbour tree
-- if so, constrain the possible leaves positions
local function get_a_tree(pos, tab, tr, xo,yo,zo)
	local p = {x=pos.x + xo, y=pos.y + yo, z=pos.z + zo}

	-- tests if a trunk is at the current pos
	local nd = get_node(p)
	if not is_trunk_of_tree(tr.trees, nd) then
		return false
	end

	-- search for a leaves or fruit node next to the trunk
	local leaf = get_node{x=p.x, y=p.y+1, z=p.z}.name
	if not tr.leaves ^ leaf
	and not tr.fruits ^ leaf then
		local leaf = get_node{x=p.x, y=p.y, z=p.z+1}.name
		if not tr.leaves ^ leaf
		and not tr.fruits ^ leaf then
			return false
		end
	end

	-- search for the requisite amount of stem trunk nodes
	for _ = 1, tr.stem_height_min-1 do
		p.y = p.y-1
		if not is_trunk_of_tree(tr.trees, get_node(p)) then
			return false
		end
	end
	p.y = p.y + tr.stem_height_min-1

	local r = tr.range
	local r_up = tr.range_up or r
	local r_down = tr.range_down or r

	-- reduce x and z avoidance range for thick stem neighbour trees
	if tr.stem_type == "2x2" then
		r = r - 1
	elseif tr.stem_type == "+" then
		r = r - 2
	end

	-- tag places which should not be removed
	local z1 = math.max(-r + zo, -r)
	local z2 = math.min(r + zo, r)
	local y1 = math.max(-r_down + yo, -r_down)
	local y2 = math.min(r_up + yo, r_up)
	local x1 = math.max(-r + xo, -r)
	local x2 = math.min(r + xo, r)
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

-- returns positions for leaves allowed to be dug
local function find_valid_head_ps(pos, head_ps, trunktop_ps, tr)
	-- exclude the stem nodes
	local before_stems = {}
	for i = 1,#trunktop_ps do
		local p = vector.subtract(trunktop_ps[i], pos)
		before_stems[hash2(p.x, p.z)] = p.y+1
	end

	local r = tr.range
	local r_up = tr.range_up or r
	local r_down = tr.range_down or r

	-- firstly, detect neighbour trees of the same sort to not hurt them
	local tab = {}
	local rx2 = 2 * r
	local rupdown = r_up + r_down
	for z = -rx2, rx2 do
		for x = -rx2, rx2 do
			local bot = before_stems[hash2(x, z)] or -rupdown
			for y = rupdown, bot, -1 do
				if get_a_tree(pos, tab, tr, x,y,z) then
					break
				end
			end
		end
	end
	-- now, get the head positions without the neighbouring trees
	local n = #head_ps
	for z = -r,r do
		for x = -r,r do
			local bot = before_stems[hash2(x, z)] or -r_down
			for y = bot,r_up do
				local p = {x=x, y=y, z=z}
				if not tab[poshash(p)] then
					n = n+1
					head_ps[n] = vector.add(pos, p)
				end
			end
		end
	end
	return n
end

-- adds the stem to the trunks
local function get_stem(trunktop_ps, trunks, tr, head_ps)
	if tr.cutting_leaves then
		treecapitator.moretrees34(trunktop_ps, trunks, tr, head_ps,
			get_node, is_trunk_of_tree)
		return
	end
	for i = 1,#trunktop_ps do
		local pos = trunktop_ps[i]
		local node = get_node(pos)
		while is_trunk_of_tree(tr.trees, node) do
			trunks[#trunks+1] = {pos, node}
			pos = {x=pos.x, y=pos.y+1, z=pos.z}
			node = get_node(pos)
		end

		-- renew trunk top position
		pos.y = pos.y-1
		trunktop_ps[i] = pos
	end
end

-- part of healthy stem searching
local function here_neat_stemps(p, tr)
	local ps = {}
	for i = 1,#tr.stem_offsets do
		local o = tr.stem_offsets[i]
		local p = {x = p.x + o[1], y = p.y, z = p.z + o[2]}
		-- air test is too simple (makeshift solution)
		if get_node(p).name ~= "air" then
			return
		end
		p.y = p.y+1
		if not is_trunk_of_tree(tr.trees, get_node(p)) then
			return
		end
		ps[#ps+1] = p
	end
	return ps
end

-- gives stem positions of a healthy tree
local function find_neat_stemps(pos, tr)
	for i = 1,#tr.stem_offsets do
		local o = tr.stem_offsets[i]
		local p = {x = pos.x - o[1], y = pos.y, z = pos.z - o[2]}
		local ps = here_neat_stemps(p, tr)
		if ps then
			return ps
		end
	end
	-- nothing found
end

-- part of incomplete stem searching
local function here_incomplete_stemps(p, tr)
	local ps = {}
	for i = 1,#tr.stem_offsets do
		local o = tr.stem_offsets[i]
		local p = {x = p.x + o[1], y = p.y+1, z = p.z + o[2]}
		if is_trunk_of_tree(tr.trees, get_node(p)) then
			p.y = p.y-1
			local node = get_node(p)
			if is_trunk_of_tree(tr.trees, node) then
				-- stem wasn't chopped enough
				return {}
			end
			-- air test is too simple (makeshift solution)
			if node.name == "air" then
				p.y = p.y+1
				ps[#ps+1] = p
			end
		end
	end
	-- #ps ∈ [3]
	return ps
end

-- gives stem positions of an eroded tree
local function find_incomplete_stemps(pos, tr)
	local ps
	local stemcount = 0
	for i = 1,#tr.stem_offsets do
		local o = tr.stem_offsets[i]
		local p = {x = pos.x - o[1], y = pos.y, z = pos.z - o[2]}
		local cps = here_incomplete_stemps(p, tr)
		local cnt = #cps
		if cnt == 0 then
			-- player needs to chop more
			return
		end
		if stemcount < cnt then
			stemcount = #cps
			ps = cps
		end
	end
	return ps
end

-- returns the lowest trunk node positions
local function get_stem_ps(pos, tr)
	if not tr.stem_type then
		-- 1x1 stem
		return {{x=pos.x, y=pos.y+1, z=pos.z}}
	end
	return find_neat_stemps(pos, tr)
		or find_incomplete_stemps(pos, tr)
end

-- gets the middle position of the tree head
local function get_head_center(trunktop_ps, stem_type)
	if stem_type == "2x2" then
		-- return the highest position
		local pos = trunktop_ps[1]
		for i = 2,#trunktop_ps do
			local p = trunktop_ps[i]
			if p.y > pos.y then
				pos = p
			end
		end
		return pos
	elseif stem_type == "+" then
		-- return the middle position
		local mid = vector.new()
		for i = 1,#trunktop_ps do
			mid = vector.add(mid, trunktop_ps[i])
		end
		return vector.round(vector.divide(mid, #trunktop_ps))
	else
		return trunktop_ps[1]
	end
end

function capitate_funcs.default(pos, tr, _, digger)
	local trees = tr.trees

	-- get the stem trunks
	local trunks = {}
	local trunktop_ps = get_stem_ps(pos, tr)
	if not trunktop_ps then
		return
	end
	local head_ps = {}
	get_stem(trunktop_ps, trunks, tr, head_ps)

	local leaves = tr.leaves
	local fruits = tr.fruits
	local hcp = get_head_center(trunktop_ps, tr.stem_type)

	-- abort if the tree lacks leaves/fruits
	local ln = get_node{x=hcp.x, y=hcp.y+1, z=hcp.z}
	if not leaves ^ ln.name
	and not fruits ^ ln.name then
		local leaf = get_node{x=hcp.x, y=hcp.y, z=hcp.z+1}.name
		if not leaves ^ leaf
		and not fruits ^ leaf then
			return
		end
	end

	-- get leaves, fruits and stem fruits
	local leaves_found = {}
	local n = find_valid_head_ps(hcp, head_ps, trunktop_ps, tr)
	local leaves_toremove = {}
	local fruits_toremove = {}
	for i = 1,n do
		local p = head_ps[i]
		local node = get_node(p)
		local nodename = node.name
		local is_trunk = trees ^ nodename
		if node.param2 ~= 0
		or not is_trunk then
			if leaves ^ nodename then
				leaves_found[nodename] = true
				leaves_toremove[#leaves_toremove+1] = {p, node}
			elseif fruits ^ nodename then
				fruits_toremove[#fruits_toremove+1] = {p, node}
			end
		elseif is_trunk
		and tr.trunk_fruit_vertical
		and fruits ^ nodename then
			trunks[#trunks+1] = {p, node}
		end
	end

	if tr.requisite_leaves then
		-- abort if specific leaves weren't found
		for i = 1,#tr.requisite_leaves do
			if not leaves_found[tr.requisite_leaves[i]] then
				return
			end
		end
	end

	-- remove fruits at first due to attachment
	-- and disable nodeupdate temporarily
	local nodeupdate = minetest.check_for_falling
	minetest.check_for_falling = function() end
	for i = 1,#fruits_toremove do
		destroy_node(fruits_toremove[i][1], fruits_toremove[i][2], digger)
	end
	minetest.check_for_falling = nodeupdate
	local inv = digger:get_inventory()
	for i = 1,#leaves_toremove do
		remove_leaf(leaves_toremove[i][1], leaves_toremove[i][2], inv, digger)
	end
	for i = 1,#trunks do
		destroy_node(trunks[i][1], trunks[i][2], digger)
	end

	-- tree was capitated, play sound
	if treecapitator.play_sound then
		minetest.sound_play("tree_falling", {pos = pos, max_hear_distance = 32})
	end
	return true
end

-- metatable for shorter code: trees ^ name ≙ name ∈ trees
local mt_default = {
	__pow = table_contains
}
treecapitator.after_register.default = function(tr)
	setmetatable(tr.trees, mt_default)
	setmetatable(tr.leaves, mt_default)
	setmetatable(tr.fruits, mt_default)
	tr.range_up = tr.range_up or tr.range
	tr.range_down = tr.range_down or tr.range
	tr.stem_height_min = tr.stem_height_min or treecapitator.stem_height_min

	if tr.stem_type == "2x2" then
		tr.stem_offsets = {
			{0,0}, {1,0},
			{0,1}, {1,1},
		}
	elseif tr.stem_type == "+" then
		tr.stem_offsets = {
			{0,0},
				{0,1},
			{-1,0},	{1,0},
				{0,-1},
		}
	end
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

	local inv = digger:get_inventory()
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


----------------------- Palm tree function -------------------------------------

-- the 17 vectors used for walking the stem
local palm_stem_dirs = {
	{0,1,0}
}
local n = 2
for i = -1,1,2 do
	palm_stem_dirs[n] = {i,0,0}
	palm_stem_dirs[n+1] = {0,0,i}
	n = n+2
end
for i = -1,1,2 do
	palm_stem_dirs[n] = {i,0,i}
	palm_stem_dirs[n+1] = {i,0,-i}
	n = n+2
end
for i = -1,1,2 do
	palm_stem_dirs[n] = {i,1,0}
	palm_stem_dirs[n+1] = {0,1,i}
	n = n+2
end
for i = -1,1,2 do
	palm_stem_dirs[n] = {i,1,i}
	palm_stem_dirs[n+1] = {i,1,-i}
	n = n+2
end
for i = 1,17 do
	local p = palm_stem_dirs[i]
	palm_stem_dirs[i] = vector.new(unpack(p))
end

local pos_from_hash = minetest.get_position_from_hash

-- gets a list of leaves positions
local function get_palm_head(hcp, tr, max_forbi)
	local pos = {x=hcp.x, y=hcp.y+1, z=hcp.z}
	local leaves = {}
	if get_node(pos).name ~= tr.leaves then
		-- search hub position
		for xo = -1,1 do
			for zo = -1,1 do
				local p = {x=pos.x+xo, y=pos.y, z=pos.z+zo}
				if get_node(p).name == tr.leaves then
					pos = p
				end
			end
		end
	end
	-- collect leaves
	leaves[poshash(pos)] = true
	for i = -1,1 do
		for j = -1,1 do
			-- don't search around the corner except max_forbi time(s)
			local dirs = {{0,0}, {i,0}, {0,j}, {i,j},  {-i,0}, {0,-j}}
			local avoids = {}
			local todo = {pos}
			local sp = 1
			while sp > 0 do
				local p = todo[sp]
				sp = sp-1
				-- only walk the "forbidden" dir if still allowed
				local forbic = avoids[poshash(p)] or 0
				local dirc = 6
				if forbic == max_forbi then
					dirc = dirc - 2
				end
				-- walk the directions
				for i = 1,dirc do
					-- increase forbidden when needed
					local forbinc = forbic
					if i > 4 then
						forbinc = forbinc+1
					end
					local xz = dirs[i]
					for y = -1,2 do
						local p = {x=p.x+xz[1], y=p.y+y, z=p.z+xz[2]}
						local ph = poshash(p)
						local forbi = avoids[ph]
						if not forbi
						or forbi > forbinc then
							avoids[ph] = forbinc
							local dif = vector.subtract(p, pos)
							if get_node(p).name == tr.leaves
							and math.abs(dif.x) <= tr.range
							and math.abs(dif.z) <= tr.range
							and dif.y <= tr.range_up
							and dif.y >= -tr.range_down then
								sp = sp+1
								todo[sp] = p
								leaves[ph] = true
							end
						end
					end
				end
			end
		end
	end
	local ps = {}
	local n = 0
	for ph in pairs(leaves) do
		n = n+1
		ps[n] = pos_from_hash(ph)
	end
	return ps,n
end

-- returns positions for palm leaves allowed to be dug
local function palm_find_valid_head_ps(pos, head_ps, tr)
	local r = tr.range
	local r_up = tr.range_up or r
	local r_down = tr.range_down or r

	-- firstly, detect neighbour palms' leaves to not hurt them
	local tab = {}
	local rx2 = 2 * r
	local rupdown = r_up + r_down
	for z = -rx2, rx2 do
		for y = -rupdown, rupdown do
			for x = -rx2, rx2 do
				local hcp = {x=pos.x+x, y=pos.y+y, z=pos.z+z}
				if not vector.equals(hcp, pos)
				and get_node(hcp).name == tr.trunk_top then
					local leaves,n = get_palm_head(hcp, tr, 0)
					for i = 1,n do
						tab[poshash(leaves[i])] = true
					end
				end
			end
		end
	end
	-- now, get the leaves positions without the neighbouring leaves
	local leaves,lc = get_palm_head(pos, tr, tr.max_forbi)
	local n = #head_ps
	for i = 1,lc do
		local p = leaves[i]
		if not tab[poshash(p)] then
			n = n+1
			head_ps[n] = p
		end
	end
	return n
end

function capitate_funcs.palm(pos, tr, node_above, digger)
	local trunk = tr.trees[1]

	-- walk the stem up to the fruit carrier
	pos = {x=pos.x, y=pos.y+1, z=pos.z}
	local trunks = {{pos, node_above}}
	local trunk_found = true
	local nohori = false
	local hcp
	while trunk_found
	and not hcp do
		trunk_found = false
		for i = 1,17 do
			local hori = i > 1 and i < 10
			if not hori
			or not nohori then
				local p = vector.add(pos, palm_stem_dirs[i])
				local node = get_node(p)
				if node.name == trunk then
					trunk_found = true
					trunks[#trunks+1] = {p, node}
					pos = p
					nohori = hori
					break
				end
				if node.name == tr.trunk_top then
					hcp = p
					trunks[#trunks+1] = {p, node}
					break
				end
			end
		end
	end
	if not hcp then
		return
	end

	-- collect coconuts
	local fruits = {}
	for zo = -1,1 do
		for xo = -1,1 do
			local p = {x=hcp.x+xo, y=hcp.y, z=hcp.z+zo}
			local node = get_node(p)
			if node.name:sub(1, #tr.fruit) == tr.fruit then
				fruits[#fruits+1] = {p, node}
			end
		end
	end

	-- find the leaves of the palm
	local leaves_ps = {}
	local lc = palm_find_valid_head_ps(hcp, leaves_ps, tr)

	if treecapitator.play_sound then
		minetest.sound_play("tree_falling", {pos = pos, max_hear_distance = 32})
	end

	local nodeupdate = minetest.check_for_falling
	minetest.check_for_falling = function() end
	for i = 1,#fruits do
		local pos,node = unpack(fruits[i])
		destroy_node(pos, node, digger)
	end
	minetest.check_for_falling = nodeupdate

	for i = 1,#trunks do
		local pos,node = unpack(trunks[i])
		destroy_node(pos, node, digger)
	end

	local inv = digger:get_inventory()
	for i = 1,lc do
		local pos = leaves_ps[i]
		remove_leaf(pos, get_node(pos), inv, digger)
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
	or digger:get_player_control().sneak
	or not treecapitator.capitation_allowed(pos, digger) then
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
dofile(path .. "moretrees34.lua")


local time = (minetest.get_us_time() - load_time_start) / 1000000
local msg = "[treecapitator] loaded after ca. " .. time .. " seconds."
if time > 0.01 then
	print(msg)
else
	minetest.log("info", msg)
end
