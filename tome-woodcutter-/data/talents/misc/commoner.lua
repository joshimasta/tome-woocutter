newTalent{
	name = "Transfering Skills", short_name = "COMMONER_SKILLS",
	type = {"commoner/commoner-in-combat", 1},
	mode = "passive",
	require = lev_req1,
	tactical = { },
	points = 5,
	no_npc_use = true,
  no_unlearn_last = true,
	on_learn = function(self, t)
		self.unused_generics = self.unused_generics + 1
	end,
	on_unlearn = function(self, t)
		self.unused_generics = self.unused_generics - 1
	end,
	info = function(self, t)
		return ([[You adapt skills needed in your old job to adventuring. You gain 1 generic talent point per raw talent level.]])
	end,
}
newTalent{
	name = "Learning The Ropes", short_name = "COMMONER_STATS",
	type = {"commoner/commoner-in-combat", 2},
	mode = "passive",
	require = lev_req2,
	tactical = { },
	points = 5,
	no_npc_use = true,
  no_unlearn_last = true,
	on_learn = function(self, t)
		self.unused_stats = self.unused_stats + 3
	end,
	on_unlearn = function(self, t)
		self.unused_stats = self.unused_stats - 3
	end,
	info = function(self, t)
		return ([[You gain 3 stat points per raw talent level.]])
	end,
}
newTalent{
	name = "Basics Of Combat", short_name = "COMMONER_COMBAT",
	type = {"commoner/commoner-in-combat", 3},
	mode = "passive",
	require = lev_req3,
	tactical = { },
	points = 5,
	no_npc_use = true,
  no_unlearn_last = true,
	getSaves = function(self, t) return self:combatTalentScale(t, 2, 10, 0.75) end,
	on_learn = function(self, t)
		local lev = self:getTalentLevelRaw(t)
		local levs = self:getTalentLevel(t)
		if lev == 1 and (self:knowTalentType("technique/shield-defense") == true) then 
      -- no mastery increase
		elseif lev == 1 and (self:knowTalentType("technique/shield-defense") == false) then
      -- no unlock
		elseif lev == 1 then
			self:learnTalentType("technique/shield-defense", false)
			self.woodcuttershielddefenceoption = true
		end
		if lev == 3 and not (self:knowTalent(self.T_SHOOT)) then 
			self:learnTalent(self.T_SHOOT, true, nil, {no_unlearn=true})
			self.woodcuttershootlearn = true
		end
		if lev == 3 and not (self:knowTalent(self.T_RUSH)) then 
			self:learnTalent(self.T_RUSH, true, nil, {no_unlearn=true})
			self.woodcutterrushlearn = true
		end
		if lev == 5 and (self:knowTalentType("technique/archery-training") == true) then 
      -- no mastery increase
		elseif lev == 5 and (self:knowTalentType("technique/archery-training") == false) then
      -- no unlock
		elseif lev == 5 then
			self:learnTalentType("technique/archery-training", false)
			self.woodcutterarcherytrainingoption = true
		end
	end,
	on_unlearn = function(self, t)
		if lev == 0 and (self.woodcuttershielddefenceoption == true) then 
			--nothing
		elseif lev == 0 and (self.woodcuttershielddefenceoption == true) then
			--nothing
		elseif lev == 0 and (self.woodcuttershielddefenceoption == true) then
			self:unlearnTalentType("technique/shield-defense")
			self.talents_types["technique/shield-defense"] = nil
			self.woodcuttershielddefenceoption = false
		end
		if lev == 2 and (self.woodcuttershootlearn == true) then 
			self:unlearnTalent(player.T_SHOOT, true, nil)
			self.woodcuttershootlearn = false
		end
		if lev == 2 and (self.woodcutterrushlearn == true) then 
			self:unlearnTalent(player.T_RUSH, true, nil)
			self.woodcutterrushlearn = false
		end
		if lev == 4 and (self.woodcutterarcherytrainingoption == true) then 
			--nothing
		elseif lev == 4 and (self.woodcutterarcherytrainingoption == true) then
			--nothing
		elseif lev == 4 and (self.woodcutterarcherytrainingoption == true) then
			self:unlearnTalentType("technique/archery-training")
			self.talents_types["technique/archery-training"] = nil
			self.woodcutterarcherytrainingoption = false
		end
	end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_physresist", t.getSaves(self, t))
		self:talentTemporaryValue(p, "combat_spellresist", t.getSaves(self, t))
		self:talentTemporaryValue(p, "combat_mentalresist", t.getSaves(self, t))
	end,
	info = function(self, t)
		return ([[You gain %d to all saves.
    At raw talent level 1, you can learn shield defence at mastery 1.0.
    At raw talent level 3, you learn talents rush and shoot.
    At raw talent level 5, you can learn archery training at mastery 1.0.
    ]]):
		tformat(t.getSaves(self, t))
	end,
}
newTalent{
	name = "Savings And Assets ", short_name = "COMMONER_SAVINGS",
	type = {"commoner/commoner-in-combat", 4},
	mode = "passive",
	require = lev_req4,
	tactical = { },
	points = 5,
	no_npc_use = true,
  no_unlearn_last = true,
	generateItem = function(self, t)
		local mainbases = {
			armours = {
				"cashmere robe",
				"hardened leather armour",
				"dwarven-steel mail armour",
				"dwarven-steel plate armour",
				"cashmere cloak",
				"hardened leather gloves",
				"dwarven-steel gauntlets",
				"cashmere wizard hat",
				"hardened leather cap",
				"dwarven-steel helm",
				"pair of hardened leather boots",
				"pair of dwarven-steel boots",
				"hardened leather belt",
				"dwarven-steel shield",
			},
			weapons = {
				"dwarven-steel battleaxe",
				"dwarven-steel greatmaul",
				"dwarven-steel greatsword",
				"dwarven-steel waraxe",
				"dwarven-steel mace",
				"dwarven-steel longsword",
				"dwarven-steel dagger",
				"thorny mindstar",
				"quiver of yew arrows",
				"yew longbow",
				"hardened leather sling",
				"yew staff",
				"pouch of dwarven-steel shots",
			},
			misc = {
				"gold ring",
				"gold amulet",
				"alchemist's lamp",
				"dwarven-steel pickaxe",
				{"yew wand", _t"yew wand"},
				{"yew totem", _t"yew totem"},
				{"dwarven-steel torque", _t"dwarven-steel torque"},
			},
		}
		--select base item
		local category = rng.table(table.values(mainbases))
		local name = rng.table(category)
		-- doing some special case stuff
		local dname = nil
		if type(name) == "table" then name, dname = name[1], name[2] end
		local not_ps, force_themes
		local player = self
		not_ps = game.state:attrPowers(player) -- make sure randart is compatible with player
		if not_ps.arcane then force_themes = {'antimagic'} end
		--generate object
		local o, ok
		local tries = 100
		repeat
			o = game.zone:makeEntity(game.level, "object", {name=name, ignore_material_restriction=true, no_tome_drops=true, ego_filter={keep_egos=true, ego_chance=-1000}}, nil, true)
			if o then ok = true end
			if o and not game.state:checkPowers(player, o, nil, "antimagic_only") then
				ok = false o = nil 
			end
			tries = tries - 1
		until ok or tries < 0
		if o then
			if not dname then dname = o:getName{force_id=true, do_color=true, no_count=true}
			else dname = "#B4B4B4#"..o:getDisplayString()..dname.."#LAST#" end
			local art, ok
			local nb = 0
			repeat
				local egos = 2 + ((rng.percent(60) and 1) or 0) -- chance to get third ego
				art = game.state:generateRandart{base=o, lev=20, egos=egos, force_themes=force_themes, forbid_power_source=not_ps}
				if art then ok = true end
				if art and not game.state:checkPowers(player, art, nil, "antimagic_only") then
					ok = false
				end
				nb = nb + 1
				if nb == 80 then break end
			until ok
			if art and nb < 80 then
				return true, art
			end
		end
		return false
	end,
	callbackOnActBase = function(self, t)
		local lev = self:getTalentLevelRaw(t)
		if lev == 5 and not self.woodcuttergainedsavingsitem then 
			local ok, item = t.generateItem(self, t)
			if not ok then return 
			else
				item:identify(true)
				self:addObject(self.INVEN_INVEN, item)
				-- prevent cheats and abuses, clear chrono wrolds
				game:chronoCancel(_t"#CRIMSON#Your timetravel has no effect on pre-determined outcomes such as this.")
				if not config.settings.cheat then game:saveGame() end
				self.woodcuttergainedsavingsitem = true
			end
		end
	end,
	on_learn = function(self, t)
		self.money = self.money + 600
	end,
	on_unlearn = function(self, t)
		self.money = self.money - 600
	end,
	info = function(self, t)
		return ([[You gain 600 gold per raw talent level. At raw talent level 5 you gain a randomly generated unique (perform any action to gain the item). (The item is level 20 and tier 3.)]])
	end,
}