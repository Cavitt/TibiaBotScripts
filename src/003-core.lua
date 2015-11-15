Core = (function()

	local function debug(message, type)
		xeno.luaSendChannelMessage(_script.debugChannel, type or CHANNEL_YELLOW, ':', message)
	end

	local function overflowText(str, len, ellipsis)
		return #str > len and string.sub(str, 1, len) .. ellipsis or str
	end

	local function formatTime(seconds, simpleFormat)
		local d, h, m, s = math.floor(seconds / 86400),
		                   math.floor(seconds / 3600) % 24,
		                   math.floor(seconds / 60) % 60,
				   seconds % 60
	        return simpleFormat and string.format('%02d:%02d', 24*d+h, m) or string.format('%02d:%02d:%02d:%02d', d, h, m, s)
	end

	local function formatNumber(n)
		local n = tonumber(string.format('%.2f', n))
		if not n then
			return '0'
		end
		local left, num, right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
		return left .. string.reverse(string.gsub(string.reverse(num), '(%d%d%d)','%1,')) .. right
	end

	local function titlecase(str)
		return string.gsub(str, "(%a)([%w_']*)", function(first, rest)
			return string.upper(first) .. string.lower(rest)
		end)
	end

	local function flattenItemCounts(items)
		-- Iterate through itemid indexed counts
		-- flatten to array with count and itemid combined
		local list = {}
		for itemid, count in pairs(items) do
			list[#list+1] = xeno.getItemNameByID(itemid) .. (count > 1 and ' (x' .. count .. ')' or '')
		end
		return list
	end

	local function formatList(items, delim, prefix)
		prefix = prefix or ''
		local message = nil
		if #items > 1 then
			if delim then
				message = string.rep(prefix .. '%s' .. delim, #items-1) .. prefix .. '%s'
			else
				message = string.rep('%s, ', #items-1) .. 'and %s'
			end
		else
			message = '%s'
		end
		return string.format(message, unpack(items))
	end

	local function getMemoryUsage()
		return collectgarbage('count') * 1024
	end

	local function freeMemory()
		local prev = getMemoryUsage()
		collectgarbage()
		return prev - getMemoryUsage()
	end

	local function pingDelay(delay)
		if type(delay) == 'table' then
			return math.max(math.random(unpack(delay)), xeno.ping())
		end
		return math.max(delay, xeno.ping())
	end

	local function throttle(action, func, ...)
		local currentTime = os.clock() * 1000
		if currentTime - action.last > action.limit then
			action.last = currentTime
			func(...)
		end
	end

	local function clearTimeout(id)
		_timers[id] = nil
	end

	local function clearWhen(event, id)
		_events[event][id] = nil
	end

	local function setTimeout(callback, timeout)
		_timerIndex = _timerIndex + 1
		_timers[_timerIndex] = {callback, (os.clock() * 1000) + timeout, nil, 0}
		return _timerIndex
	end

	local function setInterval(callback, interval, loops)
		_timerIndex = _timerIndex + 1
		_timers[_timerIndex] = {callback, (os.clock() * 1000) + interval, interval, loops}
		return _timerIndex
	end

	local function when(event, condition, callback)
		-- Labels are simpler, simple hash lookup with callback
		if event == EVENT_LABEL then
			_events[EVENT_LABEL][condition] = callback
			return condition
		end

		-- Valid conditions:
		-- string: Message matches string exactly
		-- table: Contains a pattern and optional match comparisons {pattern, firstMatch, secondMatch, ...}
		-- Any other event needs to match a pattern condition
		local id = #_events[event]+1
		_events[event][id] = {
			condition = condition,
			callback = callback,
			timeout = nil
		}

		return id
	end

	local function checkTimers()
		local currentTime = os.clock() * 1000
		local success = nil
		local index = nil
		local timer = nil
		repeat
			success, index, timer = pnext(_timers, index)
			-- Timer is false, must be pending a remove, remove now
			if not timer and index then
				_timers[index] = nil
				return
			end
			if success and index and timer then
				-- Check expiration
				if currentTime >= timer[2] then
					-- Execute
					timer[1](index)
					-- Timer may have killed itself, check if it still exists
					if _timers[index] then
						-- Increase expiration for next interval
						if timer[3] then
							_timers[index][2] = currentTime + timer[3]
						end
						-- Timer expires at some point
						if timer[4] then
							-- Decrement loop
							_timers[index][4] = timer[4] - 1
							-- Loops finished
							if timer[4] < 1 then
								_timers[index] = false
							end
						end
					end
				end
			end
		until not index or not success or not timer
	end

	local function checkEvents(eventType, message, ...)
		local success = nil
		local index = nil
		local event = nil
		if _events[eventType] then
			repeat
				success, index, event = pnext(_events[eventType], index)
				-- Event is false, must be pending a remove, remove now
				if not event and index then
					_events[eventType][index] = nil
					return
				end
				if success and index and event then
					local conditionType = type(event.condition)
					-- Always true
					if conditionType == 'nil' then
						_events[eventType][index] = nil
						event.callback(message, ...)
					-- Exact string check (or wildcard)
					elseif conditionType == 'string' then
						if event.condition == message then
							_events[eventType][index] = nil
							event.callback(message, ...)
						end
					-- Pattern check
					elseif conditionType == 'table' then
						local match = {string.match(event.condition)}
						if match[1] then
							_events[eventType][index] = nil
							event.callback(message, match, ...)
						end
					end
				end
			until not index or not success or not event
		end
	end

	local function split(str, sep)
		local res = {}
		for v in string.gmatch(str, "([^" .. sep .. "]+)") do
			res[#res + 1] = v
		end
		return res
	end

	local function trim(str)
		return string.gsub(str, "^%s*(.-)%s*$", "%1")
	end

	local function isXenoBotBinary()
		return _script.xenoversion:find('Binary') ~= nil
	end

	local function getXenoVersion()
		local data = split(_script.xenoversion, '.')
		return tonumber(data[#data])
	end

	local function getPositionFromDirection(pos, dir, len)
		local n = len or 1
		if (dir == NORTH) then
			pos.y = pos.y - n
		elseif (dir == SOUTH) then
			pos.y = pos.y + n
		elseif (dir == WEST) then
			pos.x = pos.x - n
		elseif (dir == EAST) then
			pos.x = pos.x + n
		elseif (dir == NORTHWEST) then
			pos.y = pos.y - n
			pos.x = pos.x - n
		elseif (dir == NORTHEAST) then
			pos.y = pos.y - n
			pos.x = pos.x + n
		elseif (dir == SOUTHWEST) then
			pos.y = pos.y + n
			pos.x = pos.x - n
		elseif (dir == SOUTHEAST) then
			pos.y = pos.y + n
			pos.x = pos.x + n
		end
		return pos
	end

	local function getSelfLookPosition(range)
		return getPositionFromDirection(xeno.getSelfPosition(), xeno.getSelfLookDirection(), range or 1)
	end

	local function getPosFromString(str)
		local pos = {}
		string.gsub(str, "(%d+)", function(w) return table.insert(pos,tonumber(w)) end)
		return {x=(pos[1] or 0), y=(pos[2] or 0), z=(pos[3] or 0)}
	end

	local function cleanLabel(str)
		-- Transform entity to '>'
		--str = string.gsub(str, '&gt;', '>')
		-- Remove semi-colon
		return string.sub(str, 1, -2)
	end

	local function countPairs(tbl)
		local n = 0
		for k,v in pairs(tbl) do
			n = n + 1
		end
		return n
	end

	function indexTable(tbl, lowercase)
		if not tbl or #tbl == 0 then
			return nil
		end
		if type(tbl) ~= 'table' then
			tbl = {tbl}
		end
		local keyValues = {}
		for i = 1, #tbl do
			local key = tbl[i]
			keyValues[lowercase and key:lower() or key] = true
		end
		return keyValues
	end

	local function getTimeUntilServerSave()
		local curTime = os.time()
		local utc, loc = os.date("!*t", curTime), os.date("*t", curTime)
		loc.isdst = false
		local offset = os.time(loc) - os.time(utc)
		local UTCNow = os.time()
		local UTCTable = os.date("*t", UTCNow)
		local dstValue = UTCTable.isdst and 7200 or 3600
		local targetTime = {year=UTCTable.year, month=UTCTable.month, day=UTCTable.day, hour=9, min=59}  
		local timeDifference = (((os.time(targetTime) - (UTCNow + dstValue)) + offset)/60)/60
		local hoursLeft = timeDifference
		if hoursLeft < 0 then
			hoursLeft = 24 + hoursLeft
		end
		return hoursLeft   
	end

	local function getDistanceBetween(pos1, pos2)
		return math.max(math.abs(pos1.x - pos2.x), math.abs(pos1.y - pos2.y))
	end

	local function sortPositionsByDistance(pos, positions, floorWeight)
		local sorted = positions
		table.sort(sorted, function(a, b)
			local floorA = 0
			local floorB = 0
			if floorWeight and pos.z and a.z and b.z then
				floorA = floorWeight * (math.abs(pos.z - a.z))
				floorB = floorWeight * (math.abs(pos.z - b.z))
			end
			return (getDistanceBetween(pos, a) + floorA) < (getDistanceBetween(pos, b) + floorB)
		end)
		return sorted
	end

	local function talk(messages, callback)
		local msgCount = #messages
		local responses = {}
		local function sayMessage(index)
			-- Delay messages
			local msg = messages[index]
			setTimeout(function()
				-- Last message, callback
				if index == msgCount then
					callback(responses)
				-- Recurse
				else
					sayMessage(index+1)
				end
			end, pingDelay(DELAY.RANGE_TALK))

			-- Record response to this message
			when(EVENT_NPC, nil, function(response, npc)
				-- Update response
				responses[#responses+1] = response
			end)
			
			-- Send a single message to the NPC
			xeno.selfNpcSay(msg)
			debug('NPC:: ' .. msg)
		end

		-- Send the first message and start recursing
		sayMessage(1)
	end

	local function clearWalkerPath()

		local function destroyFurniture(x, y, z)
			local weapon = xeno.getWeaponSlotData().id
			-- Wand, rods, and distance weapons CANNOT destroy furniture
			-- Attempt to detect an item in the main backpack that can
			if weapon == 0 or DISTANCE_WEAPONS[weapon] or RODS[weapon] or WANDS[weapon] then
				weapon = 0
				-- Look through main backpack
				local mainbp = _backpacks['Main']
				for spot = 0, xeno.getContainerItemCount(mainbp) - 1 do
					local item = xeno.getContainerSpotData(mainbp, spot)
					-- This item can kill furniture
					if ITEM_LIST_FURNITURE_DESTROYERS[item.id] then
						-- Save item
						weapon = item.id
						break
					end
				end
			end

			-- TODO: make Nick add moveGroundItemToGround(fromX, fromY, toX, toY) or pushTopObject...
			-- once added, push item to free position if a breaking weapon isn't found
			if weapon > 0 then
				xeno.selfUseItemWithGround(weapon, x, y, z)
			end
		end

		local function attackCreature(cid)
			-- Make sure we're not already attacking the creature
			if cid ~= xeno.getSelfTargetID() then
				xeno.attackCreature(cid)
			end    
			-- TODO: read spell/rune from shooter, apply directly to creature's face
		end

		local function clearTile(x, y, z)
			local item = xeno.getTileUseTargetID(x, y, z)
			local selfPos = xeno.getSelfPosition()
			local distance = getDistanceBetween(selfPos, {x=x,y=y,z=z})

			-- Creature
			if item.id == 99 and distance < 3 then
				local cid = item.count
				local index = xeno.getCreatureListIndex(cid)
				-- Monster
				if xeno.isCreatureMonster(index) then
					attackCreature(cid)
					return true
				end
				-- Not attackable, look at other tiles
				return false
			end

			-- Furniture
			if xeno.isItemFurniture(item.id) then
				destroyFurniture(x, y, z)
				return true
			end

			return false
		end

		-- Attempt to clear tiles in a specific order
		-- There's a better way, I guarantee it.
		local priorities = {
			[NORTH] = {NORTH, NORTHWEST, NORTHEAST, WEST, EAST, SOUTH, SOUTHWEST, SOUTHEAST},
			[EAST] = {EAST, NORTHEAST, SOUTHEAST, NORTH, SOUTH, WEST, NORTHWEST, SOUTHWEST},
			[SOUTH] = {SOUTH, SOUTHWEST, SOUTHEAST, WEST, EAST, NORTH, NORTHWEST, NORTHEAST},
			[WEST] = {WEST, NORTHWEST, SOUTHWEST, NORTH, SOUTH, EAST, NORTHEAST, SOUTHEAST}
		}

		-- Search for valid tiles around player to clear
		local pos = xeno.getSelfPosition()
		local directions = priorities[xeno.getSelfLookDirection()]
		local index = 1
		local valid = false
		repeat
			local tilePos = getPositionFromDirection({x=pos.x, y=pos.y}, directions[index], 1)
			valid = clearTile(tilePos.x, tilePos.y, pos.z)
			index = index + 1
		until valid or index > #directions

		-- Search entire screen if nothing found nearby
		if not valid then
			-- Populate all non-walkable tiles on-screen
			local tiles = {}
			for x = -7, 7 do
				for y = -7, 7 do
					-- Tile not walkable
					if xeno.getTileIsWalkable(pos.x+x, pos.y+y, pos.z) then
						tiles[#tiles+1] = {x=pos.x+x, y=pos.y+y, z=pos.z}
					end
				end
			end
			-- Sort by distance
			tiles = sortPositionsByDistance(pos, tiles)
			-- Find tile to clear
			local screenIndex = 1
			local screenValid = false
			repeat
				local tpos = tiles[screenIndex]
				screenValid = clearTile(tpos.x, tpos.y, tpos.z)
				screenIndex = screenIndex + 1
			until screenValid or screenIndex > #tiles
		end
	end

	local function cast(words)
		return xeno.getSelfSpellCooldown(words) == 0 
			and xeno.getSelfSpellRequirementsMet(words)
			and xeno.selfSay(words)
	end

	local function cureConditions(callback)
		local conditions = {
			poisoned = {
				spell = 'exana pox',
				voc = {druid=true, sorcerer=true, paladin=true, knight=true}
			},
			burning = {
				spell = 'exana flam',
				voc = {druid=true}
			},
			cursed = {
				spell = 'exana mort',
				voc = {paladin=true}
			},
			bleeding = {
				spell = 'exana kor',
				voc = {druid=true, knight=true}
			},
			electrified = {
				spell = 'exana vis',
				voc = {druid=true}
			}
		}

		local casted = false
		for condition, data in pairs(conditions) do
			if xeno.getSelfFlag(condition) and not data.cured then
				-- Only attempt once per condition
				data.cured = true
				-- Cure the condition
				if data.voc[_script.vocation:lower()] then
					casted = true
					cast(data.spell)
					break									
				end
			end
		end

		-- Attempted to heal, recurse to heal more conditions
		if casted then
			setTimeout(function()
				cureConditions(callback)
			end, 1500)
		elseif callback then
			callback()
		end
	end

	local function isCorpseOpen()
		local index = -1
		while (index < 16) do
			index = index + 1
			local container = xeno.getContainerName(index)
			local isCorpse = string.find(container, "The") or 
				string.find(container, "Demonic") or 
				string.find(container, "Dead") or 
				string.find(container, "Slain") or 
				string.find(container, "Dissolved") or 
				string.find(container, "Remains") or 
				string.find(container, "Elemental") or 
				xeno.isItemCorpse(xeno.getContainerID(index))
			if(xeno.getContainerOpen(index) and isCorpse)then
				return true
			end
		end
		return false
	end

	local function getWalkableTiles(center, range)
		local walkables = {}
		local base = center
		range = (range > 10) and 10 or range
		for x = -range, range do
			for y = -range, range do
				if xeno.getTileIsWalkable(base.x + x, base.y + y, base.z) then
					walkables[#walkables+1] = {x = base.x + x, y = base.y + y, z = base.z}
				end
			end
		end
		return walkables
	end

	local function getDirectionTo(pos1, pos2)
		local dir = NORTH
		if (pos1.x > pos2.x) then
			dir = WEST
			if (pos1.y > pos2.y) then
				dir = NORTHWEST
			elseif (pos1.y < pos2.y) then
				dir = SOUTHWEST
			end
		elseif (pos1.x < pos2.x) then
			dir = EAST
			if (pos1.y > pos2.y) then
				dir = NORTHEAST
			elseif (pos1.y < pos2.y) then
				dir = SOUTHEAST
			end
		else
			if (pos1.y > pos2.y) then
				dir = NORTH
			elseif (pos1.y < pos2.y) then
				dir = SOUTH
			end
		end
		return dir
	end

	local function getSelfName()
		return xeno.getCreatureName(xeno.getCreatureListIndex(xeno.getSelfID()))
	end
	
	local function checkSoftBoots()
		-- Check softboots
		local playerMana = math.abs((xeno.getSelfMana() / xeno.getSelfMaxMana()) * 100)
		if _config['Soft Boots']['Mana-Percent'] > 0 then
			local playerBoots = xeno.getFeetSlotData().id
			local inProtectionZone = xeno.getSelfFlag('inpz')
			local needSoftBoots = not inProtectionZone and playerMana <= _config['Soft Boots']['Mana-Percent']
			local mainbp = _backpacks['Main']
			-- Needs soft boots
			if needSoftBoots then
				-- Needs to swap normal or worn boots with softboots
				if playerBoots ~= ITEMID.SOFTBOOTS_ACTIVE then
					-- Search for soft boots in main backpack
					for spot = 0, xeno.getContainerItemCount(mainbp) - 1 do
						-- Equip soft boots
						if xeno.getContainerSpotData(mainbp, spot).id == ITEMID.SOFTBOOTS then
							xeno.containerMoveItemToSlot(mainbp, spot, "feet", 1)
							_script.equipped['feet'] = true;
							break
						end
					end
				end
			-- Need to swap active or worn softboots with normal boots
			elseif playerBoots == 0 or playerBoots == ITEMID.SOFTBOOTS_ACTIVE or playerBoots == ITEMID.SOFTBOOTS_WORN then
				-- Search for regular boots
				for spot = 0, xeno.getContainerItemCount(mainbp) - 1 do
					-- Equip regular boots
					if NORMAL_BOOTS[xeno.getContainerSpotData(mainbp, spot).id] then
						xeno.containerMoveItemToSlot(mainbp, spot, "feet", 1)
						_script.equipped['feet'] = false;
						break
					end
				end
			end
		end
	end

	local _delayTimeout = nil
	local function delayWalker()
		if _delayTimeout then
			clearTimeout(_delayTimeout)
			_delayTimeout = nil
		end
		_delayTimeout = setTimeout(function()
			xeno.setWalkerEnabled(false)
			error('Action timed out. Please contact support.')
		end, DELAY.WALKER_TIMEOUT - 100)
		return xeno.delayWalker(DELAY.WALKER_TIMEOUT)
	end

	local function resumeWalker()
		if _delayTimeout then
			clearTimeout(_delayTimeout)
			_delayTimeout = nil
		end
		return xeno.delayWalker(0)
	end

	-- Export global functions
	return {
		debug = debug,
		overflowText = overflowText,
		formatTime = formatTime,
		formatNumber = formatNumber,
		titlecase = titlecase,
		formatList = formatList,
		getMemoryUsage = getMemoryUsage,
		freeMemory = freeMemory,
		pingDelay = pingDelay,
		throttle = throttle,
		clearTimeout = clearTimeout,
		clearWhen = clearWhen,
		setTimeout = setTimeout,
		setInterval = setInterval,
		when = when,
		checkTimers = checkTimers,
		checkEvents = checkEvents,
		split = split,
		trim = trim,
		isXenoBotBinary = isXenoBotBinary,
		getXenoVersion = getXenoVersion,
		getSelfLookPosition = getSelfLookPosition,
		getPosFromString = getPosFromString,
		cleanLabel = cleanLabel,
		countPairs = countPairs,
		indexTable = indexTable,
		getTimeUntilServerSave = getTimeUntilServerSave,
		sortPositionsByDistance = sortPositionsByDistance,
		talk = talk,
		clearWalkerPath = clearWalkerPath,
		cast = cast,
		cureConditions = cureConditions,
		isCorpseOpen = isCorpseOpen,
		getWalkableTiles = getWalkableTiles,
		getDirectionTo = getDirectionTo,
		getPositionFromDirection = getPositionFromDirection,
		getDistanceBetween = getDistanceBetween,
		getSelfName = getSelfName,
		checkSoftBoots = checkSoftBoots,
		flattenItemCounts = flattenItemCounts,
		delayWalker = delayWalker,
		resumeWalker = resumeWalker
	}
end)()
