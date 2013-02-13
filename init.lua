local timber_nodenames={"default:jungletree","default:tree"}
local leaves_nodenames={"default:leaves"}
local size = 2	--2*size+1

minetest.register_on_dignode(function(pos, node)
	local i=1
	while timber_nodenames[i]~=nil do	--trunk stuff
		if node.name==timber_nodenames[i] then
			np={x=pos.x, y=pos.y+1, z=pos.z}
			while minetest.env:get_node(np).name==timber_nodenames[i] do
				minetest.env:remove_node(np)
				minetest.env:add_item(np, timber_nodenames[i])
				np={x=np.x, y=np.y+1, z=np.z}
			end
			for _, leaves in ipairs(leaves_nodenames) do	--definition of the leaves
				for i=-size,size,1 do	--definition of the leavesposition
					for j=-size,size,1 do
						for k=-size,size,1 do
						p={x=np.x+i, y=np.y-1+j, z=np.z+k}
							if minetest.env:get_node(p).name==leaves then
								itemstacks = minetest.get_node_drops(minetest.env:get_node(p).name)
								for _, itemname in ipairs(itemstacks) do
									if minetest.env:get_node(p).name ~= itemname then
										minetest.env:add_item(p, itemname)	--drop the items
									end
								end
								minetest.env:remove_node(p)	--remove the leaves
							end
						end
					end
				end
			end
		end
		i=i+1
	end
end)
