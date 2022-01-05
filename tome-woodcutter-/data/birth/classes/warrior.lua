
newBirthDescriptor{
	type = "subclass",
	name = "Woodcutter",
	desc = {
		"Woodcutters don't usually dabble on adventuring, but occasionally one of them decides to take on a more dangerous pursuit.",
		"Woodcutters are masters of axes and wood. They are tough but usually not experienced in combat.",
		"Their most important stats are: Strength and Constitution",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +6 Strength, +0 Dexterity, +3 Constitution",
		"#LIGHT_BLUE# * +0 Magic, +0 Willpower, +0 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# +2",
	},
	power_source = {technique=true},
	stats = { str=6, con=3, },
	getStatDesc = function(stat, actor)
		if stat == actor.STAT_STR then
			return ("Max firewood: %d"):tformat(math.floor(actor:getStr() - 10))
		end
	end,
	talents_types = {
		--class talents
		["technique/woodcutter"]={true, 0.3},
		["technique/firewood"]={true, 0.3},
		["technique/axes"]={true, 0.3},
		["commoner/commoner-in-combat"]={true, 0},

		--unlockable
		["spell/haunted-woods"]={false, 0.3},
		["cunning/trapping"]={false, 0},
		
		--generic talents
		--["technique/combat-training"]={true, 0}, --TODO: remove
		["technique/conditioning"]={true, 0.3},
		["technique/herblore"]={true, 0.3},
		["technique/mobility"]={true, 0},

		-- unlockable
		["cunning/survival"]={false, 0.3},
		
	},
	talents = {
		--class talents
		[ActorTalents.T_WOODCUTTER_AXE_MASTERY] = 1,
		[ActorTalents.T_WOODCUTTER_CAMPFIRE] = 1,
		[ActorTalents.T_WOODCUTTER_WOODCUTTER] = 1,
		--generic talents
		[ActorTalents.T_VITALITY] = 1,
		[ActorTalents.T_WOODCUTTER_LIGHTWEIGHT_LEAVES] = 1,
	},
	copy = {
		max_life = 120,
		mage_equip_filters,
		resolvers.equipbirth{ id=true,
			{type="weapon", subtype="battleaxe", name="iron battleaxe", autoreq=true, ignore_material_restriction=true, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true, ignore_material_restriction=true, ego_chance=-1000},
		},
	},
	copy_add = {
		life_rating = 2,
	},
}

getBirthDescriptor("class", "Warrior").descriptor_choices.subclass.Woodcutter = "allow"