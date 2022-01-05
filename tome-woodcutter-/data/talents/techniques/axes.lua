local DamageType = require "engine.DamageType"

-- Swaps weapons if needed

newTalent{
	name = "Axe Mastery", short_name = "WOODCUTTER_AXE_MASTERY",
	type = {"technique/axes", 1},
	points = 5,
	require = { stat = { str=function(level) return 12 + level * 6 end }, },
	mode = "passive",
	getDamage = function(self, t) return 30 end,
	getPercentInc = function(self, t) return math.sqrt(self:getTalentLevel(t) / 5) / 1.5 end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local inc = t.getPercentInc(self, t)
		return ([[Increases weapon damage by %d%% and physical power by 30 when using axes.]]):
		tformat(100*inc)
	end,
}

newTalent{
	name = "The Right Axe For The Job", short_name = "WOODCUTTER_RIGHT_AXE",
	type = {"technique/axes", 2},
	require = techs_req2,
	points = 5,
	mode = "activated",
	stamina = 15,
	cooldown = function(self, t) return math.ceil(math.max(20 - 2*self:getTalentLevel(t), 5)) end,
	no_energy = true,
	getDamIncrease = function(self, t) return self:combatTalentStatDamage(t, "str", 2, 30) end,
	getDuration = function(self, t) return 3 end,
	-- hasTwoHandedWeaponQS  = function(self, t, silent)--- Check if the actor has a two handed weapon
	-- 	if self:attr("disarmed") then
	-- 		return nil, "disarmed"
	-- 	end
	
	-- 	if not self:getInven("QS_MAINHAND") then return end
	-- 	local weapon = self:getInven("QS_MAINHAND")[1]
	-- 	if not weapon or not weapon.twohanded then
	-- 		return nil
	-- 	end
	-- 	return weapon
	-- end,
	hasAxeWeaponQS = function(self, t)
		if not self:getInven("QS_MAINHAND") then return end
		local weapon = self:getInven("QS_MAINHAND")[1]
		if not weapon or (weapon.subtype ~= "battleaxe" and weapon.subtype ~= "waraxe") then
			return nil
		end
		return weapon
	end,
	on_pre_use = function(self, t, silent)
		if self.no_inventory_access then return end
		if self:attr("sleep") and not self:attr("lucid_dreamer") then
			if not silent then game.logPlayer(self, "You cannot use The Right Axe For The Job while sleeping!") end
			return
		end
		local weapon = t.hasAxeWeaponQS(self, t)
		if not weapon then
			if not silent then game.logPlayer(self, "You cannot use The Right Axe For The Job without a quickswap axe!") end
			return nil
		end
		return true 
	end,
	action = function(self, t) 
		if not t.on_pre_use(self, t, false) then return false end

		local old_inv_access = self.no_inventory_access -- Make sure clones can swap
		self.no_inventory_access = nil
		self:attr("no_sound", 1)
		self:quickSwitchWeapons(true)
		self:attr("no_sound", -1)
		self.no_inventory_access = old_inv_access

		self:setEffect(self.EFF_WOODCUTTER_PHYSICAL_SURGE, t.getDuration(self, t), {power = t.getDamIncrease(self, t), max = 1000}) -- change physical power
		return true
	end,
	info = function(self, t)
		return ([[Swap to your other weapon set, provided it is an axe of course. Remove any disarms affecting you and gain %d physical power (based on strength) for %d turns.]]):
		tformat(t.getDamIncrease(self, t), t.getDuration(self, t))
	end,
}

newTalent{
	name = "Axe Sharpening", short_name = "WOODCUTTER_AXE_SHARPENING",
	type = {"technique/axes", 3},
	require = techs_req3,
	mode = "sustained",
	points = 5,
	sustain_stamina = 30,
	cooldown = 5,
	tactical = { BUFF = 2 },
	iconOverlay = function(self, t, p)
		local p = self.sustain_talents[t.id]
		if not p then return "" end
		return tostring(math.floor(damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)))), "buff_font_smaller"
	end,
	getDamage = function(self, t) return self:combatTalentPhysicalDamage(t, 1, 60)+10 end,
	activate = function(self, t)
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Sharpen your axes; each blow you land will do an additional %.2f physical damage.
		The damage will improve with your Physical Power.]]):
		tformat(damDesc(self, DamageType.PHYSICAL, damage))
	end,
}

newTalent{
	name = "Cinematic Axe Spin", --short_name = "DEATH_DANCE_ASSAULT", 
	image = "talents/death_dance.png",
	type = {"technique/axes", 4},
	require = techs_req4,
	points = 5,
	cooldown = 10,
	stamina = 30,
	tactical = { ATTACKAREA = { weapon = 2, offhand = 1 } },
	range = 0,
	radius = 2,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t)}
	end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.4, 2.1) end,
	on_pre_use = function(self, t, silent) 
		local weapon = self:hasAxeWeapon()
		if not weapon then
			if not silent then game.logPlayer(self, "You cannot use Cinematic Axe Spin without an axe!") end
			return nil
		end
		return true 
	end,
	action = function(self, t)
		local weapon = self:hasAxeWeapon()
		if not weapon then
			game.logPlayer(self, "You cannot use Cinematic Axe Spin without an axe!")
			return nil
		end
		local _, offweapon = self:hasDualWeapon()

		local doOffhandAttack = offweapon and not (offweapon.subtype ~= "battleaxe" and offweapon.subtype ~= "waraxe")

		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and target ~= self then
				self:attackTargetWith(target, weapon.combat, nil, t.getDamage(self, t))
				if doOffhandAttack then
					self:attackTargetWith(target, offweapon.combat, nil, 0.5)
				end
			end
		end)

		self:addParticles(Particles.new("meleestorm", 1, {radius=self:getTalentRadius(t)}))

		return true
	end,
	info = function(self, t)
		return ([[Spin around with your axe, damaging all enemies in radius %d for %d%% weapon damage.
		If you have offhand axe, also deal 50%% offhand weapon damage.]]):
		tformat(self:getTalentRadius(t), 100 * t.getDamage(self, t))
	end,
}
