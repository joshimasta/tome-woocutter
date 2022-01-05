newTalent{
	name = "Woodcutter", short_name = "WOODCUTTER_WOODCUTTER",
	type = {"technique/woodcutter", 1},
	mode = "passive",
	require = techs_req1,
	points = 5,
	on_learn = function(self, t)
		self.inc_damage_actor_type = self.inc_damage_actor_type or {}
		self.inc_damage_actor_type["immovable/plants"] = (self.inc_damage_actor_type["immovable/plants"] or 0) + 50
		self.inc_damage_actor_type["giant/treant"] = (self.inc_damage_actor_type["giant/treant"] or 0) + 50
	end,
	on_unlearn = function(self, t)
		self.inc_damage_actor_type["immovable/plants"] = (self.inc_damage_actor_type["immovable/plants"] or 0) - 50
		self.inc_damage_actor_type["giant/treant"] = (self.inc_damage_actor_type["giant/treant"] or 0) - 50
	end,
	info = function(self, t)
		return ([[Your woodcutting technique allows you to deal %d%% increased damage to plants and treants.]]):
		format(25*self:getTalentLevelRaw(t))
	end,
}
newTalent{
	name = "Chop the Brances", short_name = "WOODCUTTER_CHOP_THE_BRANCHES",
	type = {"technique/woodcutter", 2},
	mode = "activated",
	require = techs_req2,
	points = 5,
	cooldown = 30,
	requires_target = true,
	range = 1,
	tactical = { ATTACK = { weapon = 1 }, DISABLE = { disarm = 1 } },
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.5, 0.9) end,
	getDuration = function(self, t) return self:combatTalentLimit(t, 20, 5, 9) end,
	getPowerloss = function(self, t) return self:combatTalentPhysicalDamage(t, 4, 60) end,
	action = function(self, t)
		local weapon = self:hasAxeWeapon()
		if not weapon then
			game.logPlayer(self, "You cannot use Chop the Brances without an axe!")
			return nil
		end

		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end
		local speed, hit = self:attackTargetWith(target, weapon.combat, nil, t.getDamage(self, t))

		if hit then
			if target:canBe("disarm") then
				target:setEffect(target.EFF_DISARMED, t.getDuration(self, t), {apply_power=self:combatPhysicalpower()})
				if target.subtype == "plants" then
					target:setEffect(target.EFF_WOODCUTTER_POWER_REDUCED, t.getDuration(self, t), {apply_power=self:combatPhysicalpower()})
				end
			else
				game.logSeen(target, "%s resists the Chop the Brances!", target:getName():capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Attack target for %d%% weapon damage and attempt to disarm it for %d turns. 
		If the target is a plant, it also loses %d of all powers.]]):
		format(t.getDamage(self, t)*100, t.getDuration(self, t), t.getPowerloss(self, t))
	end,
}
newTalent{
	name = "Log Throw", short_name = "WOODCUTTER_LOG_THROW",
	type = {"technique/woodcutter", 3},
	mode = "activated",
	require = techs_req3,
	points = 5,
	target = function(self, t)
		return {type="ball", radius=0, range=self:getTalentRange(t), talent=t, friendlyfire=true}
	end,
	speed = "standard",
	range = 4,
	cooldown = 10,
	getDamage = function(self, t) return self:combatTalentPhysicalDamage(t, 1, 320) end,
	getDuration = function(self, t) return self:combatTalentLimit(t, 10, 3, 5) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local damage = self:physicalCrit(t.getDamage(self, t))
		self:project(tg, x, y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target then
				-- deal damage to primary target
				DamageType:get(DamageType.PHYSICAL).projector(self, target.x, target.y, DamageType.PHYSICAL, damage, {}, nil)

				if target:canBe("daze") then
					target:setEffect(target.EFF_DAZED, t.getDuration(self, t), {apply_power=self:combatPhysicalpower()})
				else
					game.logSeen(target, "%s resists the daze!", target:getName():capitalize())
				end
		
				-- find possible secondary targets
				local first = target
				local affected = {}
				self:project({type="ball", selffire=false, friendlyfire=false, x=target.x, y=target.y, radius=1, range=99}, target.x, target.y, function(bx, by)
					local actor = game.level.map(bx, by, Map.ACTOR)
					if actor and not affected[actor] and self:reactionToward(actor) < 0 then
						affected[actor] = true
					end
				end)
				affected[first] = nil
				local possible_targets = table.listify(affected)
		
				-- check if any targets were found
				if #possible_targets ~= 0 then 
					-- pick random target
					local act = rng.tableRemove(possible_targets)[1]
					
					-- deal damage to secondary target
					DamageType:get(DamageType.PHYSICAL).projector(self, act.x, act.y, DamageType.PHYSICAL, damage/2, {}, nil)
				end
			end
		end)

		game.level.map:particleEmitter(x, y, 2, "circle_moving", {y=-14*8/64, yv=8, appear_size=0, base_rot=0, a=240, appear=6, limit_life=8, speed=0, img="woodcutter_log", radius=-0.18})
		return true
	end,
	info = function(self, t)
		return ([[Deal %d physical damage to target and daze it for %d turns. Deal %d damage to random enemy next to the target.]]):
		format(damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)), t.getDuration(self, t), damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)/2))
	end,
}
newTalent{
	name = "Timber!", short_name = "WOODCUTTER_TIMBER",
	type = {"technique/woodcutter", 4},
	mode = "passive",
	require = techs_req4,
	points = 5,
	getDamage = function(self, t) return self:combatTalentPhysicalDamage(t, 40, 1000) end,
	getDamagePercentage = function(self, t) return self:combatTalentLimit(t, 100, 15, 50) end,
	info = function(self, t)
		return ([[After you kill an enemy with a melee attack, you deal physical damage to random adjacent enemy equal to %d%% killed unit's max hp, up to %d.]]):
		format(damDesc(self, DamageType.PHYSICAL, t.getDamagePercentage(self, t)),damDesc(self, DamageType.PHYSICAL,  t.getDamage(self, t)))
	end,
}