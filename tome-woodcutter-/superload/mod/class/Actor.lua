
local _M = loadPrevious(...)

local base_init = _M.init
function _M:init(t, no_default)
  -- Do stuff "before" loading the original file
	t.firewood_regen = t.firewood_regen or 0 -- Firewood does not regen
	t.max_firewood = t.max_firewood or 6
	t.firewood = t.firewood or 6

  -- execute the original function
  local retval = base_init(self, t, no_default)

  
  -- Do stuff "after" loading the original file


  -- return whatever the original function would have returned
  return retval
end

local base_onStatChange = _M.onStatChange
function _M:onStatChange(stat, v)
  -- Do stuff "before" loading the original file

  if stat == self.STAT_STR then
    -- firewood
    local multi_firewood = 0.1
    self:incMaxFirewood(multi_firewood * v)
  elseif stat == self.STAT_CON then
    -- firewood
    local multi_firewood = 0.1
    self:incMaxFirewood(multi_firewood * v)
  end

  -- execute the original function
  local retval = base_onStatChange(self, stat, v)

  
  -- Do stuff "after" loading the original file


  -- return whatever the original function would have returned
  return retval
end



return _M

