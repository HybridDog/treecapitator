local mgname = minetest.get_mapgen_setting"mg_name"

if mgname == "v6" then
	treecapitator.register_tree{
		trees = {"default:tree"},
		leaves = {"default:leaves"},
		range = 2,
		fruits = {"default:apple"}
	}

	treecapitator.register_tree({
		trees = {"default:jungletree"},
		leaves = {"default:jungleleaves"},
		range = 3
	})
else
	treecapitator.register_tree{
		trees = {"default:tree"},
		leaves = {"default:leaves"},
		range = 2,
		range_up = 4,
		range_down = 0,
		fruits = {"default:apple", "default:tree"},
		trunk_fruit_vertical = true
	}

	treecapitator.register_tree({
		trees = {"default:jungletree"},
		leaves = {"default:jungleleaves"},
		fruits = {"default:jungletree"},
		range = 4,
		range_up = 14,
		range_down = 5,
		trunk_fruit_vertical = true,
		stem_height_min = 12,
	})

	treecapitator.register_tree({
		trees = {"default:jungletree"},
		leaves = {"default:jungleleaves"},
		fruits = {"default:jungletree"},
		range = 4,
		range_up = 14,
		range_down = 3,
		trunk_fruit_vertical = true,
		stem_type = "2x2",
		stem_height_min = 12,
	})
end

treecapitator.register_tree({
	trees = {"default:pine_tree"},
	leaves = {"default:pine_needles"},
	-- the +2 height is used to also support the coned pine trees
	range_up = 2 +2,
	range_down = 6,
	range = 3,
})

treecapitator.register_tree({
	trees = {"default:acacia_tree"},
	leaf = "default:acacia_leaves",
	no_param2test = true,
	--leavesrange = 4,
	type = "acacia"
})

treecapitator.register_tree({
	trees = {"default:aspen_tree"},
	leaves = {"default:aspen_leaves"},
	range = 4,
})

if minetest.get_modpath("farming_plus") then
	treecapitator.register_tree({
		trees = {"default:tree"},
		leaves = {"farming_plus:banana_leaves"},
		range = 2,
		fruits = {"farming_plus:banana"}
	})

	treecapitator.register_tree({
		trees = {"default:tree"},
		leaves = {"farming_plus:cocoa_leaves"},
		range = 2,
		fruits = {"farming_plus:cocoa"}
	})
end

if treecapitator.moretrees_support
and minetest.get_modpath("moretrees") then
	treecapitator.register_tree({
		trees = {"moretrees:acacia_trunk"},
		leaves = {"moretrees:acacia_leaves"},
		range = 10,
	})

	treecapitator.register_tree{
		trees = {"moretrees:poplar_trunk"},
		leaves = {"moretrees:poplar_leaves"},
		range_up = 5,
		range_down = 17,
		range = 2,
	}

	local dates = {"moretrees:dates_fn", "moretrees:dates_m0",
		"moretrees:dates_n"}
	for i = 0, 4 do
		dates[#dates+1] = "moretrees:dates_f" .. i
	end
	dates[#dates+1] = "moretrees:date_palm_trunk"
	treecapitator.register_tree{
		trees = {
			"moretrees:date_palm_trunk",
			"moretrees:date_palm_mfruit_trunk",
			"moretrees:date_palm_ffruit_trunk"
		},
		leaves = {"moretrees:date_palm_leaves"},
		fruits = dates,
		trunk_fruit_vertical = true,
		range = 11,
		range_up = 15,
		range_down = 0,
	}

	treecapitator.register_tree{
		trees = {"moretrees:apple_tree_trunk"},
		leaves = {"moretrees:apple_tree_leaves"},
		fruits = {"default:apple", "moretrees:apple_tree_trunk"},
		trunk_fruit_vertical = true,
		range = 9,
		range_up = 3,
		range_down = 4,
	}

	treecapitator.register_tree{
		trees = {"moretrees:beech_trunk"},
		leaves = {"moretrees:beech_leaves"},
		range = 4,
		range_down = 2,
		range_up = 3,
		fruits = {"moretrees:beech_trunk"},
		trunk_fruit_vertical = true
	}

	treecapitator.register_tree{
		trees = {"moretrees:birch_trunk"},
		leaves = {"moretrees:birch_leaves"},
		fruits = {"moretrees:birch_trunk"},
		trunk_fruit_vertical = true,
		cutting_leaves = 3,
		stem_height_min = 4,
		range = 8,
		range_down = 13,
		range_up = 10,
	}

	treecapitator.register_tree{
		trees = {"moretrees:fir_trunk"},
		leaves = {"moretrees:fir_leaves", "moretrees:fir_leaves_bright"},
		range_up = 2,
		range_down = 21,
		range = 7,
		fruits = {"moretrees:fir_cone", "moretrees:fir_trunk"},
		trunk_fruit_vertical = true
	}

	treecapitator.register_tree({
		trees = {"moretrees:jungletree_trunk"},
		leaves = {"moretrees:jungletree_leaves_green",
			"jungletree_leaves_yellow", "jungletree_leaves_red"},
		range = 8,
	})

	treecapitator.register_tree{
		trees = {"moretrees:oak_trunk"},
		leaves = {"moretrees:oak_leaves"},
		fruits = {"moretrees:acorn", "moretrees:oak_trunk"},
		trunk_fruit_vertical = true,
		stem_type = "+",
		range = 11,
		range_up = 11,
		range_down = 1,
	}

	-- needs special type
	treecapitator.register_tree({
		trees = {"moretrees:cedar_trunk"},
		leaves = {"moretrees:cedar_leaves"},
		range = 10,
		range_up = 1,
		range_down = 19,
		trunk_fruit_vertical = true,
		fruits = {"moretrees:cedar_cone", "moretrees:cedar_trunk"}
	})

	treecapitator.register_tree{
		trees = {"moretrees:rubber_tree_trunk",
			"moretrees:rubber_tree_trunk_empty"},
		leaves = {"moretrees:rubber_tree_leaves"},
		fruits = {"moretrees:rubber_tree_trunk",
			"moretrees:rubber_tree_trunk_empty"},
		trunk_fruit_vertical = true,
		stem_type = "2x2",
		range = 8,
		range_down = 1,
		range_up = 8,
	}

	treecapitator.register_tree{
		trees = {"moretrees:sequoia_trunk"},
		leaves = {"moretrees:sequoia_leaves"},
		fruits = {"moretrees:sequoia_trunk"},
		trunk_fruit_vertical = true,
		stem_type = "+",
		range = 10,
		range_up = 3,
		range_down = 33,
		cutting_leaves = 6,
		stem_height_min = 6,
	}

	treecapitator.register_tree{
		trees = {"moretrees:spruce_trunk"},
		leaves = {"moretrees:spruce_leaves"},
		fruits = {"moretrees:spruce_cone", "moretrees:spruce_trunk"},
		trunk_fruit_vertical = true,
		cutting_leaves = 1,
		stem_type = "+",
		range = 10,
		range_down = 25,
		range_up = 5,
	}

	treecapitator.register_tree{
		trees = {"moretrees:willow_trunk"},
		leaves = {"moretrees:willow_leaves"},
		fruits = {"moretrees:willow_trunk"},
		trunk_fruit_vertical = true,
		stem_type = "+",
		range = 13,
		range_up = 6,
		range_down = 6,
	}

	treecapitator.register_tree{ -- small and 2x2 jungletree at once
		trees = {"moretrees:jungletree_trunk"},
		leaves = {"default:jungleleaves", "moretrees:jungletree_leaves_red"},
		fruits = {"moretrees:jungletree_trunk"},
		requisite_leaves = {"moretrees:jungletree_leaves_red"},
		trunk_fruit_vertical = true,
		stem_height_min = 4,
		cutting_leaves = 5,
		stem_type = "2x2",
		range = 8, -- 5 small
		range_up = 2, -- 1 small
		range_down = 17, -- 6 small
	}

	treecapitator.register_tree{
		trees = {"moretrees:jungletree_trunk"},
		leaves = {"default:jungleleaves", "moretrees:jungletree_leaves_yellow",
			"moretrees:jungletree_leaves_red"},
		fruits = {"moretrees:jungletree_trunk"},
		requisite_leaves = {"moretrees:jungletree_leaves_yellow"},
		trunk_fruit_vertical = true,
		cutting_leaves = 5,
		stem_type = "+",
		range = 8,
		range_up = 4,
		range_down = 16,
	}

	treecapitator.register_tree{
		trees = {"moretrees:palm_trunk"},
		trunk_top = "moretrees:palm_fruit_trunk",
		leaves = "moretrees:palm_leaves",
		fruit = "moretrees:coconut",
		range = 10,
		range_up = 7,
		range_down = 4,
		max_forbi = 2,
		type = "palm",
	}

	--~ treecapitator.register_tree({
		--~ trees = {"moretrees:sequoia_trunk"},
		--~ leaves = {"moretrees:sequoia_leaves"},
		--~ range = 8,


		--~ height = 17,
		--~ max_nodes = 8000,
		--~ num_trunks_min = 5,
		--~ num_trunks_max = 400,
		--~ num_leaves_min = 10,
		--~ num_leaves_max = 4000,
		--~ type = "moretrees",
	--~ })

	--~ treecapitator.register_tree({
		--~ trees = {"moretrees:willow_trunk"},
		--~ leaves = {"moretrees:willow_leaves"},
		--~ range = 11,
		--~ height = 17,
		--~ max_nodes = 8000,
		--~ num_trunks_min = 5,
		--~ num_trunks_max = 400,
		--~ num_leaves_min = 10,
		--~ num_leaves_max = 4000,
		--~ type = "moretrees",
	--~ })
end

-- code from amadin and narrnika
if minetest.get_modpath("ethereal") then
	treecapitator.register_tree({--jungle [эвкалипт]
		trees = {"default:jungletree"},
		leaves = {"default:jungleleaves"},
		range = 3,
		height = 20,
		max_nodes = 145,
		num_trunks_min = 0,
		num_trunks_max = 35,
		num_leaves_min = 0,
		num_leaves_max = 110,
		type = "moretrees",
	})
	treecapitator.register_tree({--pine [кедр]
		trees = {"default:pinetree"}, -- this may need to be changed to pine_tree
		leaves = {"ethereal:pineleaves"},
		range = 6,
		type = "default",
	})
	treecapitator.register_tree({--orange [апельсиновое дерево]
		trees = {"default:tree"},
		leaves = {"default:leaves", "ethereal:orange_leaves"},
		fruits = {"default:apple", "ethereal:orange"},
		range = 2,
		type = "default",
	})
	treecapitator.register_tree({--acacia [акация]
		trees = {"ethereal:acacia_trunk"},
		leaves = {"ethereal:acacia_leaves"},
		range = 10,
		height = 10,
		max_nodes = 122,
		num_trunks_min = 0,
		num_trunks_max = 22,
		num_leaves_min = 0,
		num_leaves_max = 100,
		type = "moretrees",
	})
	treecapitator.register_tree({--banana [банановое дерево]
		trees = {"ethereal:banana_trunk"},
		leaves = {"ethereal:bananaleaves"},
		fruits = {"ethereal:banana"},
		range = 3,
		height = 7,
		max_nodes = 28,
		num_trunks_min = 0,
		num_trunks_max = 4,
		num_leaves_min = 0,
		num_leaves_max = 20,
		type = "moretrees",
	})
	treecapitator.register_tree({--coconut [кокосовое дерево]
		trees = {"ethereal:palm_trunk"},
		leaves = {"ethereal:palmleaves"},
		fruits = {"ethereal:coconut"},
		range = 3,
		height = 9,
		max_nodes = 37,
		num_trunks_min = 0,
		num_trunks_max = 8,
		num_leaves_min = 0,
		num_leaves_max = 25,
		type = "moretrees",
	})
	treecapitator.register_tree({--willow [ива]
		trees = {"ethereal:willow_trunk"},
		leaves = {"ethereal:willow_twig"},
		range = 10,
		height = 13,
		max_nodes = 540,
		num_trunks_min = 0,
		num_trunks_max = 90,
		num_leaves_min = 0,
		num_leaves_max = 450,
		type = "moretrees",
	})
	treecapitator.register_tree({--moshroom [гриб]
		trees = {"ethereal:mushroom_trunk"},
		leaves = {"ethereal:mushroom", "ethereal:mushroom_pore"},
		range = 4,
		height = 10,
		max_nodes = 100,
		num_trunks_min = 0,
		num_trunks_max = 32,
		num_leaves_min = 0,
		num_leaves_max = 80,
		type = "moretrees",
	})
end
