function DamageType.initState(state)
	if state == nil then return {}
	elseif state == true or state == false then return {}
	else return state end
end

-- Loads the implicit crit if one has not been passed.
function DamageType.useImplicitCrit(src, state)
	if state.crit_set then return end
	state.crit_set = true
	if not src.turn_procs then
		state.crit_type = false
		state.crit_power = 1
	else
		state.crit_type = src.turn_procs.is_crit
		state.crit_power = src.turn_procs.crit_power or 1
		src.turn_procs.is_crit = nil
		src.turn_procs.crit_power = nil
	end
end

local useImplicitCrit = DamageType.useImplicitCrit
local initState = DamageType.initState

newDamageType{
	name = "bonfire healing", type = "WOODCUTTER_BONFIRE_HEAL_STAMINA",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local target = game.level.map(x, y, Map.ACTOR)

		if target and target.knowTalent and target:knowTalent(target.T_WOODCUTTER_BONFIRE) then
			local heal = target:callTalent(target.T_WOODCUTTER_BONFIRE, "getHealing", target)
			target:heal(heal, target)
			local stamina = target:callTalent(target.T_WOODCUTTER_BONFIRE, "getStamina", target)
			target:staminaInc(stamina, target)
		end
	end,
}