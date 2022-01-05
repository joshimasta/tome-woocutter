
newTalent{
	name = "Familiar With the Woods", short_name = "WOODCUTTER_FAMILIAR",
	type = {"spell/haunted-woods", 1},
	require = spells_req_high1,
	points = 5,
	mode = "passive",
	getSpellpower = function(self, t) return self:combatTalentLimit(t, 50, 8, 16, false, 1.3) end,
  getManaRegen = function(self, t) return 0.2 end,
  getDamPer = function(self, t) return self:getTalentLevelRaw(t)*10 end,
	getDamageCampfire = function(self, t) return self:combatTalentSpellDamage(t, 0, 30) end,
	on_learn = function(self, t)
		self.inc_damage_actor_type = self.inc_damage_actor_type or {}
		self.inc_damage_actor_type.ghost = (self.inc_damage_actor_type.ghost or 0) + 10
	end,
	on_unlearn = function(self, t)
		self.inc_damage_actor_type.ghost = (self.inc_damage_actor_type.ghost or 0) - 10
	end,
	passives = function(self, t, ret)
		self:talentTemporaryValue(ret, "mana_regen", t.getManaRegen(self, t))
		self:talentTemporaryValue(ret, "combat_spellresist", t.getSpellpower(self, t))
	end,
	info = function(self, t)
		local spellpower = t.getSpellpower(self, t)
		local damPer = t.getDamPer(self, t)
		local campfireDamage = t.getDamageCampfire(self, t)
		return ([[You gain %0.1f%% of your strength (%d) as bonus to spell power and spell save, and you deal %d%% extra damage to ghosts. Your campfire deals %0.2f extra light damage, based on your spellpower.]]):
		tformat(spellpower, spellpower * self:getStr() / 100,  damPer, damDesc(self, DamageType.LIGHT, campfireDamage))
	end,
}

newTalent{
	name = "Ghost Timber", short_name = "WOODCUTTER_GHOST_TIMBER",
	type = {"spell/haunted-woods", 2},
	require = spells_req_high2,
	points = 5,
	mode = "activated",
	mana = 15,
	cooldown = 8,
	tactical = { ATTACK = {DARKNESS = 2} },
	range = 3,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), talent=t, friendlyfire=self:spellFriendlyFire()}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 70, 280) end,
	getDuration = function(self, t) return 3 end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		self:project(tg, x, y, DamageType.DARKSTUN, self:spellCrit(t.getDamage(self, t)))
		local _ _, x, y = self:canProject(tg, x, y)

		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "shadow_beam", {tx=x-self.x, ty=y-self.y}) -- todo
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Deal %d darkness damage in a %d long beam and stun the targets for 4 turns.]]):
		tformat(damDesc(self, DamageType.DARKNESS, t.getDamage(self, t)), t.range)
	end,
}

newTalent{
	name = "Axe spiriting", short_name = "WOODCUTTER_AXE_SPIRITING",
	type = {"spell/haunted-woods", 3},
	require = spells_req_high3,
	mode = "sustained",
	points = 5,
	sustain_stamina = 10,
	sustain_mana = 40,
	cooldown = 10,
	tactical = { BUFF = 2 },
	iconOverlay = function(self, t, p)
		local p = self.sustain_talents[t.id]
		if not p then return "" end
		return tostring(math.floor(damDesc(self, DamageType.DARKNESS, t.getDamage(self, t)))), "buff_font_smaller"
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 1, 70)+10 end,  -- This doesn't crit or generally scale easily so its safe to be aggressive
	getManaCost = function(self, t) return 0 end,
	activate = function(self, t)
		local ret = {}
		if core.shader.active(4) then
			local slow = rng.percent(50)
			local h1x, h1y = self:attachementSpot("hand1", true) if h1x then self:talentParticles(ret, {type="shader_shield", args={img="shadowhands_01", dir=180, a=0.7, size_factor=0.3, x=h1x, y=h1y-0.1}, shader={type="flamehands", time_factor=slow and 700 or 1000}}) end
			local h2x, h2y = self:attachementSpot("hand2", true) if h2x then self:talentParticles(ret, {type="shader_shield", args={img="shadowhands_01", dir=180, a=0.7, size_factor=0.3, x=h2x, y=h2y-0.1}, shader={type="flamehands", time_factor=not slow and 700 or 1000}}) end
		end
		game:playSoundNear(self, "talents/arcane")
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Channel energies to your axes to make them (mostly) spirit proof. Your spirited axes deal %0.2f extra darkness damage to targets.]]):
		tformat(damDesc(self, DamageType.DARKNESS, damage))
	end,
}
newTalent{
	name = "Beckoming The Sounds", short_name = "WOODCUTTER_SOUNDS",
	type = {"spell/haunted-woods", 4},
	require = spells_req_high4,
	points = 5,
	range = 0,
	cooldown = 45,
	mana = 45,
	no_energy = true,
	getDuration = function(self, t) return 8 end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 8, 60) end,
	getRadius = function(self, t) return 3 end,
	terrifiedPowerMultiplier = function(self, t) return 1.2 end,
	getTerrifiedDamage = function(self,t)
		return math.floor(self:combatTalentSpellDamage(t, 5, 20) * t.terrifiedPowerMultiplier(self, t))
	end,
	getTerrifiedDuration = function(self, t)
		return 8
	end,
	getTerrifiedPower = function(self,t)
		return math.floor(self:combatTalentSpellDamage(t, 25, 60) * t.terrifiedPowerMultiplier(self, t))
	end,
	getTerrifiedChance = function(self, t) 
		return math.min(
			25, 
			self:combatScale(self:getTalentLevel(t), 7, 1, 15, 6.5) * math.max(1, self:combatScale(self.combat_spellspeed, 1, 1, 1.35, 1.5))
		) 
	end,
	mode = "activated",
	target = function(self, t)
		 return {type="ball", range=self:getTalentRange(t), radius=t:getRadius(self, t), talent=t, selffire=false, friendlyfire=self:spellFriendlyFire() }
	end,
	getTickEffect =  function(self, t)
		-- find targets and damage (and crit)
		local tg = self:getTalentTarget(t)
		local dam = self:spellCrit(t.getDamage(self, t))

		-- project damage and effects
		self:projectSource(tg, self.x, self.y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and target ~= self then
				if self:getTalentLevel(t) > 0 then
					--deal damage
					DamageType:get(DamageType.MIND).projector(self, px, py, DamageType.MIND, dam/2)
					DamageType:get(DamageType.DARKNESS).projector(self, px, py, DamageType.DARKNESS, dam/2)
					--check for terrified
					if rng.percent(t.getTerrifiedChance(self, t)) and target:checkHit(self:combatSpellpower(), target:combatSpellResist(), 5, 95, 15) and target:canBe("fear") then 
						local eff = {src=self, duration=t.getTerrifiedDuration(self, t) }
						eff.damage = self:spellCrit(t.getTerrifiedDamage(self, t) / 2)
						eff.cooldownPower = t.getTerrifiedPower(self, t) / 100
						target:setEffect(target.EFF_TERRIFIED, t.getTerrifiedDuration(self, t), eff)
					end
				end
			end
		end, nil, nil, t)
		return true
	end,
	action = function(self, t)
		self:setEffect(self.EFF_WOODCUTTER_SOUNDS, t.getDuration(self, t), {}) -- change physical power
		return true
	end,
	info = function(self, t)
		local dam = self:spellCrit(t.getDamage(self, t))
		return ([[Deal %d mind and %d darkness damage per turn to enemies in %d radius around you for %d turns.
		Has %d%% chance to make affected enemies #ORANGE#terrified#LAST#, dealing %0.2f mind and %0.2f darkness damage per turn for 8 turns and increases cooldowns by %d%%.
		Damage scales based on your spellpower and chance to terrify based on your spell speed.]]):
		tformat(damDesc(self, DamageType.MIND, dam/2), damDesc(self, DamageType.DARKNESS, dam/2), t.getRadius(self, t), t.getDuration(self, t), t.getTerrifiedChance(self, t),damDesc(self, DamageType.MIND, t.getTerrifiedDamage(self, t)/2),damDesc(self, DamageType.DARKNESS, t.getTerrifiedDamage(self, t)/2),t.getTerrifiedPower(self, t))
	end,
}