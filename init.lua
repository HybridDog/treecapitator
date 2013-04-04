treecapitator = {}

-------------------------------------------Settings--------------------------------------------
treecapitator.drop_items = true	--drop them / get them in the inventory
local	timber_nodenames = {"default:jungletree","default:tree"}
local	leaves_nodenames = {"default:leaves","default:jungleleaves"}
local	fruit_nodenames  = {"default:apple"}
local	size = 2	--2*size+1
-----------------------------------------------------------------------------------------------

local function dropitem(item, posi, digger)
	if treecapitator.drop_items then
		minetest.env:add_item(posi, item)
	else
		digger:get_inventory():add_item('main', item)
	end
end

minetest.register_on_dignode(function(pos, node, digger)
	local i=1
	while timber_nodenames[i]~=nil do	--trunk stuff
		if node.name==timber_nodenames[i] then
			np={x=pos.x, y=pos.y+1, z=pos.z}
			while minetest.env:get_node(np).name==timber_nodenames[i] do
				minetest.env:remove_node(np)
				dropitem(timber_nodenames[i], np, digger)
				np.y = np.y+1
			end
			for i=-size,size,1 do	--definition of the leavesposition
				for j=-size,size,1 do
					for k=-size,size,1 do
					p={x=np.x+i, y=np.y-1+j, z=np.z+k}
						for _, leaves in ipairs(leaves_nodenames) do	--definition of the leaves
							if minetest.env:get_node(p).name==leaves then
								itemstacks = minetest.get_node_drops(minetest.env:get_node(p).name)
								for _, itemname in ipairs(itemstacks) do
									if minetest.env:get_node(p).name ~= itemname then
										dropitem(itemname, p, digger)
									end
								end
								minetest.env:remove_node(p)	--remove the leaves
							end
						end
						for _, fruit in ipairs(fruit_nodenames) do	--definition of the fruits
							if minetest.env:get_node(p).name==fruit then
								dropitem(fruit, p, digger)
								minetest.env:remove_node(p)	--remove the fruit
							end
						end
					end
				end
			end
		end
		i=i+1
	end
end)
