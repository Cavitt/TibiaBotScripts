Targeter = (function()
	
	-- Imports
	local clearTimeout = Core.clearTimeout
	local setInterval = Core.setInterval
	local getDistanceBetween = Core.getDistanceBetween
	
	local function targetingGetCreatureThreshold(list, range, amount, multifloor, floor)
		local targets = {}
		local count = 0
		local pos = xeno.getSelfPosition()
		for i = CREATURES_LOW, CREATURES_HIGH do
			local name = xeno.getCreatureName(i)
			-- Is this creature invited to die?
			if list[string.lower(name)] then
				-- Position & Distance
				local cpos = xeno.getCreaturePosition(i)
				local distance = getDistanceBetween(pos, cpos)
				if ((pos.z + (floor or 0)) == cpos.z or multifloor) and distance <= range then
					-- Normal creature checks
					if xeno.getCreatureVisible(i) and xeno.getCreatureHealthPercent(i) > 0 and xeno.isCreatureMonster(i) then
						targets[#targets+1] = xeno.getCreatureIDFromIndex(i)
						count = count + 1
					end
				end
			end
		end
		return {count >= amount, targets}
	end

	-- Export global functions
	return {
		targetingGetCreatureThreshold = targetingGetCreatureThreshold
	}
end)()
