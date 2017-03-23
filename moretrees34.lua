-- This provides a workaround for the cutting leaves moretrees problem.

function treecapitator.moretrees34(trunktop_ps, trunks, tr, head_ps,
	get_node, is_trunk_of_tree
)
	local trees = tr.trees
	for i = 1,#trunktop_ps do
		-- add the usual trunks
		local pos = trunktop_ps[i]
		local node = get_node(pos)
		while is_trunk_of_tree(trees, node) do
			trunks[#trunks+1] = {pos, node}
			pos = {x=pos.x, y=pos.y+1, z=pos.z}
			node = get_node(pos)
		end

		-- meddle with the lacunarity
		local ys = pos.y
		local ye
		local detected_trunks = {}

		-- search upwards until the gap is big enough or the tree ended
		local foundleaves = 0
		while true do
			if is_trunk_of_tree(trees, node) then
				foundleaves = 0
				detected_trunks[pos.y] = node
				pos.y = pos.y+1
				node = get_node(pos)
			elseif tr.leaves ^ node.name
			or tr.fruits ^ node.name then
				foundleaves = foundleaves+1
				if foundleaves > tr.cutting_leaves then
					-- cutting leaves count exceeded
					ye = pos.y-foundleaves
					break
				end
				pos.y = pos.y+1
				node = get_node(pos)
			else
				-- above the tree
				ye = pos.y-1
				break
			end
		end

		-- search downwards until enough trunks are found above each other
		-- or no such trunks are found
		local ytop = ys-1
		local y = ye
		local last_test = ys + tr.stem_height_min
		while y >= last_test do
			if detected_trunks[y] then
				local too_short
				for ty = y - tr.stem_height_min + 1, y-1 do
					if not detected_trunks[y] then
						too_short = true
						y = ty-1
						break
					end
				end
				if not too_short then
					-- upper end found
					ytop = y
					break
				end
			end
			y = y-1
		end

		if ytop >= ys then
			-- add trunks and leaves/fruits
			for y = ys, ytop do
				local p = {x=pos.x, y=y, z=pos.z}
				if detected_trunks[y] then
					trunks[#trunks+1] = {p, detected_trunks[y]}
				else
					head_ps[#head_ps+1] = p
				end
			end
		end

		-- renew trunk top position
		pos.y = ytop
		trunktop_ps[i] = pos
	end
end
