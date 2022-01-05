local Birther = require "engine.Birther"
local ActorTalents = require "engine.interface.ActorTalents"
local DamageType = require "engine.DamageType"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local Map = require "engine.Map"

class:bindHook("Actor:takeHit", function(self, data)
	if self.knowTalent and self:knowTalent(self.T_WOODCUTTER_RESISTANCE_ROOTS) then
		local threshold = self:callTalent(self.T_WOODCUTTER_RESISTANCE_ROOTS, "getThreshold")
		local damageMultiplier =self:callTalent(self.T_WOODCUTTER_RESISTANCE_ROOTS, "getDamageMultiplier")
		if data.value <= threshold then
			data.value = data.value * damageMultiplier
			return true
		end
	end
	return false
end)

	
class:bindHook("ToME:load", function(self, data)
	ActorTalents:loadDefinition("/data-woodcutter/talents/techniques/techniques.lua")
	ActorTalents:loadDefinition("/data-woodcutter/talents/spell/spell.lua")
	ActorTalents:loadDefinition("/data-woodcutter/talents/misc/misc.lua")
	Birther:loadDefinition("/data-woodcutter/birth/classes/warrior.lua")
	ActorTemporaryEffects:loadDefinition("/data-woodcutter/timed_effects.lua")
	DamageType:loadDefinition("/data-woodcutter/damage_types.lua")
	
	-- Load Actor resources
	dofile("/data-woodcutter/resources.lua")
end)

class:bindHook("Actor:actBase:Effects", function(self, data)
	if self.knowTalent and self:knowTalent(self.T_WOODCUTTER_SOUNDS) and self:hasEffect(self.EFF_WOODCUTTER_SOUNDS) then
		self:callTalent(self.T_WOODCUTTER_SOUNDS, "getTickEffect")
	end
end)

class:bindHook("Combat:attackTargetWith", function(self, data)
	hitted = data.hitted
	target = data.target
	
	-- Axe Sharpening
	if hitted and data.weapon and not target.dead and self:knowTalent(self.T_WOODCUTTER_AXE_SHARPENING) and self:isTalentActive(self.T_WOODCUTTER_AXE_SHARPENING) then
		-- check for axe
		if data.weapon.talented == "axe" then
			local dam = self:callTalent(self.T_WOODCUTTER_AXE_SHARPENING, "getDamage")
			DamageType:get(DamageType.PHYSICAL).projector(self, target.x, target.y, DamageType.PHYSICAL, dam)
		end
	end
	
	-- Axe Spiriting
	if hitted and not target.dead and self:knowTalent(self.T_WOODCUTTER_AXE_SPIRITING) and self:isTalentActive(self.T_WOODCUTTER_AXE_SPIRITING) then
		-- check for axe
		if data.weapon.talented == "axe" then
			local dam = self:callTalent(self.T_WOODCUTTER_AXE_SPIRITING, "getDamage")
			DamageType:get(DamageType.PHYSICAL).projector(self, target.x, target.y, DamageType.DARKNESS, dam)
		end
	end

	-- Timber! proc
	if hitted and target.dead and self.knowTalent and self:knowTalent(self.T_WOODCUTTER_TIMBER) then

		-- calculate damage
		local dam = self:callTalent(self.T_WOODCUTTER_TIMBER, "getDamage")
		local damP = self:callTalent(self.T_WOODCUTTER_TIMBER, "getDamagePercentage")
		local damMax = target.max_life * damP / 100
		dam = math.min(dam, damMax)

		-- find possible targets
		local first = target
		local affected = {}
		self:project({type="ball", selffire=false, friendlyfire=false, x=target.x, y=target.y, radius=1, range=0}, target.x, target.y, function(bx, by)
			local actor = game.level.map(bx, by, Map.ACTOR)
			if actor and not affected[actor] and self:reactionToward(actor) < 0 then
				affected[actor] = true
			end
		end)
		affected[first] = nil
		local possible_targets = table.listify(affected)

		-- check if no targets were found
		if #possible_targets ~= 0 then 
			-- pick random target
			local act = rng.tableRemove(possible_targets)[1]
			
			-- deal damage to selected target
			DamageType:get(DamageType.PHYSICAL).projector(self, act.x, act.y, DamageType.PHYSICAL, dam, {}, nil)
		end
	end

end)
