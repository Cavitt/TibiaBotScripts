Container = (function()
	
	-- Imports
	local pingDelay = Core.pingDelay
	local clearTimeout = Core.clearTimeout
	local clearWhen = Core.clearWhen
	local setTimeout = Core.setTimeout
	local setInterval = Core.setInterval
	local when = Core.when
	local formatList = Core.formatList
	local debug = Core.debug
	local log = Console.log
	local info = Console.info
	local prompt = Console.prompt

	local function getLastContainer()
		local last = 0
		for i = 0, 16 do
			if xeno.getContainerOpen(i) then
				last = i
			end
		end
		return last
	end

	local function getContainerByName(name)
		for i = 0, 16 do
			if xeno.getContainerName(i) == name and xeno.getContainerOpen(i) then
				return i
			end
		end
		return false
	end

	local function compareContainers(a, b)
		-- Different item count, return false
		local itemcount = xeno.getContainerItemCount(a)
		local compcount = xeno.getContainerItemCount(b)
		if itemcount ~= compcount then
			return false
		end
		-- Different name, return false
		if xeno.getContainerName(a) ~= xeno.getContainerName(b) then
			return false
		end
		-- Different slot data, return false
		for spot = 0, itemcount do
			local item = xeno.getContainerSpotData(a, spot)
			local compitem = xeno.getContainerSpotData(b, spot)
			if item.id ~= compitem.id or item.count ~= compitem.count then
				return false
			end
		end
		-- Containers are similar (shallow comparison)
		return true
	end

	local function whenContainerUpdates(container, callback)
		local timeout = nil
		local success = nil
		timeout = setTimeout(function()
			clearWhen(EVENT_CONTAINER, success)
			callback(false)
		end, DELAY.CONTAINER_TIMEOUT)
		success = when(EVENT_CONTAINER, tostring(container), function(index, id, name)
			clearTimeout(timeout)
			callback(true)
		end)
	end

	local function resetContainerDepths(source, destination, sDepth, dDepth, callback)
		-- Go back in source container
		if sDepth > 0 then
			xeno.containerBack(source)
			whenContainerUpdates(source, function()
				resetContainerDepths(source, destination, sDepth-1, dDepth, callback)
			end)

		-- Go back in destination container
		elseif dDepth > 0 then
			xeno.containerBack(destination)
			whenContainerUpdates(destination, function()
				resetContainerDepths(source, destination, sDepth, dDepth-1, callback)
			end)
		-- Return
		elseif callback then
			callback()
		end
	end

	local function containerMoveItems(options, callback)
		local fromContainer = options.src
		local toContainer = options.dest
		local toSlot = options.slot

		local whiteList = options.items
		local blackList = options.ignore
		local itemFilter = options.filter

		local disableSourceCascade = options.disableSourceCascade or fromContainer == _backpacks['Main']
		local openWindow = options.openwindow -- open first destination cascade in new window

		local spotOffset = 0
		local sourceDepth = 0
		local destDepth = 0

		local isMovingPaused = false

		local moveItem = nil
		local watchContainerFullError = nil
		local onContainerFull = nil
		local moveInterval = nil
		local fullEvent = nil

		local moveCounts = {}
		local moveHits = {}
		local lastMove = {
			itemid = nil,
			count = nil
		}

		if not fromContainer or not toContainer then
			callback()
			return
		end

		-- Target move slot is last slot in the container by default
		if toSlot == nil then
			toSlot = xeno.getContainerItemCapacity(toContainer) - 1
		end

		-- Registers the error watcher
		watchContainerFullError = function()
			debug('containerMoveItems: container full event')
			return when(EVENT_ERROR, ERROR_CONTAINER_FULL, onContainerFull)
		end

		local item = nil

		-- Called to trigger a single item move
		moveItem = function(self)

			-- Moving is paused, stop recurse
			if isMovingPaused then
				debug('containerMoveItems: moving paused')
				return
			end

			-- Remaining items
			local itemCount = xeno.getContainerItemCount(fromContainer)

			-- No items and cascade OR skipped all filled spots, stop entirely
			if itemCount == 0 or spotOffset >= itemCount then
				-- Kill monitoring container full errors
				if fullEvent then
					clearWhen(EVENT_ERROR, fullEvent)
				end
				-- Kill move event
				if moveInterval then
					clearTimeout(moveInterval)
				end
				-- Reset depths and finish
				resetContainerDepths(fromContainer, toContainer, sourceDepth, destDepth, function()
					debug('containerMoveItems: resetContainerDepths -> callback')
					callback(true, moveHits)
				end)
				return
			end

			-- Das item
			item = xeno.getContainerSpotData(fromContainer, spotOffset)

			-- Amount of this stack to move (defaults to entire stack)
			local moveStackCount = item.count

			-- Cascade backpack, last slot of backpack
			if xeno.isItemContainer(item.id) and (spotOffset + 1 >= itemCount) then 
				-- Cascade source enabled, open it, update source depth, reset spot offset
				if not disableSourceCascade then
					sourceDepth = sourceDepth + 1
					spotOffset = 0
					xeno.containerUseItem(fromContainer, itemCount-1, true, true)
					debug('containerMoveItems: cascade [last slot]')
				else
					spotOffset = spotOffset + 1
					-- Skip to next item immediately
					debug('containerMoveItems: moveItem() [last slot]')
					moveItem(self)
				end
				return
			end

			-- Item is in blacklist, try next spot
			if blackList and blackList[item.id] then
				spotOffset = spotOffset + 1
				-- Skip to next item immediately
				debug('containerMoveItems: moveItem() [blacklist]')
				moveItem(self)
				return
			end

			-- Item not in filter list, try next spot
			if whiteList and not whiteList[item.id] then
				spotOffset = spotOffset + 1
				-- Skip to next item immediately
				debug('containerMoveItems: moveItem() [filter]')
				moveItem(self)
				return
			end

			-- Item filter is set, run function to test validity
			if itemFilter and not itemFilter(item) then
				spotOffset = spotOffset + 1
				-- Skip to next item immediately
				debug('containerMoveItems: moveItem() [filter func]')
				moveItem(self)
				return
			end

			-- Item list, and entry has a number (count) value
			if whiteList and whiteList[item.id] and type(whiteList[item.id]) == 'number' then
				-- Check if we've moved any of this item yet
				if not moveCounts[item.id] then
					moveCounts[item.id] = whiteList[item.id]
				end

				-- We don't need anymore of this item, skip
				if moveCounts[item.id] <= 0 then
					spotOffset = spotOffset + 1
					-- Skip to next item immediately
					debug('containerMoveItems: moveItem() [no need]')
					moveItem(self)
					return
				end

				-- Now we know how much to move, don't go over the needed (smallest value)
				moveStackCount = math.min(item.count, moveCounts[item.id])

				-- Decrease needed (we'll reverse this if we fail)
				moveCounts[item.id] = moveCounts[item.id] - moveStackCount
			end

			-- Track move counts by itemid
			local itemMoves = moveHits[item.id]
			if not itemMoves then itemMoves = 0 end
			moveHits[item.id] = itemMoves + moveStackCount

			-- Track last move
			lastMove.itemid = item.id
			lastMove.count = moveStackCount
			
			-- Move item to destination
			debug(('containerMoveItems: move item %d, %d => %d, %d x%d'):format(fromContainer, spotOffset, toContainer, toSlot, moveStackCount))
			xeno.containerMoveItemToContainer(fromContainer, spotOffset, toContainer, toSlot, moveStackCount)
		end

		-- Triggered when the destination fills up
		onContainerFull = function()
			-- Set flag so we stop moving items
			-- No need to kill fullEvent, it dies after one use
			isMovingPaused = true

			-- Check if we need to reverse a move
			if item and lastMove.itemid and lastMove.count > -1 then
				-- Increase move counts
				if whiteList and moveCounts[lastMove.itemid] then
					moveCounts[item.id] = moveCounts[item.id] + lastMove.count
				end
				-- Decrease total item moves
				local itemMoves = moveHits[item.id]
				if not itemMoves then itemMoves = 0 end
				moveHits[item.id] = math.max(0, itemMoves - lastMove.count)
			end

			setTimeout(function()
				-- We weren't depositing into a backpack, no cascade available
				if not xeno.isItemContainer(xeno.getContainerSpotData(toContainer, toSlot).id) then
					-- Kill move event
					if moveInterval then
						clearTimeout(moveInterval)
					end
					-- Reset depths and finish
					debug('containerMoveItems: reset depths [no bp, no cascade]')
					resetContainerDepths(fromContainer, toContainer, sourceDepth, destDepth, function()
						debug('containerMoveItems: callback() [no bp, no cascade]')
						callback(false, moveHits)
					end)
					return
				end
				-- Open destination container
				debug('containerMoveItems: open destination')
				xeno.containerUseItem(toContainer, toSlot, not openWindow, true)

				local targetContainer = openWindow and getLastContainer() or toContainer
				whenContainerUpdates(targetContainer, function()
					-- Update toContainer index if we opened in a new window
					if openWindow then
						toContainer = targetContainer
						debug('containerMoveItems: new window = ' .. toContainer)
						-- Reset destination depth, since we're in a new destination
						destDepth = 0
					end

					-- Check if last item is a container
					local lastSlot = xeno.getContainerItemCount(toContainer) - 1
					local cascadeID = xeno.getContainerSpotData(toContainer, lastSlot).id
					if xeno.isItemContainer(cascadeID) then
						-- Found cascade backpack, update slot, update destination depth
						openWindow = false
						destDepth = destDepth + 1
						toSlot = lastSlot

						-- Start moving again
						isMovingPaused = false

						-- Register full event again
						fullEvent = watchContainerFullError()
						debug('containerMoveItems: cascade depth = ' .. destDepth)
						return
					end
					-- No cascade backpack, stop entirely
					-- Reset depths and finish
					debug('containerMoveItems: reset depths [cascaded]')
					resetContainerDepths(fromContainer, toContainer, sourceDepth, destDepth, function()
						debug('containerMoveItems: callback() [cascaded]')
						callback(false, moveHits)
						-- Kill move event
						if moveInterval then
							clearTimeout(moveInterval)
						end
					end)		
					return
				end)
			end, DELAY.CONTAINER_MOVE_ITEM)
		end

		-- Begin moving
		moveInterval = setInterval(moveItem, DELAY.CONTAINER_MOVE_ITEM)

		-- Start watching for container full errors
		fullEvent = watchContainerFullError()
	end

	local function moveItems(containers, options, callback, dirty)
		local source = table.remove(containers)
		containerMoveItems({
			src = source,
			dest = options.dest,
			items = options.items,
			disableSourceCascade = options.disableSourceCascade,
			openwindow = options.openwindow
		}, function(cascaded, moveCounts)
			-- Count moved items
			local totalCount = 0
			if moveCounts then
				for itemid, count in pairs(moveCounts) do
					totalCount = totalCount + count
				end
			end
			-- Moved items, flag entire move as "dirty"
			-- means cleanContainer will reloop
			-- we do this incase we freed up any slots
			if totalCount > 0 then
				dirty = true
			end

			-- Successfully moved items,
			-- Last container, finish
			if #containers == 0 then
				callback(dirty)
			-- Recurse
			else
				moveItems(containers, options, callback, dirty)
			end
		end)
	end

	local function cleanContainers(destination, itemList, callback, shallow)
		-- Check all backpacks except for destination
		-- for items in the list and move them to the destination
		local containers = {}
		for i = 0, 15 do
			if i ~= destination and xeno.getContainerOpen(i) then
				containers[#containers+1] = i
			end
		end
		moveItems(containers, {
			dest = destination,
			slot = 0,
			items = itemList,
			-- Do not dig into the main backpack
			disableSourceCascade = shallow,
			openwindow = false
		}, function(dirty)
			-- Something was moved
			if dirty then
				cleanContainers(destination, itemList, callback, shallow)
			elseif callback then
				callback()
			end
		end)
	end

	local function openMainBackpack(callback, tries)
		-- Retry attempts
		tries = tries or 3

		-- Open
		local opened = xeno.slotUseItem(3)

		-- Wait for Main Backpack
		whenContainerUpdates(0, function()
			-- Success
			if opened > 0 then
				if _config['General']['Minimize-Backpacks'] then
					xeno.minimizeContainer(0)
				end
				callback(true)
			-- Fail, out of retries
			elseif tries <= 0 then
				callback(false)
			-- Fail, recurse
			else
				tries = tries - 1
				openMainBackpack(callback, tries)
			end
		end)
	end

	local function resetContainers(callback)
		-- Close all containers
		for i = 0, 16 do
			xeno.closeContainer(i)
		end

		local minimizeBackpacks = _config['General']['Minimize-Backpacks']
		openMainBackpack(function()
			local backpacks = {}
			local function openChild(index)
				local spot = backpacks[index]
				local newcontainer = getLastContainer() + 1
				-- Open child backpack
				xeno.containerUseItem(0, spot, false, true)

				-- Wait for child to open
				whenContainerUpdates(newcontainer, function()
					-- Minimize all containers
					if minimizeBackpacks then
						for i = 1, 16 do
							if xeno.getContainerOpen(i) then
								xeno.minimizeContainer(i)
							end
						end
					end
					-- Open next child
					if #backpacks > index then
						openChild(index+1)
					-- Complete, main callback
					else
						callback()
					end
				end)
			end

			-- Loop through all items, add containers to list
			local itemcount = xeno.getContainerItemCount(0)
			for spot = 0, itemcount - 1 do
				local item = xeno.getContainerSpotData(0, spot)
				if xeno.isItemContainer(item.id) then
					backpacks[#backpacks+1] = spot
				end
			end

			-- Call openChild for every backpack
			openChild(1)
		end)
	end

	local function setupContainers(callback)
		local needGoldContainer = false
		local needPotionContainer = false
		local needRuneContainer = false
		local needAmmoContainer = false
		local needSuppliesContainer = false

		-- Pause the bot
		xeno.attackCreature(0)
		xeno.followCreature(0)
		xeno.setWalkerEnabled(false)
		xeno.setLooterEnabled(false)
		xeno.setTargetingEnabled(false)

		log('Setting up your backpacks, please wait...')
		local function finishSetup()
			log('Your backpacks have been setup. Do NOT rearrange containers!')

			-- Resume the bot
			xeno.setWalkerEnabled(true)
			xeno.setLooterEnabled(true)
			xeno.setTargetingEnabled(true)

			callback()
		end

		-- Move items in main backpack to the correct backpacks
		local function organizeMainBackpack()
			local destinations = {}
			local itemLists = {}

			-- Move gold to gold backpack
			local goldBackpack = _backpacks['Gold']
			destinations[#destinations+1] = {'Gold', goldBackpack}
			itemLists[goldBackpack] = {[3031] = true}

			-- Move platinum and crystal coins to main
			local mainBackpack = _backpacks['Main']
			destinations[#destinations+1] = {'Main', mainBackpack}
			itemLists[mainBackpack] = {
				[3035] = true,
				[3043] = true
			}

			-- Create itemid list for each supply group
			for itemid, supply in pairs(_supplies) do
				-- Amulets and Rings always go in the Supplies backpack
				local name = supply.group
				if name == 'Amulet' or name == 'Ring' then
					name = 'Supplies'
				end
				-- Send to Main backpack list if it matches the index
				local backpack = _backpacks[name]
				if backpack then
					if backpack == _backpacks['Main'] then
						name = 'Main'
					end
					-- Init table if it doesn't exist
					if not itemLists[backpack] then
						itemLists[backpack] = {}
						-- Add backpack to index for easy iteration
						destinations[#destinations+1] = {name, backpack}
					end
					-- Add supply item to the list
					itemLists[backpack][itemid] = true
				end
			end

			local function moveNextItems(index)
				local backpack = destinations[index]

				-- Check if destination exists (no items to move)
				if not backpack then
					finishSetup()
					return
				end

				local backpackName = backpack[1]
				local destination = backpack[2]

				-- Get itemid list for this backpack
				local itemList = itemLists[destination]

				-- Clean all backpacks and move valid items to this backpack
				cleanContainers(destination, itemList, function(success)
					-- Proceed to next destination
					moveNextItems(index+1)
				end)
			end

			-- Move items to proper backpack, then finish
			if #destinations > 0 then
				moveNextItems(1)
			-- None to move, finish up
			else
				finishSetup()
			end
		end

		-- Assign backpacks
		local function assignBackpacks()
			-- Setup containers (start at index 2 since Main = 0, Loot = 1)
			local index = 2
			local list = {}

			list[#list+1] = '#1  -  Main backpack'
			list[#list+1] = '#2  -  Loot backpack'

			local containerStatuses = {
				{'Gold', needGoldContainer},
				{'Potions', needPotionContainer},
				{'Runes', needRuneContainer},
				{'Ammo', needAmmoContainer},
				{'Supplies', needSuppliesContainer}
			}

			for i = 1, #containerStatuses do
				local status = containerStatuses[i]
				if status and status[2] then
					_backpacks[status[1]] = index
					list[#list+1] = ('#%d  -  %s backpack'):format(index+1, status[1])
					index = index + 1
				else
					_backpacks[status[1]] = 0
				end
			end

			info('Your backpack setup:\n' .. formatList(list, '\n', '    '));

			if _config['General']['Organize-Backpacks'] then
				log('Organizing your backpacks, please wait...')
				organizeMainBackpack()
			else
				finishSetup()
			end
		end

		-- Open main bp and children
		resetContainers(function()
			-- Count how many are open (excluding main bp)
			-- Determine how many we need
			-- If we have enough, continue
			-- If not, prompt user, wait for response, recheck

			-- Loop through supplies, flag each "type" of container we will need
			local neededContainers = 0
			local runeCount = 0
			local potionCount = 0
			local ammoCount = 0
			local supplyCount = 0

			if _config['Loot']['Loot-Gold'] then
			   neededContainers = neededContainers + 1
			   needGoldContainer = true 
			end

			for supplyId, supply in pairs(_supplies) do
				if supply.group == 'Potions' and not needPotionContainer then
					potionCount = potionCount + supply.max
					if potionCount > 100 then
						neededContainers = neededContainers + 1
						needPotionContainer = true
					end
				elseif supply.group == 'Runes' and not needRuneContainer then
					runeCount = runeCount + supply.max
					if runeCount > 100 then
						neededContainers = neededContainers + 1
						needRuneContainer = true
					end
				elseif supply.group == 'Ammo' and not needAmmoContainer then
					ammoCount = ammoCount + supply.max
					if ammoCount > 100 then
						neededContainers = neededContainers + 1
						needAmmoContainer = true
					end
				elseif (supply.group == 'Ring' or supply.group == 'Amulet') and not needSuppliesContainer then
					supplyCount = supplyCount + supply.max
					if supplyCount > 5 then
						neededContainers = neededContainers + 1
						needSuppliesContainer = true
					end
				end
			end

			-- Backpacks inside main bp we can use (ignore mainbp and loot bp)
			local availableContainers = getLastContainer() - 1

			-- Make sure we have enough, if not prompt, then retry
			if availableContainers < neededContainers then
				-- prompt user, then assignBackpacks
				local missingCount = (neededContainers - availableContainers)
				local singularMsg = 'Not enough backpacks. Add one more backpack to your main backpack. Type "retry" to continue.'
				local pluralMsg = 'Not enough backpacks. Add ' .. missingCount .. ' more backpacks to your main backpack. Type "retry" to continue.'
				local message = missingCount > 1 and pluralMsg or singularMsg
				local function promptBackpacks()
					prompt(message, function(response)
						if string.find(string.lower(response), 'retry') then
							setupContainers(callback)
						else
							promptBackpacks()
						end
					end)
				end
				promptBackpacks()
				return
			end

			-- All is well, start setup
			assignBackpacks()
		end)
	end

	local function getContainerItemCounts(index, callback, deepSearch, startLevel)
		local items = {}
		local function countLevel(level)
			-- Iterate through container spots
			local lastSlot = xeno.getContainerItemCount(index) - 1
			for spot = 0, lastSlot do
				local item = xeno.getContainerSpotData(index, spot)
				-- Do not count the cascade backpack 
				if spot ~= lastSlot or not xeno.isItemContainer(item.id) then
					-- Create table and entries on-demand
					if not items[item.id] then
						items[item.id] = 0
					end
					-- Increment count
					items[item.id] = items[item.id] + math.max(item.count, 1)
				end
			end

			-- Only counting the current container level OR reached top level
			if not deepSearch or level <= 1 then
				if callback then
					callback(items)
				end
				return items
			-- Not done, keep counting backwards
			else
				-- Navigate back a level
				local ret = xeno.containerBack(index)
				whenContainerUpdates(index, function()
					countLevel(level-1)
				end)
			end
			return nil
		end
		local function gotoBottom(depth)
			local lastSlot = xeno.getContainerItemCount(index) - 1
			local cascadeID = xeno.getContainerSpotData(index, lastSlot).id
			-- Another cascade, go deeper
			if xeno.isItemContainer(cascadeID) then
				xeno.containerUseItem(index, lastSlot, true, true)
				whenContainerUpdates(index, function()
					gotoBottom(depth + 1)
				end)
				return
			end
			-- At the last level, start counting items
			countLevel(depth)
		end
		-- Deep count specified, go to end of container and count backwards
		if deepSearch then
			gotoBottom(startLevel or 1)
		-- Shallow count, function can be used synchronously
		else
			return countLevel(1)
		end
	end

	local function getTotalItemCount(itemIdList, ignoreEquipment)
		local totals = {}
		local numberReturn = false

		-- Wrap single itemid in an index table
		if type(itemIdList) ~= 'table' then
			numberReturn = itemIdList
			itemIdList = {[itemIdList] = true}
		end

		-- Count equipment
		if not ignoreEquipment then
			local slots = {
				xeno.getHeadSlotData,
				xeno.getArmorSlotData,
				xeno.getLegsSlotData,
				xeno.getFeetSlotData,
				xeno.getAmuletSlotData,
				xeno.getWeaponSlotData,
				xeno.getRingSlotData,
				xeno.getShieldSlotData,
				xeno.getAmmoSlotData
			}
			for i = 1, #slots do
				local slot = slots[i]()
				if slot and slot.id then
					-- Counting this item
					if itemIdList[slot.id] then
						local itemTotal = totals[slot.id]
						local itemcount = math.max(slot.count, 1)
						if not itemTotal then
							totals[slot.id] = itemcount
						else
							itemTotal = itemTotal + itemcount
						end
					end
				end
			end
		end

		-- Iterate all possible containers
		for i = 0, 16 do
			-- No more containers, stop searching
			if not xeno.getContainerOpen(i) then
				break
			end
			-- Count this container
			local counts = getContainerItemCounts(i)
			for itemid, itemcount in pairs(counts) do
				-- Counting this item
				if itemIdList[itemid] then
					local itemTotal = totals[itemid]
					if not itemTotal then
						totals[itemid] = itemcount
					else
						totals[itemid] = itemTotal + itemcount
					end
				end
			end
		end

		-- Returns number if single number was provided
		-- otherwise returns a pairs table with itemid = count
		if numberReturn then
			totals = totals[numberReturn]
		end
		return totals or 0
	end

	local function getMoney()
		local counts = getTotalItemCount(ITEM_LIST_MONEY)

		local gold = counts[3031] or 0
		local plat = counts[3035] or 0
		local crystal = counts[3043] or 0

		local total = gold
		total = total + (plat * 100)
		total = total + (crystal * 10000)

		return total
	end

	local function getFlasks()
		local counts = getTotalItemCount(ITEM_LIST_FLASKS)

		local small = counts[285] or 0
		local med = counts[284] or 0
		local large = counts[283] or 0

		return small + med + large
	end

	local function getFlaskWeight()
		local counts = getTotalItemCount(ITEM_LIST_FLASKS)

		local small = counts[285] or 0
		local med = counts[284] or 0
		local large = counts[283] or 0

		return (small * xeno.getItemWeight(285))
			+ (med * xeno.getItemWeight(284))
			+ (large * xeno.getItemWeight(283))
	end

	local function unrustLoot(callback)
		-- Make sure a corpse is not currently open
		-- Loop through each slot in the loot container
		-- If loot is a "rusty" item, use oil on it.
		-- Wait x delay and look at the same slot.
		-- If loot is shitty, toss it out. (offset slot in loop)
		-- If loot is good, continue (add to supplies)
		-- Remove rusty armor from supplies (HUD)
		-- Add oil as supply waste (HUD)
	end

	-- Export global functions
	return {
		getLastContainer = getLastContainer,
		getContainerByName = getContainerByName,
		whenContainerUpdates = whenContainerUpdates,
		containerMoveItems = containerMoveItems,
		setupContainers = setupContainers,
		resetContainers = resetContainers,
		getContainerItemCounts = getContainerItemCounts,
		cleanContainers = cleanContainers,
		getTotalItemCount = getTotalItemCount,
		getMoney = getMoney,
		getFlasks = getFlasks,
		getFlaskWeight = getFlaskWeight
	}
end)()
