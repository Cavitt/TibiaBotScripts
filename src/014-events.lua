do
	-- Imports
	local formatNumber = Core.formatNumber
	local formatTime = Core.formatTime
	local freeMemory = Core.freeMemory
	local throttle = Core.throttle
	local clearTimeout = Core.clearTimeout
	local setTimeout = Core.setTimeout
	local setInterval = Core.setInterval
	local checkTimers = Core.checkTimers
	local checkEvents = Core.checkEvents
	local delayWalker = Core.delayWalker
	local resumeWalker = Core.resumeWalker
	local split = Core.split
	local pingDelay = Core.pingDelay
	local getTimeUntilServerSave = Core.getTimeUntilServerSave
	local clearWalkerPath = Core.clearWalkerPath
	local getPositionFromDirection = Core.getPositionFromDirection
	local getDistanceBetween = Core.getDistanceBetween
	local getSelfName = Core.getSelfName
	local cast = Core.cast
	local cureConditions = Core.cureConditions
	local checkSoftBoots = Core.checkSoftBoots
	local log = Console.log
	local warn = Console.warn
	local openConsole = Console.openConsole
	local openDebugChannel = Console.openDebugChannel
	local openPrivateMessageConsole = Console.openPrivateMessageConsole
	local cleanContainers = Container.cleanContainers
	local resetContainers = Container.resetContainers
	local getTotalItemCount = Container.getTotalItemCount
	local setupContainers = Container.setupContainers
	local whenContainerUpdates = Container.whenContainerUpdates
	local hudUpdateDimensions = Hud.hudUpdateDimensions
	local hudUpdatePositions = Hud.hudUpdatePositions
	local hudItemUpdate = Hud.hudItemUpdate
	local hudQueryLootChanges = Hud.hudQueryLootChanges
	local hudQuerySupplyChanges = Hud.hudQuerySupplyChanges
	local loadConfigFile = Ini.loadConfigFile
	local shopSellLoot = Npc.shopSellLoot
	local walkerLabelExists = Walker.walkerLabelExists
	local walkerStartPath = Walker.walkerStartPath
	local walkerGetClosestLabel = Walker.walkerGetClosestLabel
	local walkerReachNPC = Walker.walkerReachNPC
	local walkerGetDoorDetails = Walker.walkerGetDoorDetails
	local walkerUseTrainer = Walker.walkerUseTrainer
	local walkerCapacityDrop = Walker.walkerCapacityDrop
	local walkerRestoreMana = Walker.walkerRestoreMana
	local walkerTravel = Walker.walkerTravel
	local setDynamicSettings = Settings.setDynamicSettings
	local checkAllSupplyThresholds = Supply.checkAllSupplyThresholds
	local resupply = Supply.resupply
	local targetingGetCreatureThreshold = Targeter.targetingGetCreatureThreshold

	local LABEL_ACTIONS = {
		-- Player & Supply Check [huntcheck|id]
		['huntcheck'] = function(group, id, failLabel, skipSupplyCheck)
			skipSupplyCheck = skipSupplyCheck == 'true'
			local state = 'Hunting'
			local route = '--'

			-- Pause walker
			delayWalker()

			-- Drop vials / gold
			walkerCapacityDrop()

			-- Check logout conditions
			local logoutReason = nil
			local logoutConfig = _config['Logout']

			-- Condition: Forced
			if _script.forceLogoutQueued then
				logoutReason = 'Requested by user.'
			-- Condition: Low Stamina
			elseif logoutConfig['Stamina'] and logoutConfig['Stamina'] > 0 and (xeno.getSelfStamina() / 60) < logoutConfig['Stamina'] then
				logoutReason = 'Low stamina.'
			-- Condition: Reached Target level
			elseif logoutConfig['Level'] and logoutConfig['Level'] > 0 and xeno.getSelfLevel() >= logoutConfig['Level'] then
				logoutReason = 'Desired level reached.'
			-- Condition: near Server Save
			elseif logoutConfig['Server-Save'] and logoutConfig['Server-Save'] > 0 and getTimeUntilServerSave() < logoutConfig['Server-Save'] then
				logoutReason = 'Close to server save.'
			-- Condition: Reached Time limit
			elseif logoutConfig['Time-Limit'] and logoutConfig['Time-Limit'] > 0 and ((os.time() - _script.start) / 3600) >= logoutConfig['Time-Limit'] then
				logoutReason = 'Time limit reached.'
			end

			-- Found a reason to logout
			if logoutReason then
				state = 'Exiting'
				-- Train or logout
				local action = 'logout'
				if logoutConfig['Train-Skill'] and logoutConfig['Train-Skill'] ~= 'none' then
					action = 'train'
					_script.trainingQueued = true
				else
					_script.logoutQueued = true
				end
				log('Returning to ' .._script.town.. ' to ' .. action .. '. ' .. logoutReason)
				-- Clean backpacks
				cleanContainers(_backpacks['Loot'], ITEM_LIST_SKINNABLE_LOOT, nil, true)
				-- Route system
				if failLabel then
					xeno.gotoLabel(failLabel, true)
				-- Regular system
				else
					xeno.gotoLabel('huntexit|' .. id)
				end
			-- Continue hunting
			else
				-- Check our state
				local supplies = not skipSupplyCheck and checkAllSupplyThresholds() or {}
				local lowSupplies = supplies.min
				local lowCap = not skipSupplyCheck and (xeno.getSelfCap() < _config['Capacity']['Hunt-Minimum']) or false
				local needSoftbootRepair = not skipSupplyCheck and (_config['Soft Boots']['Mana-Percent'] > 0 and getTotalItemCount(ITEMID.SOFTBOOTS_WORN) > 0) or false
				-- Resupply
				if _script.returnQueued or supplies.min or lowCap or needSoftbootRepair then
					state = 'Walking to exit'
					log('Returning to ' .. _script.town .. ' to re-supply.' .. (_script.returnQueued and ' [forced]' or ''))
					-- Clean backpacks
					cleanContainers(_backpacks['Loot'], ITEM_LIST_SKINNABLE_LOOT, nil, true)
					-- Route system
					if failLabel then
						xeno.gotoLabel(failLabel, true)
					-- Regular system
					else
						xeno.gotoLabel('huntexit|'..id)
					end
				-- Continue hunting
				else
					-- Route system
					if failLabel then
						-- Check route status (disable, enabled, random)
						-- random is a 50% chance to take the route
						local routeData = _config['Route']
						if routeData then
							local routeEnabled = routeData[id]
							if routeEnabled == 'random' then
								routeEnabled = math.random(1, 10) > 5 and true or false
							end
							if _script.returnQueued or not routeEnabled then
								xeno.gotoLabel(failLabel, true)
							-- Route enabled, update script state
							else
								route = id
							end
						end
					-- Regular system
					else
						xeno.gotoLabel('huntstart|'..id)
					end
				end
			end
			if not route then route = '--' end
			-- Update script state
			if _config['HUD']['Enabled'] then
				_script.state = state;
				-- We don't currently have a route
				if _script.route == '--' then
					_script.route = route ~= '--' and route:gsub('-', ' ') or '--'
				end
				-- The current label is a route
				if route ~= '--' then
					-- Set the new route
					_script.route = route:gsub('-', ' ')
				end
			end

			-- Resume walker
			resumeWalker()
		end,

		-- Exit spawn and return to town
		['spawnexit'] = function(group)
			-- Update state
			log('Exiting spawn.')
			_script.inSpawn = false
			_script.state = 'Walking to town'

			-- Update round
			_script.round = _script.round + 1

			-- Disable active alarm if running
			if _script.alarmInterval then
				clearTimeout(_script.alarmInterval)
				_script.alarmInterval = nil
				warn('Alarm disabled.')
			end

			-- Clear return queued
			_script.returnQueued = false

			-- Walk to town|spawn~townentrance
			walkerStartPath(_script.town, 'spawn', _script.townentrance or _script.townexit, function()

				-- Cure Conditions
				if _config['General']['Cure-Conditions'] then
					cureConditions()
				end

				-- Trainers
				if _script.trainingQueued then
					walkerStartPath(_script.town, _script.townentrance or _script.townexit, 'trainers', function()
						walkerUseTrainer()
						--assert(false, 'Script finished successfully.')
					end)
				-- Logout
				elseif _script.logoutQueued then
					walkerStartPath(_script.town, _script.townentrance or _script.townexit, 'depot', function()
						log('Hunting complete, logging out.')
						if not _config['Logout']['Exit-Log'] then
							xeno.doSelfLogout()
							assert(false, 'Script finished successfully.')
						else
							os.exit()
						end
					end)
				-- Start resupply process
				else
					resupply()
				end
			end)
		end,

		-- Enter spawn
		['enterspawn'] = function(group)
			log('Entering spawn.')
			_script.state = 'Hunting';
			_script.inSpawn = true;
		end,

		-- Door System
		['door'] = function(group, id, action)
			if action == 'START' then
				local door = walkerGetDoorDetails(id)
				-- Skip to corresponding door label
				if xeno.getTileIsWalkable(door.doorPos.x, door.doorPos.y, door.doorPos.z) then
					xeno.gotoLabel(door.posLabel)
				end
			-- Door position label (ex: door|100|SOUTH)
			else
				-- Door is walkable
				-- Use door in front, step forward until out of doorway
				-- Check if we're on other side of door, if not go back to door|id|START
				local door = walkerGetDoorDetails(id)
				-- Open door if closed
				if not xeno.getTileIsWalkable(door.doorPos.x, door.doorPos.y, door.doorPos.z) then
					xeno.selfUseItemFromGround(door.doorPos.x, door.doorPos.y, door.doorPos.z)
				end
				-- Rush through open door
				xeno.doSelfStep(door.direction)
				xeno.doSelfStep(door.direction)
				-- If walker gets stuck in the next 3 seconds, return to door
				_script.stuckReturnLabel = door.startLabel
				_script.stuckReturnTimer = setTimeout(function()
					_script.stuckReturnLabel = nil
				end, 3000)
			end
		end,

		-- Pick System
		['pick'] = function(group, direction)
			local directions = {['NORTH']=NORTH, ['SOUTH']=SOUTH, ['EAST']=EAST, ['WEST']=WEST}
			local pos = getPositionFromDirection(xeno.getSelfPosition(), directions[direction], 1)
			xeno.selfUseItemWithGround(_script.pick, pos.x, pos.y, pos.z)
		end,

		-- Levitate System
		['levitate'] = function(group, change, direction, nostep)
			local prevFloor = xeno.getSelfPosition().z
			local directions = {['NORTH']=NORTH, ['SOUTH']=SOUTH, ['EAST']=EAST, ['WEST']=WEST}
			local dir = directions[direction]

			-- Pause walker & looter
			delayWalker()
			xeno.setLooterEnabled(false)
			xeno.doSelfTurn(dir)
			xeno.doSelfTurn(dir)

			if not nostep then
				xeno.doSelfStep(dir)
			end

			setTimeout(function()
				if xeno.getSelfPosition().z == prevFloor then
					cast('exani hur ' .. (change == '+' and 'up' or 'down'))
				end
				xeno.setLooterEnabled(true)
				resumeWalker()
			end, 1000)
		end,

		-- Anti-Lure System
		['run'] = function(group, name, id, waitTime)
			-- Reached the end, wait
			if id == 'end' then
				local setIgnore = setTargetingIgnoreEnabled
				-- Pause walker
				delayWalker()
				-- Disable ignore mode
				setIgnore(false)
				-- Enable the walker when there's no more threats
				_script.antiLureCheckInterval = setInterval(function()
					-- Check if we can continue
					local threshold = targetingGetCreatureThreshold(
						_config['Anti Lure']['Creatures'],
						_config['Anti Lure']['Range'],
						_config['Anti Lure']['Amount'],
						false)
					-- Threshold met, stop timer and start walker
					if not threshold[1] then
						clearTimeout(_script.antiLureCheckInterval)
						_script.antiLureCheckInterval = nil
						resumeWalker()
					end
				end, waitTime and tonumber(waitTime) or 20000)
			end
		end,

		-- Traveling (travel|ankrahmun~svargrond)
		['travel'] = function(group, route)
			delayWalker()
			walkerTravel(route, function()
				resumeWalker()
			end, true)
		end,

		-- Edge cases
		['special'] = function(group, param1, param2)
			-- Rafzan Shop (in-spawn shop)
			if param1 == 'RafzanTrade' then
				delayWalker()
				walkerReachNPC('Rafzan', function()
					shopSellLoot({
						[17846] = true,
						[17813] = true,
						[17812] = true,
						[17810] = true,
						[17859] = true
					}, function()
						resumeWalker()
					end)
				end)
			-- Elemental Soils Shop (in-spawn shop)
			elseif param1 == 'SoilsTrade' then
				delayWalker()
				walkerReachNPC('Arkulius', function()
					shopSellLoot({
						[940] = true, -- natural soil
						[941] = true, -- glimmering soil
						[942] = true, -- flawless ice crystal
						[944] = true, -- iced soil
						[945] = true, -- energy soil
						[946] = true, -- eternal flames
						[947] = true, -- mother soil
						[948] = true, -- pure energy
						[954] = true -- neutral matter
					}, function()
						resumeWalker()
					end)
				end)
			elseif param1 == 'SpheresMachine' then
				delayWalker()
				local gemItemId = tonumber(param2) or 678
				local gemCount = getTotalItemCount(gemItemId)
				local tries = 0
				local depositInterval = nil
				local depositGem = function()
					xeno.selfUseItemWithGround(gemItemId, 33269, 31830, 10)
					setTimeout(function()
						local newcount = getTotalItemCount(gemItemId)
						if newcount == gemCount then
							tries = tries + 1
						end
						gemCount = newcount
						if tries > 5 then
							clearTimeout(depositInterval)
							xeno.selfUseItemFromGround(33269, 31830, 10)
							resumeWalker()
						end
					end, DELAY.CONTAINER_USE_ITEM)
				end
				if xeno.getTileUseID(33269, 31830, 10).id ~= 843 then
					xeno.selfUseItemFromGround(33269, 31830, 10)
					setTimeout(function()
						depositInterval = setInterval(depositGem, DELAY.CONTAINER_USE_ITEM)
					end, DELAY.CONTAINER_USE_ITEM)
				else
					depositInterval = setInterval(depositGem, DELAY.CONTAINER_USE_ITEM)
				end
			end
		end
	}

	local function toggleCriticalMode(state)
		if _script.blockCritMode then
			return
		end

		-- We want to turn crit mode on
		if state then
			-- Crit mode is not already on
			if _script.unsafeQueue < 1 then
				xeno.enterCriticalMode()
				_script.unsafeQueue = 1
			-- Crit mode is already on, increment to stay in crit mode
			else
				_script.unsafeQueue = _script.unsafeQueue + 1
			end
		-- We want to turn crit mode off
		else
			_script.unsafeQueue = _script.unsafeQueue - 1
			-- Zero or below, exit crit mode
			if _script.unsafeQueue < 1 then
				xeno.exitCriticalMode()
				_script.unsafeQueue = 0
			end
		end
	end

	local _huntingForDepot = false
	local _snapbacks = 0
	local _lastsnapback = 0
	local _lastposition = xeno.getSelfPosition()
	local _walkerStuckScreenshotInterval = nil

	function onTick()
		if not _script.ready then return end

		toggleCriticalMode(true)

		-- Check and execute timers
		checkTimers()

		-- Update conditions (that need polling)
		_script.stuck = xeno.getWalkerStuck()
		_script.ignoring = xeno.getTargetingIgnoring()

		-- We're stuck, take a screenshot in 10 seconds if we are still stuck then
		if _script.stuck and not _walkerStuckScreenshotInterval then
			_walkerStuckScreenshotInterval = setTimeout(function()
				xeno.setDiagnosticsEnabled(1)
				local pos = xeno.getSelfPosition()
				setTimeout(function()
					xeno.screenshot(('stuck-%d-%d-%d'):format(pos.x, pos.y, pos.z))
					xeno.setDiagnosticsEnabled(0)
				end, 1000)
				_walkerStuckScreenshotInterval = nil
			end, 10 * 1000)

		-- No longer stuck, cancel the screenshot
		elseif not _script.stuck and _walkerStuckScreenshotInterval then
			clearTimeout(_walkerStuckScreenshotInterval)
			_walkerStuckScreenshotInterval = nil
		end

		-- Anti-lure checks
		if _config['Anti Lure'] and _config['Anti Lure']['Amount'] and _config['Anti Lure']['Amount'] > 0 then
			-- Not already running away like a little bitch
			if not _script.ignoring then
				local setIgnore = setTargetingIgnoreEnabled
				local threshold = targetingGetCreatureThreshold(
					_config['Anti Lure']['Creatures'],
					_config['Anti Lure']['Range'],
					_config['Anti Lure']['Amount'],
					false)
				-- Threshold met, goto run path
				if threshold[1] then
					setIgnore(true)
					xeno.attackCreature(0)
					log('Anti-lure triggered. Returning to safety.')
					local closestPath = walkerGetClosestLabel(false, 'run')
					if closestPath then
						xeno.gotoLabel(closestPath.name)
					end
				end
			end
		end

		-- Initiate path clearing process
		if _script.stuck then
			-- Finding a depot, try next one
			if _script.findingDepot then
				-- Not already searching
				if not _huntingForDepot then
					_script.findingDepot = _script.findingDepot + 1
					local label = 'depot|' .. string.lower(_script.town) .. '|' .. _script.findingDepot
					-- Depot exists, try walking to it
					if walkerLabelExists(label) then
						xeno.gotoLabel(label)
						-- Prevent stuck event from firing this same action immediately
						_huntingForDepot = true
						setTimeout(function()
							_huntingForDepot = false
						end, 3000)
					-- No more depots, go to a depotend, most likely to fail
					else
						xeno.gotoLabel('depotend')
					end
				end
			-- Go to return label if set
			elseif _script.stuckReturnLabel then
				xeno.gotoLabel(_script.stuckReturnLabel)
				_script.stuckReturnLabel = nil
				if _script.stuckReturnTimer then
					clearTimeout(_script.stuckReturnTimer)
				end
			end
			throttle(THROTTLE_CLEAR_PATH, clearWalkerPath)
		end

		if _config['HUD'] and _config['HUD']['Enabled'] then
			-- Time related statistics
			local timediff = os.time() - _script.start
			local serverSave = getTimeUntilServerSave() * 3600
			local playerStamina = xeno.getSelfStamina() * 60
			local logoutConfig = _config['Logout']
                        local simpleTime = _config['HUD'] and _config['HUD']['Simple-Time-Format']
			
			hudItemUpdate('General', 'Balance', _script.balance, true)
			hudItemUpdate('General', 'Online Time', formatTime(timediff, simpleTime), true)
 			
 			local timeLimit = logoutConfig['Time-Limit'] or 0
 			local ssLimit = logoutConfig['Server-Save'] or 0
 			local stamLimit = logoutConfig['Stamina'] or 0
 			local remaining = {}

 			if timeLimit > 0 then
 				remaining[#remaining+1] = (timeLimit * 3600) - (os.time() - _script.start)
 			end

 			if serverSave > 0 then
 				remaining[#remaining+1] = serverSave - (ssLimit * 3600)
 			end

 			if stamLimit > 0 then
 				remaining[#remaining+1] = playerStamina - (stamLimit * 3600)
 			end

 			-- Sort remaining times (lowest first)
			table.sort(remaining)

			-- Choose lowest remaining time to display
			local remainingTime = remaining[1]
 			if remainingTime then
				hudItemUpdate('General', 'Time Remaining', formatTime(remainingTime, simpleTime), true)
 			end

			hudItemUpdate('General', 'Server Save', formatTime(serverSave, simpleTime), true)
			hudItemUpdate('General', 'Stamina', formatTime(playerStamina, simpleTime), true)

			local ping = xeno.ping()
			if ping ~= _script.pingLast then
				_script.pingSum = _script.pingSum + ping
				_script.pingEntries = _script.pingEntries + 1
				_script.pingLast = ping
			end

			if _script.pingEntries > 0 then
				hudItemUpdate('General', 'Latency', ping .. ' ms (avg: ' .. math.floor((_script.pingSum / _script.pingEntries) + 0.5) .. ')', true)
			end

			-- Update experience gain
			local gain = xeno.getSelfExperience() - _script.baseExp
			local staminadiff = xeno.getSelfStamina() - _script.startStamina()
			staminadiff = (staminadiff > 0 and staminadiff or 1) * 60
			local useStaminaMeasure = _config['HUD']['Per-Stamina-Measurement']
			local diff = useStaminaMeasure and staminadiff or timediff
			local hourlyexp = tonumber(math.floor(gain / (diff / 3600))) or 0			
			local hourPostfix = useStaminaMeasure and ' xp/sh' or ' xp/h'
			hudItemUpdate('Statistics', 'Experience', formatNumber(gain) .. ' xp', true)
			hudItemUpdate('Statistics', 'Hourly Exp', formatNumber(hourlyexp) .. hourPostfix, true)

			-- Update profit
			local totalLooted = _hud.index['Statistics']['Looted'].value
			local totalWaste = _hud.index['Statistics']['Wasted'].value
			local profit = totalLooted - totalWaste
			local hourlygain = tonumber(math.floor(profit / (timediff / 3600))) or 0
			hudItemUpdate('Statistics', 'Profit', formatNumber(profit) .. ' gp', true)
			hudItemUpdate('Statistics', 'Hourly Profit', formatNumber(hourlygain) .. ' gp/h', true)

			-- Update level stats
			local playerLevel = xeno.getSelfLevel()
			local targetLevel = playerLevel + 1
			local expLeft = ((50/3) * (targetLevel^3) - (100 * targetLevel^2) + ((850/3) * targetLevel) - 200) - xeno.getSelfExperience()
			hudItemUpdate('Statistics', 'Exp to Level', formatNumber(expLeft) .. ' xp', true)
			hudItemUpdate('Statistics', 'Time to Level', hourlyexp > 0 and formatTime(expLeft / (gain / timediff), simpleTime) or formatTime(0, simpleTime), true)

			-- Update state
			hudItemUpdate('Script', 'State', _script.state, true)
			hudItemUpdate('Script', 'Reason', _script.reason, true)
			hudItemUpdate('Script', 'Route', _script.route, true)
			hudItemUpdate('Script', 'Round', tostring(_script.round), true)

			local targetState = 'Disabled'
			if _script.ignoring then
				targetState = 'Ignoring'
			elseif xeno.getXenoBotStatus()["targeting"] then
				targetState = 'Enabled'
			end

			hudItemUpdate('Script', 'Targeter', targetState, true)

			local walkerState = 'Disabled'
			if _script.stuck then
				walkerState = 'Stuck'
			elseif xeno.getWalkerLuring() then
				walkerState = 'Luring'
			elseif xeno.getXenoBotStatus()["walker"] then
				walkerState = 'Enabled'
			end

			hudItemUpdate('Script', 'Walker', walkerState, true)

			-- Loot & Supply Polling
			hudQueryLootChanges()
			hudQuerySupplyChanges()

			hudUpdateDimensions()
			hudUpdatePositions()
		end

		toggleCriticalMode(false)
	end

	function onLabel(name)
		if not _script.ready then return end
		toggleCriticalMode(true)

		-- Path end event
		if name == 'end' then
			delayWalker()
			checkEvents(EVENT_PATH_END, _path)
			_path = {town = nil, route = nil, town = nil, from = nil, to = nil}
			toggleCriticalMode(false)
			return
		end

		-- Depot end event
		if name == 'depotend' then
			delayWalker()
			checkEvents(EVENT_DEPOT_END, 'depotend')
			toggleCriticalMode(false)
			return
		end

		-- Split label
		local label = split(name, '|')
		local group = label and label[1]

		-- Path start, parse
		if group ~= 'travel' and string.find(name, '~') then
			local pathData = split(name, '|')
			local town = pathData[1]
			local route = pathData[2]

			local routeData = split(route, '~')
			local from = routeData[1]
			local to = routeData[2]

			-- Update path
			_path = {town = town, route = route, town = town, from = from, to = to}
			toggleCriticalMode(false)
			return
		end

		-- Reached the end of a route
		if group:sub(1,3) == 'No-' then
			-- False route matches current route
			if group:sub(4):lower() == _script.route:lower() then
				_script.route = '--';
			end
		end

		-- Label events
		local event = LABEL_ACTIONS[group] or _events[EVENT_LABEL][group]
		if event then
			event(unpack(label))
		end
		toggleCriticalMode(false)
	end

	function onErrorMessage(message)
		if not _script.ready then return end
		toggleCriticalMode(true)

		checkEvents(EVENT_ERROR, message)

		--[[
		-- Snap back
		if message == ERROR_NOT_POSSIBLE then
			local time = os.clock() * 1000
			local pos = xeno.getSelfPosition()
			-- It's been longer than 2 seconds, reset snapbacks
			if time - _lastsnapback > 2000 then
				_snapbacks = 0
			-- Moved since the last snapback
			elseif getDistanceBetween(_lastposition, pos) > 0 then
				_snapbacks = 0
			end

			-- Save time and increment snapbacks by one
			_lastsnapback = time
			_lastposition = pos
			_snapbacks = _snapbacks + 1
			-- If snapbacks are at 5 or more, assume an invisible monster is blocking
			if _snapbacks >= 5 then
				-- TODO: free account alternative (wait for "You must learn this spell first" or "You need a premium account" error message)
				if _script.vocation == 'Paladin' then
					cast('exori san')
				elseif _script.vocation == 'Knight' then
					cast('exori')
				else
					cast('exori frigo')
				end
				_snapbacks = 0
			end
		end
		]]
		toggleCriticalMode(false)
	end

	function onLootMessage(message)
		if not _script.ready then return end
		toggleCriticalMode(true)

		-- Check if we need to pump mana
		local manaRestorePercent = _config['Mana Restorer']['Restore-Percent']
		local potionName = _config['Potions']['ManaName']
		local playerPos = xeno.getSelfPosition()
		if manaRestorePercent and manaRestorePercent > 0 and potionName then
			-- Mana below threshold
			local playerMana = math.abs((xeno.getSelfMana() / xeno.getSelfMaxMana()) * 100)
			if playerMana <= manaRestorePercent then
				-- Check for monsters
				local potionid = type(potionName) == 'string' and xeno.getItemIDByName(potionName) or potionName
				local monsterOnScreen = false
				for i = CREATURES_LOW, CREATURES_HIGH do
					local cpos = xeno.getCreaturePosition(i)
					if cpos then
						local distance = getDistanceBetween(playerPos, cpos)
						if playerPos.z == cpos.z and distance <= _config['Mana Restorer']['Range'] then
							if xeno.getCreatureVisible(i) and xeno.getCreatureHealthPercent(i) > 0 and xeno.isCreatureMonster(i) then
								monsterOnScreen = true
								break
							end
						end
					end
				end
				-- No monsters on screen
				if not monsterOnScreen then
					-- Stop walker to pump
					delayWalker()
					walkerRestoreMana(potionid, manaRestorePercent, function()
						-- Mana restored, continue walking
						resumeWalker()
					end)
				end
			end
		end

		-- Check if we need to drop anything
		throttle(THROTTLE_CAP_DROP, walkerCapacityDrop)

		checkEvents(EVENT_LOOT, message)
		toggleCriticalMode(false)
	end

	local _battleMsgRunning = false
	function onBattleMessage(message)
		if _battleMsgRunning then return end
		if not _script.ready then return end

		_battleMsgRunning = true

		toggleCriticalMode(true)

		-- What should we equip/un-equip (slot=itemid)
		local equip = {}
		local unequip = {}

		local playerPos = xeno.getSelfPosition()
		local playerRing = xeno.getRingSlotData().id
		local playerAmulet = xeno.getAmuletSlotData().id
		local playerHealth = math.abs((xeno.getSelfHealth() / xeno.getSelfMaxHealth()) * 100)
		local playerMana = math.abs((xeno.getSelfMana() / xeno.getSelfMaxMana()) * 100)
		local playerTargets = 0

		for i = CREATURES_LOW, CREATURES_HIGH do
			local cpos = xeno.getCreaturePosition(i)
			local distance = getDistanceBetween(playerPos, cpos)
			if playerPos.z == cpos.z and distance <= 7 then
				if xeno.getCreatureVisible(i) and xeno.getCreatureHealthPercent(i) > 0 and xeno.isCreatureMonster(i) then
					playerTargets = playerTargets + 1
				end
			end
		end

		-- Loop through supplies
		-- TODO: this seems like it could be optimized
		for itemid, supply in pairs(_supplies) do
			-- Check rings & amulets
			if supply.group == 'Ring' or supply.group == 'Amulet' and supply.options then
				-- Thresholds
				local triggered = false
				local creatures = supply.options['Creature-Equip'] or 0
				local health = supply.options['Health-Equip'] or 0
				local mana = supply.options['Mana-Equip'] or 0
				local slotItem = supply.group == 'Ring' and playerRing or playerAmulet
				-- We need to equip the ring
				if (creatures > 0 and playerTargets >= creatures) or (health > 0 and playerHealth <= health) or (mana > 0 and playerMana <= mana) then
					-- Only equip if we don't have it on already
					if slotItem ~= itemid and slotItem ~= ITEM_LIST_ACTIVE_RINGS[itemid] then
						equip[supply.group] = itemid
					end
				-- We need to un-equip the ring
				elseif slotItem == itemid or slotItem == ITEM_LIST_ACTIVE_RINGS[itemid] then
					unequip[supply.group] = itemid
				end
			end
		end

		-- Equip all queued supplies
		for group, itemid in pairs(equip) do
			-- Search for the item to equip
			local backpack = _backpacks['Supplies']
			local slot = group == 'Ring' and "ring" or "amulet"
			for spot = 0, xeno.getContainerItemCount(backpack) - 1 do
				local item = xeno.getContainerSpotData(backpack, spot)
				-- Equip item
				if item.id == itemid then
					xeno.containerMoveItemToSlot(backpack, spot, slot, -1)
					_script.equipped[slot] = true;
					-- If this group exists in unequip, remove it, as it will be removed on equip.
					if unequip[group] then
						unequip[group] = nil
					end
					break
				end
			end
		end

		-- Un-equip all queued supplies
		for group, itemid in pairs(unequip) do
			local slot = group == 'Ring' and "ring" or "amulet"
			xeno.slotMoveItemToContainer(slot, _backpacks['Supplies'], 0)
			_script.equipped[slot] = false;
		end

		checkSoftBoots()
		checkEvents(EVENT_BATTLE, message)
		toggleCriticalMode(false)
		_battleMsgRunning = false
	end

	function onChannelSpeak(channel, message)
		-- Do not check if the script is event ready
		-- prompts are needed beforehand
		toggleCriticalMode(true)

		-- First character is slash, command is expected
		if string.sub(message, 1, 1) == '/' then
			-- Clear last console message, so we can repeat ourselves
			_lastConsoleMessage = nil
			local params = split(string.sub(message, 2), ' ')
			local command = params and params[1]
			-- Help command
			if command == 'help' then
				log([[Available commands:
	                /resupply  =  Forces the script to return to town after the current round.
	                /logout  =  Forces the script to return to town and logout after the current round.
	                /config = Opens the config file for this script.
	                /resethud  =  Reset the session start time.
	                /history  =  Opens a channel to monitor received private messages.
	                /debug = Opens a debug channel with more verbose logging.]])
			-- Clear memory
			elseif command == 'freemem' then
				local bytes = freeMemory()
				log('Released ' .. bytes .. ' bytes of allocated RAM.')
			-- Open config
			elseif command == '' then
			-- Open debug channel
			elseif command == 'debug' then
				openDebugChannel()
			-- Open private message history channel
			elseif command == 'history' then
				openPrivateMessageConsole()
			--[[elseif command == 'theme' then
				local themeName = params[2]
				local theme = themeName and THEME[themeName]
				if theme then
					_script.theme = themeName
					log('HUD theme set to ' .. themeName .. '.')
				else
					log('Invalid HUD theme name. [light, dark]')
				end]]
			-- Reset session time
			elseif command == 'resethud' then
				_script.start = os.time()
				log('Reset script start time.')
			elseif command == 'config' then
				local configName = '[' .. getSelfName() .. '] ' .. _script.name
				xeno.showConfigEditor(configName)
			-- Force logout
			elseif command == 'logout' then
				_script.forceLogoutQueued = true
				log('Returning to town to logout after the current round.')
			-- Force resupply
			elseif command == 'resupply' then
				_script.returnQueued = true
				log('Returning to town after the current round.')
			elseif command == 'refill' then
				_script.returnQueued = true
				log('Returning to town after the current round.')
			-- TODO: implement a more modular reload system in RC2
			-- Reload config
			--[[elseif command == 'reload' then
				_config = {}
				_supplies = {}
				loadConfigFile(function()
					setupContainers(function()
						setDynamicSettings(function()
							log('Reloaded the config.')
							-- If reloaded in town, trigger resupply
							if _script.state == 'Resupplying' or _script.state == 'Starting' then
								log('Triggering resupply incase supply counts may have changed.')
								resupply()
							end
						end)
					end)
				end, true)--]]
			end
		-- Not command, handle as usual
		else
			checkEvents(EVENT_COMMAND, message)
		end
		toggleCriticalMode(false)
	end

	function onLogoutEvent()
		if not _script.ready then return end
		_script.forceLogoutQueued = true
		log('Returning to town to logout after the current round. [Xeno Monitor]')
	end

	function onChannelClose(channel)
		if not _script.ready then return end
		toggleCriticalMode(true)

		if _script.channel and tonumber(_script.channel) == tonumber(channel) then
			openConsole()
			-- Backpacks were closed, we just logged in.
			if not xeno.getContainerOpen(0) then
				local inProtectionZone = xeno.getSelfFlag('inpz')
				-- Disable walker, looter, and targeter
				delayWalker()
				xeno.setLooterEnabled(false)
				xeno.setTargetingEnabled(false)
				-- If in PZ, we enable after we setup containers
				resetContainers(function()
					if inProtectionZone then
						resumeWalker()
						xeno.setLooterEnabled(true)
						xeno.setTargetingEnabled(true)
					end
				end)
				-- Otherwise, we wait 10 seconds
				if not inProtectionZone then
					setTimeout(function()
						resumeWalker()
						xeno.setLooterEnabled(true)
						xeno.setTargetingEnabled(true)
					end, 10000)
				end
			end

		elseif _script.historyChannel and tonumber(_script.historyChannel) == tonumber(channel) then
			_script.historyChannel = nil
		end
		toggleCriticalMode(false)
	end

	function onPrivateMessage(name, level, message)
		if not _script.ready then return end
		toggleCriticalMode(true)

		-- TODO: filter spam
		-- TODO: alarm and red text for configurable words
		if _script.historyChannel then
			xeno.luaSendChannelMessage(_script.historyChannel, CHANNEL_ORANGE, name .. ' ['..level..']', message)
		end
		toggleCriticalMode(false)
	end

	function onNpcMessage(name, message)
		if not _script.ready then return end
		toggleCriticalMode(true)
		checkEvents(EVENT_NPC, message, name)
		toggleCriticalMode(false)
	end

	function onContainerChange(index, title, id)
		if not _script.ready then return end
		-- Trigger on the next tick cycle
		-- we need to give the client time to update
		-- on RL Tibia we artificially delay this time for safety reasons
		local delay = xeno.isRealTibia() == 1 and pingDelay(DELAY.CONTAINER_WAIT) or 0
		setTimeout(function()
			toggleCriticalMode(true)
			checkEvents(EVENT_CONTAINER, index, title, id)
			toggleCriticalMode(false)
		end, delay)
	end

	xeno.registerNativeEventListener(TIMER_TICK, 'onTick')
	xeno.registerNativeEventListener(WALKER_SELECTLABEL, 'onLabel')
	xeno.registerNativeEventListener(ERROR_MESSAGE, 'onErrorMessage')
	xeno.registerNativeEventListener(LOOT_MESSAGE, 'onLootMessage')
	xeno.registerNativeEventListener(BATTLE_MESSAGE, 'onBattleMessage')
	xeno.registerNativeEventListener(EVENT_SELF_CHANNELSPEECH, 'onChannelSpeak')
	xeno.registerNativeEventListener(LOGOUT_COMMAND, 'onLogoutEvent')
	xeno.registerNativeEventListener(EVENT_SELF_CHANNELCLOSE, 'onChannelClose')
	xeno.registerNativeEventListener(PRIVATE_MESSAGE, 'onPrivateMessage')
	xeno.registerNativeEventListener(NPC_MESSAGE, 'onNpcMessage')
	xeno.registerNativeEventListener(CONTAINER_OPEN, 'onContainerChange')
end
