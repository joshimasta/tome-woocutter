-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2019 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

base_size = 32
can_shift = true

return { generator = function()
	local ad = rng.range(0, 360)
	local a = math.rad(ad)
	local dir = math.rad(ad + 90)
	local r = rng.range(1, 18)
	local dirv = math.rad(1)
	--local col = rng.range(20, 80)/255

	return {
--		trail = 1,
		life = 20,
		size = rng.range(6, 8), sizev = -0.15, sizea = 0,

		x = r * math.cos(a), xv = rng.float(-0.2, 0.2), xa = 0,
		y = r * math.sin(a), yv = rng.float(-0.3, 0.1), ya = -0.03,
		dir = dir, dirv = dirv, dira = dir / 20,
		vel = 0, velv = 0, vela = 0,

		r = rng.range(245, 255)/255,  rv = 0, ra = 0,
		g = rng.range(235, 255)/255,  gv = 0, ga = 0,
		b = rng.range(5, 15)/255,  bv = 0, ba = 0,
		a = rng.range(70, 100)/255,  av = 0, aa = 0,
	}
end, },
function(self)
	self.ps:emit(1)
end,
40
