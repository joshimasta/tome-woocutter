

local _M = loadPrevious(...)

--add axe mastery
table.insert(_M.weapon_talents.axe, 1, "T_AXE_MASTERY")


--ghost of the woods spell power
local base_combatSpellpowerRaw = _M.combatSpellpowerRaw
function _M:combatSpellpowerRaw(add)
  -- Do stuff "before" loading the original file
  add = add or 0

	if self:knowTalent(self.T_WOODCUTTER_FAMILIAR) then
		add = add + self:callTalent(self.T_WOODCUTTER_FAMILIAR,"getSpellpower") * self:getStr() / 100
	end

  -- execute the original function
  local d, am = base_combatSpellpowerRaw(self, add)

  
  -- Do stuff "after" loading the original file


  -- return whatever the original function would have returned
  return d, am

end

return _M 
