Depot = (function()
	
	-- Imports
	local pingDelay = Core.pingDelay
	local setTimeout = Core.setTimeout
	local getWalkableTiles = Core.getWalkableTiles
	local getDirectionTo = Core.getDirectionTo
	local getSelfLookPosition = Core.getSelfLookPosition
	local getPositionFromDirection = Core.getPositionFromDirection
	local formatList = Core.formatList
	local flattenItemCounts = Core.flattenItemCounts
	local warn = Console.warn
	local error = Console.error
	local log = Console.log
	local getLastContainer = Container.getLastContainer
	local getContainerByName = Container.getContainerByName
	local whenContainerUpdates = Container.whenContainerUpdates
	local containerMoveItems = Container.containerMoveItems
	local resetContainers = Container.resetContainers
	local walkerGotoDepot = Walker.walkerGotoDepot
	local walkerStartPath = Walker.walkerStartPath
	local bankWithdrawGold = Npc.bankWithdrawGold
	local shopBuyBackpacks = Npc.shopBuyBackpacks

	local function openLocker(callback)
		-- Immediately callback if Locker is already open
		local locker = getContainerByName(CONT_NAME_LOCKER)
		if locker then
			callback(locker)
			return
		end

		-- Depot position (defaults to look pos)
		local depot = getSelfLookPosition(1)

		-- Detect entry, find depot tile from opposite direction
		local pos = xeno.getSelfPosition()
		local tiles = getWalkableTiles(pos, 1)
		if tiles and tiles[1] then
			local entryPos = tiles[1]
			depot = getPositionFromDirection({x=pos.x, y=pos.y}, getDirectionTo(entryPos, pos), 1)
		end
		-- Browse locker field
		xeno.selfBrowseField(depot.x, depot.y, pos.z)
		-- Wait for Browsefield window
		setTimeout(function()
			-- Browsefield window
			local browsefield = getLastContainer()
			-- Open Locker in same window (first slot)
			xeno.containerUseItem(browsefield, 0, true, true)
			-- Wait for Locker window
			whenContainerUpdates(browsefield+1, function(success)
				if not success then
					openLocker(callback)
					return
				end

				-- Callback with container list index
				locker = getContainerByName(CONT_NAME_LOCKER)
				callback(locker)
			end)
		end, pingDelay(DELAY.BROWSE_FIELD))
	end

	local function openDepot(callback)
		-- Immediately callback if Depot is already open
		local depot = getContainerByName(CONT_NAME_DEPOT)
		if depot then
			callback(depot)
			return
		end

		-- Open Locker first
		openLocker(function(locker)
			-- Unable to open locker
			if not locker then
				callback(false)
				return
			end

			-- Open Depot in same window (first slot)
			xeno.containerUseItem(locker, 0, true, true)
			-- Wait for Depot window
			whenContainerUpdates(locker+1, function(success)
				if not success then
					openDepot(callback)
					return
				end
				
				-- Callback with container list index
				depot = getContainerByName(CONT_NAME_DEPOT)
				callback(depot)
			end)
		end)
	end

	local function transferToDepot(depot, slot, callback)
		containerMoveItems({
			src = _backpacks['Loot'],
			dest = depot,
			slot = slot,
			openwindow = false,
			ignore = {
				-- Flasks
				[283] = true,
				[284] = true,
				[285] = true,
				-- Money
				[3031] = true,
				[3035] = true,
				[3043] = true,
				-- Tools
				[ITEMID.OBSIDIAN_KNIFE] = true,
				[ITEMID.BLESSED_STAKE] = true,
			},
			filter = function(item)
				if slot == DEPOT.SLOT_STACK and xeno.isItemStackable(item.id) then
					return true
				elseif slot == DEPOT.SLOT_NONSTACK and not xeno.isItemStackable(item.id) then
					return true
				end
				return false
			end
		}, function(success, moveCounts)
			local totalCount = 0
			if moveCounts then
				for itemid, count in pairs(moveCounts) do
					-- TODO: add to HUD looted
					totalCount = totalCount + count
				end
			end
			if totalCount > 0 then
				local moveList = formatList(flattenItemCounts(moveCounts), ', ', '')
				local lootType = slot == DEPOT.SLOT_STACK and 'stackables' or 'items'
				log('Deposited ' .. lootType .. ': ' .. moveList .. '.')
			end
			-- Warn player not all their loot was moved
			if not success then
				warn('Some loot was unable to be deposited. Make sure you have enough free slots in your depot backpacks.')
			end
			-- Return
			callback()
		end)
	end

	local function transferFromDepot(depot, neededSupplies, callback)
		-- Detect items we need to withdraw, and backpacks to withdraw to
		local groups = {}
		local groupIndex = {}
		local mainBP = _backpacks['Main']
		local potionsBP = _backpacks['Potions']
		local runesBP = _backpacks['Runes']
		local ammoBP = _backpacks['Ammo']
		local suppliesBP = _backpacks['Supplies']
		local groupTransfers = 0

		local suppliesUsed = false
		for itemid, supply in pairs(_supplies) do
			if supply.group == 'Ring'or supply.group == 'Amulet' or supply.group == 'Supplies' then
				if supply.max > 0 then
					suppliesUsed = true
					break
				end
			end
		end

		for itemid, supply in pairs(neededSupplies) do
			if supply.group == 'Food' then
				if not groups[mainBP] then groups[mainBP] = {} end
				groups[mainBP][itemid] = supply.needed
			elseif supply.group == 'Potions' then
				if not groups[potionsBP] then groups[potionsBP] = {} end
				groups[potionsBP][itemid] = supply.needed
			elseif supply.group == 'Runes' then
				if not groups[runesBP] then groups[runesBP] = {} end
				groups[runesBP][itemid] = supply.needed
			elseif supply.group == 'Ammo' then
				if not groups[ammoBP] then groups[ammoBP] = {} end
				groups[ammoBP][itemid] = supply.needed
			elseif supply.group == 'Ring' or supply.group == 'Amulet' or supply.group == 'Supplies' then
				if not groups[suppliesBP] then groups[suppliesBP] = {} end
				groups[suppliesBP][itemid] = supply.needed
			end
		end

		-- Turn associate list into something we can iterate easily
		for bp, _ in pairs(groups) do
			groupIndex[#groupIndex+1] = bp
		end

		-- Move each group
		local function transferGroup(index)
			-- Lookup group backpack
			local backpack = groupIndex[index]
			-- No more groups, finished
			if not backpack then
				if not suppliesUsed and groupTransfers == 0 then
					_script.disableWithdraw = true
					log('No supplies found in depot (3rd slot). Disabling future withdrawal attempts.')
				end
				return callback()
			end
			-- Look group items
			local items = groups[backpack]
			-- Move group
			containerMoveItems({
				src = depot,
				dest = backpack,
				openwindow = false,
				items = items,
			}, function(success, moveCounts)
				-- If we didn't withdraw anything, disable withdrawing supplies in the future
				local totalCount = 0
				if moveCounts then
					for itemid, count in pairs(moveCounts) do
						-- TODO: add to HUD supplies
						totalCount = totalCount + count
					end
				end
				if totalCount > 0 then
					local moveList = formatList(flattenItemCounts(moveCounts), ', ', '')
					log('Withdrew ' .. moveList .. '.')
					groupTransfers = groupTransfers + 1
				end
				-- Warn player not all their loot was moved
				if not success then
					warn('Unable to withdraw all supplies. Make sure your character has slots and capacity.')
				end
				-- Next group, after short delay
				setTimeout(function()
					transferGroup(index+1)
				end, pingDelay(DELAY.CONTAINER_MOVE_ITEM))
			end)
		end

		-- Open supply slot in depot
		xeno.containerUseItem(depot, DEPOT.SLOT_SUPPLY, true, true)
		setTimeout(function()
			-- Start transfer
			transferGroup(1)
		end, pingDelay(DELAY.CONTAINER_MOVE_ITEM))
	end

	local function depositBackpacks(locker, count, callback)
		local slots = {}
		-- Find the slots to move from
		for spot = 0, xeno.getContainerItemCount(0) - 1 do
			local item = xeno.getContainerSpotData(0, spot)
			if xeno.isItemContainer(item.id) then
				local newIndex = #slots+1
				slots[newIndex] = spot
				if newIndex >= count then
					break
				end
			end
		end


		-- Sort greatest to least so we don't shift source slots
		table.sort(slots, function(a,b) return a > b end)

		local function moveBp(index)
			local fromSlot = slots[index]
			-- No more containers to deposit, return
			if not fromSlot then
				callback()
				return
			end

			-- Move backpack to depot slot in locker
			xeno.containerMoveItemToContainer(0, fromSlot, locker, 0, 1)

			-- Delay and continue
			setTimeout(function()
				moveBp(index+1)
			end, pingDelay(DELAY.CONTAINER_MOVE_ITEM))
		end

		moveBp(1)
	end

	local function depotTransfer(depot, needDeposit, neededSupplies, callback)

		-- Minimize depot container
		xeno.minimizeContainer(depot)

		-- Set depot state
		_script.depotOpen = true

		-- Check slots
		local missingBps = 0
		for spot = 0, 1 do
			local item = xeno.getContainerSpotData(depot, spot)
			if not item or not xeno.isItemContainer(item.id) then
				missingBps = missingBps + 1
			end
		end

		-- Stackable and nonstackables required
		if missingBps > 0 then
			warn('Missing loot and/or stackable loot container in depot. Walking to the equipment shop.')
			local bpPrice = missingBps * PRICE.BACKPACK
			-- Walk to bank
			walkerStartPath(_script.town, 'depot', 'bank', function()
				-- Withdraw gold
				bankWithdrawGold(bpPrice, function()
					-- Walk to tool NPC
					walkerStartPath(_script.town, 'bank', 'tools', function()
						-- Buy backpacks
						shopBuyBackpacks(missingBps, function()
							-- Walk back to depot
							walkerStartPath(_script.town, 'tools', 'depot', function()
								walkerGotoDepot(function()
									openLocker(function(locker)
										depositBackpacks(locker, missingBps, function()
											-- Recurse this insane callstack
											openDepot(function(newDepot)
												depotTransfer(newDepot, needDeposit, neededSupplies, callback)
											end)
										end)
									end)
								end)
							end)
						end)
					end)
				end)
			end)
			return
		end

		-- We need to deposit
		if needDeposit then
			-- Deposit stackables
			transferToDepot(depot, DEPOT.SLOT_STACK, function()
				-- Delay
				setTimeout(function()
					-- Deposit non-stackables
					transferToDepot(depot, DEPOT.SLOT_NONSTACK, function()
						-- We need to withdraw, delay and withdraw
						if neededSupplies then
							setTimeout(function()
								-- Withdraw supplies
								transferFromDepot(depot, neededSupplies, function()
									-- Set depot state
									_script.depotOpen = false
									callback()
								end)
							end, DELAY.CONTAINER_MOVE_ITEM)
						-- Nothing left
						else
							-- Set depot state
							_script.depotOpen = false
							callback()
						end
					end)
				end, DELAY.CONTAINER_MOVE_ITEM)
			end)
		-- Only withdraw
		elseif neededSupplies then
			-- Withdraw supplies
			transferFromDepot(depot, neededSupplies, function()
				-- Set depot state
				_script.depotOpen = false
				callback()
			end)
		-- Nothing?
		else
			-- Set depot state
			_script.depotOpen = false
			callback()
		end
	end

	local function startDepotTransfer(needDeposit, neededSupplies, callback)
		-- Walk to nearest depot
		walkerGotoDepot(function()
			resetContainers(function()
				-- Open Depot
				openDepot(function(depot)
					-- Depot not opened, keep looking
					if not depot then
						startDepotTransfer(needDeposit, neededSupplies, callback)
						return
					end
					depotTransfer(depot, needDeposit, neededSupplies, callback)
				end)
			end)
		end)
	end

	-- Export global functions
	return {
		startDepotTransfer = startDepotTransfer
	}
end)()
