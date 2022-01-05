
newTalent{
	name = "Campfire", short_name = "WOODCUTTER_CAMPFIRE",
	type = {"technique/firewood", 1},
	mode = "activated",
	require = techs_req1,
	points = 5,
	cooldown = 12,
	firewood = 4,
	stamina = 10,
	tactical = { ATTACK = {FIRE = 2} },
	autolearn_talent = "T_FIREWOOD_POOL",
	range = 1,
	radius = 6,
	speed = "standard",
	direct_hit = true,
	requires_target = true,
	no_npc_use = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=true, friendlyfire=true}
	end,
	getDamagePrimary = function(self, t) return self:combatTalentPhysicalDamage(t, 0, 180) end,
	getDamageSecondary = function(self, t) return self:combatTalentPhysicalDamage(t, 0, 30) end,
	getDamageSecondaryExtra = function(self, t)
			if self:knowTalent(self.T_WOODCUTTER_FAMILIAR) then
				return self:callTalent(self.T_WOODCUTTER_FAMILIAR,"getDamageCampfire")
			end
			return 0
		end,
	getDuration = function(self, t) return 8 end,
	getFirewoodGain = function(self, t) return 2 end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		local damPri = t.getDamagePrimary(self, t)
		local damSec = t.getDamageSecondary(self, t)
		local damSecExtra = t.getDamageSecondaryExtra(self, t)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, t.getDuration(self, t),
			DamageType.FIRE, damPri,
			0,
			5, nil,
			{type="campfire_embers", overlay_particle={zdepth=6, only_one=true, type="circle", args={base_rot=0, oversize=0.7, a=255, appear=16, speed=0, img="campfire_image", radius=0}}},
			nil, true
		)
		game.level.map:addEffect(self,
			x, y, t.getDuration(self, t),
			DamageType.LITE_LIGHT, damSec,
			self:getTalentRadius(t),
			5, nil,
			{type="campfire_light"},
			nil, false, false
		)
		if damSecExtra > 0 then
			game.level.map:addEffect(self,
				x, y, t.getDuration(self, t),
				DamageType.LIGHT, damSecExtra,
				self:getTalentRadius(t),
				5, nil,
				nil,
				nil, false, false
			)
		end

		game:playSoundNear(self, "talents/cloud")
		return true
	end,
	callbackOnDealDamage = function(self, t, val, target, dead, death_note)
		if not dead then return end
		
		if target.subtype == "plants" then
			self:incFirewood(t.getFirewoodGain(self, t))
		end

	end,
	info = function(self, t)
		local damPri = t.getDamagePrimary(self, t)
		local damSec = t.getDamageSecondary(self, t)
		local damSecExtra = t.getDamageSecondaryExtra(self, t)
		return ([[Create a campfire, which deals %0.2f fire damage to anyone standing on it. Also deals %0.2f + %0.2f light damage to enemies in radius %d. Killing a plant grants %d firewood. (Currently %0.2f/%0.2f firewood.)]]):
		format(damDesc(self, DamageType.FIRE, damPri), damDesc(self, DamageType.LIGHT, damSec), damDesc(self, DamageType.LIGHT, damSecExtra), self:getTalentRadius(t), t.getFirewoodGain(self, t), self.firewood, self.max_firewood)
	end,
}

newTalent{
	name = "Gather Firewood", short_name = "WOODCUTTER_GATHER_FIREWOOD",
	type = {"technique/firewood", 2},
	mode = "activated",
	require = techs_req2,
	tactical = { },
	points = 5,
	cooldown = function(self, t) return math.ceil(math.max(23 - 2*self:getTalentLevel(t), 5)) end,
	firewood = 0,
	no_npc_use = true,
	firewoodRegen = 0.05,
	getFirewoodGain = function(self, t) return self:getTalentLevelRaw(t) + 1 end,
	on_learn = function(self, t)
		self.firewood_regen = (self.firewood_regen or 0) + t.firewoodRegen
	end,
	on_unlearn = function(self, t)
		self.firewood_regen = (self.firewood_regen or 0) - t.firewoodRegen
	end,
	target = function(self, t)
		return {type="beam", range=1, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local terrain = game.level.map(x, y, Map.TERRAIN)
		if terrain.type ~= "wall" then
			game.logPlayer(self, "You need to target a wall.") 
			return false 
		end
		local grass = string.find(terrain.subtype, 'grass')
		grass = grass or string.find(terrain.subtype, 'bamboo')
		local tree = (terrain.name == "burnt tree" or terrain.name == "snowy tree" or terrain.name == "tree")
		if not (grass or tree) then 
			game.logPlayer(self, "The target needs to be made of wood.") 
			return false 
		end

		self:project(tg, x, y, DamageType.DIG, 1)
		self:incFirewood(3)

		return true
	end,
	info = function(self, t)
		return ([[Destroy an adjacent wood tile to regain %d firewood. You also gain passive %0.2f firewood regen.]]):
		format(t.getFirewoodGain(self, t), t.firewoodRegen)
	end,
}
newTalent{
	name = "Warm Meals", short_name = "WOODCUTTER_WARM_MEALS",
	type = {"technique/firewood", 3},
	mode = "sustained",
	require = techs_req3,
	tactical = { },
	points = 5,
	cooldown = 10,
	sustain_stamina = 10,
	sustain_firewood = 2,
	speed = "standard",
	getLifeRegen = function(self, t) return self:combatTalentScale(t, 0.5, 2.5, 0.75) + math.max(self:combatTalentStatDamage(t, "con", 0, 2.5), 0) end,
	getMaxLife = function(self, t) return self:combatTalentScale(t, 5, 50, 0.75) + math.max(self:combatTalentStatDamage(t, "con", 5, 50), 0) end,
	getResistance = function(self, t) return self:combatTalentScale(t, 1, 5, 0.75) end,
	activate = function(self, t)
		--game:playSoundNear(self, "talents/arcane")
		return {
			regen = self:addTemporaryValue("life_regen", t.getLifeRegen(self, t)),
			life = self:addTemporaryValue("max_life", t.getMaxLife(self, t)),
			res = self:addTemporaryValue("resists", {[DamageType.NATURE] = t.getResistance(self, t)}),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("life_regen", p.regen)
		self:removeTemporaryValue("max_life", p.life)
		self:removeTemporaryValue("resists", p.res)
		return true
	end,
	info = function(self, t)
		return ([[You superior diet gives you advantages over regular adventurers. While sustained, you gain %0.1f health regen, %d max health and %d%% nature resistance. The bonus health and health regen scale based on your constitution.]]):
		format(t.getLifeRegen(self, t), t.getMaxLife(self, t), t.getResistance(self, t))
	end,
}

newTalent{
	name = "Bonfire", short_name = "WOODCUTTER_BONFIRE",
	type = {"technique/firewood", 4},
	mode = "activated",
	require = techs_req4,
	points = 5,
	cooldown = 30,
	firewood = 6,
	stamina = 15,
	tactical = { ATTACK = {FIRE = 2} },
	range = 1,
	radius = 6,
	speed = "standard",
	direct_hit = true,
	requires_target = true,
	no_npc_use = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=1, selffire=false, friendlyfire=false}
	end,
	getDamagePrimary = function(self, t) return self:combatTalentPhysicalDamage(t, 0, 180) end,
	getHeal = function(self, t) return 2 + self:combatTalentStatDamage(t, "con", 2, 25) end,
	getStamina = function(self, t) return self:combatTalentScale(t, 0.2, 2) end,
	getDuration = function(self, t) return 8 end,
	getBurnDamage = function(self, t) return self:combatTalentPhysicalDamage(t, 10, 80) end,
	getBurnDuration = function(self, t) return 4 end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		local damPri = t.getDamagePrimary(self, t)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, t.getDuration(self, t),
			DamageType.FIRE, damPri,
			0,
			5, nil,
			{type="campfire_embers", overlay_particle={zdepth=6, only_one=true, type="circle", args={base_rot=0, oversize=0.7, a=255, appear=16, speed=0, img="campfire_image", radius=0}}},
			nil, true
		)
		game.level.map:addEffect(self,
			x, y, t.getDuration(self, t),
			DamageType.FIREBURN, t.getBurnDamage(self, t),
			1,
			5, nil,
			nil,
			nil, false, false
		)
		game.level.map:addEffect(self,
			x, y, t.getDuration(self, t),
			DamageType.LITE, 1,
			self:getTalentRadius(t),
			5, nil,
			{type="campfire_light"},
			nil, false, false
		)
		game.level.map:addEffect(self,
			x, y, t.getDuration(self, t),
			DamageType.WOODCUTTER_BONFIRE_HEAL_STAMINA, 1,
			self:getTalentRadius(t),
			5, nil,
			nil,
			nil, false
		)

		game:playSoundNear(self, "talents/cloud")
		return true
	end,
	info = function(self, t)
		local damPri = t.getDamagePrimary(self, t)
		return ([[Create a bonfire for %d turns, which deals %0.2f fire damage to anyone standing on it and deals %0.2f burning fire damage in radius 1. 
		You restore %0.2f health and %0.2f stamina per turn while you are within radius 6 of the bonfire.]]):
		format(t.getDuration(self, t), damDesc(self, DamageType.FIRE, damPri), damDesc(self, DamageType.FIRE, t.getBurnDamage(self, t)), t.getHeal(self, t), t.getStamina(self, t))
	end,
}
