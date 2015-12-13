Supply = (function()
	
	-- Imports
	local formatList = Core.formatList
	local setInterval = Core.setInterval
	local clearTimeout = Core.clearTimeout
	local delayWalker = Core.delayWalker
	local resumeWalker = Core.resumeWalker
	local getDistanceBetween = Core.getDistanceBetween
	local log = Console.log
	local warn = Console.warn
	local prompt = Console.prompt
	local error = Console.error
	local getContainerItemCounts = Container.getContainerItemCounts
	local cleanContainers = Container.cleanContainers
	local getTotalItemCount = Container.getTotalItemCount
	local getMoney = Container.getMoney
	local getFlaskWeight = Container.getFlaskWeight
	local hudItemUpdate = Hud.hudItemUpdate
	local bankDepositGold = Npc.bankDepositGold
	local bankGetBalance = Npc.bankGetBalance
	local bankWithdrawGold = Npc.bankWithdrawGold
	local shopSellLoot = Npc.shopSellLoot
	local shopRefillSoftboots = Npc.shopRefillSoftboots
	local shopBuySupplies = Npc.shopBuySupplies
	local walkerLabelExists = Walker.walkerLabelExists
	local walkerStartPath = Walker.walkerStartPath
	local walkerGetPosAfterLabel = Walker.walkerGetPosAfterLabel
	local walkerGotoLocation = Walker.walkerGotoLocation
	local startDepotTransfer = Depot.startDepotTransfer
	local checkChainRules = Ini.checkChainRules

	local function updateSupplyCount(supplyTypes, itemListFilter)
		local function checkBackpack(group)
			-- Count the backpack assigned to this supply group
			-- Some supplies share the same backpack (Amulets & Rings)
			local backpackName = group
			if group == 'Amulet' or group == 'Ring' then
				backpackName = 'Supplies'
			end

			-- If dedicated backpack doesn't exist, check main backpack
			-- Supplies actually use the Main container, not Supplies
			local backpack = nil
			if group ~= 'Supplies' and _backpacks[backpackName] then
				backpack = _backpacks[backpackName]
			else
				backpack = _backpacks['Main']
			end

			local sessionCount = {}

			-- Count slots
			local slotItems = {}

			slotItems[1] = xeno.getAmmoSlotData()
			slotItems[2] = xeno.getHeadSlotData()
			slotItems[3] = xeno.getArmorSlotData()
			slotItems[4] = xeno.getLegsSlotData()
			slotItems[5] = xeno.getFeetSlotData()
			slotItems[6] = xeno.getAmuletSlotData()
			slotItems[7] = xeno.getWeaponSlotData()
			slotItems[8] = xeno.getRingSlotData()
			slotItems[9] = xeno.getShieldSlotData()

			-- Count supplies in slots
			for i = 1, 9 do
				local slot = slotItems[i]
				if slot and slot.id > 0 then
					if not itemListFilter or itemListFilter[slot.id] then
						local supply = _supplies[slot.id]
						-- This item is a supply and the correct group
						if supply and supply.group == group then
							-- Create supply count session if needed
							if not sessionCount[slot.id] then
								sessionCount[slot.id] = 0
							end

							-- Update supply count
							local count = sessionCount[slot.id] + math.max(slot.count, 1)
							sessionCount[slot.id] = count
							_supplies[slot.id].count = count
						end
					end
				end
			end

			-- Count supplies in the backpack determined above
			for spot = 0, xeno.getContainerItemCount(backpack) - 1 do
				local item = xeno.getContainerSpotData(backpack, spot)
				if not itemListFilter or itemListFilter[item.id] then
					local supply = _supplies[item.id]
					-- This item is a supply and the correct group
					if supply and supply.group == group then
						-- Create supply count session if needed
						if not sessionCount[item.id] then
							sessionCount[item.id] = 0
						end

						-- Update supply count
						local count = sessionCount[item.id] + math.max(item.count, 1)
						sessionCount[item.id] = count
						_supplies[item.id].count = count
					end
				end
			end

			-- Set supplies not found to zero
			for itemid, supply in pairs(_supplies) do
				if supply.group == group then
					if not sessionCount[itemid] then
						_supplies[itemid].count = 0
					end
				end
			end
		end

		-- If not supply types specified, default to all
		if not supplyTypes then
			supplyTypes = {'Runes', 'Potions', 'Ammo', 'Food', 'Supplies', 'Ring', 'Amulet'}
		-- Wrap in table (passed one)
		elseif type(supplyTypes) ~= 'table' then
			supplyTypes = {supplyTypes}
		end

		for i = 1, #supplyTypes do
			checkBackpack(supplyTypes[i])
		end
	end

	local disableAlarm = function()
		prompt('To disable the alarm, enter any text to stop the alarm.', function(response)
			if _script.alarmInterval then
				clearTimeout(_script.alarmInterval)
				_script.alarmInterval = nil
				warn('Alarm disabled.')
			end
		end)
	end

	local function checkAllSupplyThresholds(updatedNeededCount)
		-- Update all supply counts before checking
		updateSupplyCount()

		-- Thresholds
		local minThresholds = false
		local maxThresholds = false
		local alarmThresholds = false

		-- Loop through supplies, find the differences for each setting
		for itemid, supply in pairs(_supplies) do
			-- Minimum is expected to be checked and is below expected
			if supply.min > 0 and supply.count < supply.min then
				if not minThresholds then
					minThresholds = {}
				end
				minThresholds[itemid] = supply
			end
			-- Maximum is expected to be checked and is below expected
			local maxThreshold = supply.max >= 200 and supply.max - 20 or supply.max
			if supply.max > 0 and supply.count < maxThreshold then
				if not maxThresholds then
					maxThresholds = {}
				end
				maxThresholds[itemid] = supply
				-- Lock the buy amount
				if updatedNeededCount then
					supply.needed = supply.max - supply.count
				end
			-- Count is above max, always clear needed
			else
				supply.needed = 0
			end
			-- Alarm is expected to be checked and is below expected
			if supply.alarm > 0 and supply.count < supply.alarm then
				if not alarmThresholds then
					alarmThresholds = {}
				end
				alarmThresholds[itemid] = supply
			end
		end

		-- Log items below minimum & max
		local itemNames = {}
		local itemsAdded = {}
		local itemLists = {minThresholds}

		-- Town check, print max items too
		if not _script.inSpawn then
			itemLists[#itemLists + 1] = maxThresholds
		end

		-- Add items from min and max tables
		for i = 1, #itemLists do
			local list = itemLists[i]
			if list then
				for itemid, _ in pairs(list) do
					-- Make sure we don't add duplicates
					if not itemsAdded[itemid] then
						-- Make name plural
						local name = xeno.getItemNameByID(itemid)
						local suffix = 's'
						-- Name ends with 's', make suffix 'es'
						if string.sub(name, -1) == 's' then
							suffix = 'es'
						end
						-- Check if alarm for this item is triggered
						local important = ''
						if _script.inSpawn and (alarmThresholds and alarmThresholds[itemid]) then
							important = '!!!'
						end
						-- Add to log
						itemNames[#itemNames+1] = name .. suffix .. important
						-- Flag as added to log
						itemsAdded[itemid] = true
					end
				end
			end
		end

		-- Print the min and max items
		if #itemNames > 0 then
			warn('Low supply count for ' .. formatList(itemNames) .. '.')
		end

		-- If any item was added to the alarm threshold, start alarm
		if _script.inSpawn and alarmThresholds and not _script.alarmInterval then
			-- Sound alarm until disabled
			_script.alarmInterval = setInterval(function()
				xeno.alert()
			end, DELAY.AlARM_INTERVAL)

			-- Send alarm immediately
			xeno.alert()

			-- Send stop alarm prompt to user
			disableAlarm()
		end

		-- Return all supplies below thresholds
		return {
			min = minThresholds,
			max = maxThresholds,
			alarm = alarmThresholds
		}
	end

	local function getResupplyDetails()
		-- Only run this after selling loot, depositing loot gold, and withdrawing supplies
		-- Needed count for items will be locked after running this function
		-- Counts are decremented per item purchase
		-- count can decrease after selling loot
		-- count can increase after depositing loot gold
		-- count can decrease after withdrawing supplies
		local totalCost = 0
		local totalWeight = 0
		local refillSupplyGroups = {}
		local refillSoftboots = false
		local venoreTravel = false
		local edronTravel = false
		local runeTravel = nil
		local sourceTown = string.lower(_script.town)

		-- Spawn traveling, lookup by script name, apply a flat fee
		local spawnTravelFee = SPAWN_TRAVELLING[string.lower(_script.name)]
		if spawnTravelFee then
			totalCost = spawnTravelFee
		end

		-- Softboots refill (+ travel costs if not in venore and not already)
		if _config['Soft Boots']['Mana-Percent'] > 0 then
			local wornSoftBootCount = getTotalItemCount(ITEMID.SOFTBOOTS_WORN)
			-- Worn softboots on us, refill
			if wornSoftBootCount > 0 then
				refillSoftboots = true
				-- Not in Venore, we need to travel
				if sourceTown ~= 'venore' then
					venoreTravel = true
				end
				totalCost = totalCost + math.max(0, wornSoftBootCount) * PRICE.SOFTBOOTS_REFILL
			end
		end

		-- Supply refill cost (+ travel costs for exotic runes)
		local thresholds = checkAllSupplyThresholds(true)
		if thresholds.max then
			for itemid, supply in pairs(thresholds.max) do
				if supply.group ~= 'Amulet' and supply.group ~= 'Ring' then
					-- Runes can be domestic or foreign
					if supply.group == 'Runes' then
						-- We need to travel to Edron to get premium runes
						if RUNES_EXOTIC[itemid] and not EXOTIC_RUNE_TOWNS[sourceTown] then
							edronTravel = true
							runeTravel = 'Edron'
						-- We are in Edron and we need to travel to get free runes
						elseif RUNES_NORMAL[itemid] and sourceTown == 'edron' then
							venoreTravel = true
							runeTravel = 'Venore'
						-- We can buy these runes in town
						else
							refillSupplyGroups[supply.group] = true
						end
					-- Other supplies are all domestic
					elseif supply.group == 'Potions' or supply.group == 'Ammo' or supply.group == 'Food' then
						refillSupplyGroups[supply.group] = true
					end
					totalCost = totalCost + supply.needed * xeno.getItemCost(itemid)
					totalWeight = totalWeight + supply.needed * xeno.getItemWeight(itemid)
				end
			end
		end

		-- Add all travel costs to total
		if venoreTravel then
		    local travelRoute = TRAVEL_ROUTES[sourceTown .. '~venore']
		    local returnRoute = TRAVEL_ROUTES['venore~' .. sourceTown]
		    if not travelRoute then
		        error('Missing travel route from ' .. sourceTown .. ' to venore. Please contact support.')
		    end
		    totalCost = totalCost + travelRoute.cost + returnRoute.cost
		end
		if edronTravel and sourceTown ~= 'edron' then
		    local returnRoute = TRAVEL_ROUTES['edron~' .. sourceTown]
		    if venoreTravel then
		        -- Since we're returning directly from Edron we don't need the cash for traveling back from Venore anymore.
		        local notNeededVenoreReturnRoute = TRAVEL_ROUTES['venore~' .. sourceTown]
		        totalCost = totalCost - notNeededVenoreReturnRoute.cost
		        -- We already had to go to venore, head from venore to edron
		        sourceTown = 'venore'
		    end
		    local travelRoute = TRAVEL_ROUTES[sourceTown .. '~edron']
		    if not travelRoute then
		        error('Missing travel route from ' .. sourceTown .. ' to edron. Please contact support.')
		    end
		    totalCost = totalCost + travelRoute.cost + returnRoute.cost
		end

		return {
			withdrawGold = math.max(0, totalCost),
			capNeeded = math.max(0, totalWeight),
			refillSupplyGroups = refillSupplyGroups,
			refillSoftboots = refillSoftboots,
			foreignRuneTown = runeTravel
		}
	end

	local function resupply(callback, step, loot, details)
		--[[ 
			- Check if we need to go to loot seller
				- Sell loot (if any)
			- Check if we need to go to bank
				- Deposit gold (if any)
				IF NOT WITHDRAWING SUPPPLIES:
					- Withdraw gold
			- Check if we need to go to depot
				- Deposit loot (if any)
				- Withdraw supplies (if any)
			- IF HASN'T WITHDREW SUPPLY GOLD Check if we need to go to bank
				- Withdraw gold
			- Check travel-prone supplies first
				- Softboot refill (travel venore)
				- In edron and need "normal" runes (travel venore)
				- Not in edron, gray island, rathleton and need "exotic" runes (travel edron)
					- If already traveling to venore, travel directly from venore to edron
			- Check regular supplies
				- Runes not needing travel, Potions, Ammo, and Food
				- Order is based on current distance
		]]

		-- Update HUD and script state
		_script.state = 'Resupplying';

		step = step or 0

		-- Step 1) Detect loot to sell
		if step < 1 then
			-- Deep search of loot backpack.
			delayWalker()
			getContainerItemCounts(_backpacks['Loot'], function(items)
				resumeWalker()

				-- No items at all, skip step
				if not items then
					resupply(callback, 1, items)
					return
				end

				-- NPC Sell disabled (still pass items for deposit detection)
				if not _config['Loot']['Npc-Sell'] then
					resupply(callback, 1, items)
					return
				end

				-- List of sellable loot in this town
				local townLoot = SELLABLE_LOOT[string.lower(_script.town)]

				-- Nothing sellable in town, skip step
				if not townLoot then
					resupply(callback, 1, items)
					return
				end

				-- Path chosen (closest to us)
				local closestPath = nil
				local closestDistance = nil
				local supplyTown = string.lower(_script.town)
				local selfPos = xeno.getSelfPosition()

				-- Determine if we can sell each loot item
				local lootPaths = {}
				local lootPathCount = 0
				for itemid, itemcount in pairs(items) do
					-- We can sell this item
					local lootPath = townLoot[itemid]
					if lootPath then
						-- First type found is boolean, only one loot seller for town
						if type(lootPath) == 'boolean' then
							lootPaths['loot'] = true
							break
						-- Insert loot path as an option if not already
						elseif not lootPaths['loot.' .. lootPath] then
							lootPaths['loot.' .. lootPath] = true
							lootPathCount = lootPathCount + 1
						end
					end
				end

				-- Find the closest loot path to take
				for pathName, _ in pairs(lootPaths) do
					local label = supplyTown .. '|' .. pathName .. '~depot'
					-- Path exists
					if walkerLabelExists(label) then
						local pos = walkerGetPosAfterLabel(label)
						local distance = getDistanceBetween(selfPos, pos)
						-- Closest label so far
						if closestDistance == nil or distance < closestDistance then
							closestDistance = distance
							closestPath = pathName
						end
					end
				end

				-- We have loot to deposit
				if closestPath then
					log('Walking to the depot to deposit loot.')
					walkerGotoLocation(_script.town, closestPath, function()
						-- Arrived at loot shop
						shopSellLoot(townLoot, function()
							-- Repeat step if more loot paths
							if lootPathCount > 1 then
								resupply(callback, 0, items)
							-- Skip to next step
							else
								resupply(callback, 1, items)
							end
						end)
					end)
				-- No loot, go to next step
				else
					resupply(callback, 1, items)
				end
			end, true)
			return
		end

		-- Step 2) Detected money to deposit AND we need to do step 3 OTHERWISE skip to step 4
		if step < 2 then
			-- Loot remaining in loot backpack
			local depositLoot = false
			if loot then
				for itemid, _ in pairs(loot) do
					if itemid ~= ITEMID.OBSIDIAN_KNIFE and itemid ~= ITEMID.BLESSED_STAKE then
						depositLoot = true
						break
					end
				end
			end
			
			-- We need to withdraw supplies
			local withdrawSupplies = not _script.disableWithdraw and checkAllSupplyThresholds().max

			-- We can skip step 3, so we can also skip this step, go past 3.
			if not depositLoot and not withdrawSupplies then
				resupply(callback, 3, loot)
				return
			end

			local gold = getMoney()
			if gold > 500 then
				walkerGotoLocation(_script.town, 'bank', function(path)
					-- Arrived at bank
					bankDepositGold(function()
						-- Balance
						bankGetBalance(function()
							-- Deposited gold, continue resupply
							resupply(callback, 2, loot)
						end, true)
					end)
				end)
			else
				-- Skip to next step
				resupply(callback, 2, loot)
			end
			return
		end

		-- Step 3) Detected loot to deposit or supplies to withdraw
		if step < 3 then
			-- Loot remaining in loot backpack
			local depositLoot = false
			if loot then
				for itemid, _ in pairs(loot) do
					if itemid ~= ITEMID.OBSIDIAN_KNIFE
						and itemid ~= ITEMID.MECHANICAL_ROD
						and itemid ~= ITEMID.FISHING_ROD
						and itemid ~= ITEMID.BLESSED_STAKE then
						depositLoot = true
						break
					end
				end
			end

			-- We need to withdraw supplies
			local neededSupplies = false
			if not _script.disableWithdraw then
				neededSupplies = checkAllSupplyThresholds(true).max
			end

			if depositLoot and neededSupplies then
				log('Walking to the depot to withdraw supplies and deposit loot.')
			elseif depositLoot then
				log('Walking to the depot to deposit loot.')
			elseif neededSupplies then
				log('Walking to the depot to withdraw supplies.')
			end

			-- Do we need to head to the depot (deposit or withdraw)
			if depositLoot or neededSupplies then				
				walkerGotoLocation(_script.town, 'depot', function()
					-- Arrived at depot
					startDepotTransfer(depositLoot, neededSupplies, function()
						if _script.chainConfig then
							if checkChainRules(_script.chainConfig) then
								return
							end
						end
						-- Finished deposit & withdraw, continue resupply
						resupply(callback, 3, loot)
					end)
				end)
				return
			end
		end

		-- SHIT GETS REAL NOW. From this point on we need to look into the future
		-- Includes gold cost, softboot refill, and foreign rune town
		-- Do NOT call more than once, as it resets the future (resets needed values)!!!
		if not details then
			details = getResupplyDetails()
		end

		-- Step 4) Once this is called the amount we will buy is locked
		if step < 4 then
			if details.withdrawGold > 0 then 
				-- Check capacity
				if details.capNeeded > 0 then
					-- Deduct weight of supplies we sell before buying (flasks)
					--[[local estimatedCap = xeno.getSelfCap() - getFlaskWeight()
					-- Not enough capacity for supplies error
					if details.capNeeded > estimatedCap then
						error('Not enough capacity for supplies. Please lower config values or increase your capacity.')
						return
					end]]
				end
				walkerGotoLocation(_script.town, 'bank', function()
					-- Arrived at bank
					bankDepositGold(function()
						-- Under 10k rounds to nearest hundredths, otherwise thousandths 
						local roundTo = details.withdrawGold < 10000 and 100 or 1000
						local roundedCost = math.ceil(details.withdrawGold / roundTo) * roundTo
						-- Withdraw travel funds
						bankWithdrawGold(roundedCost, function()
							-- Balance
							bankGetBalance(function()
								-- Finished bank withdrawal, continue resupply
								resupply(callback, 4, loot, details)
							end, true)
						end, true)
					end)
				end)
				return
			end
		end

		-- Step 5) Detected softboots to refill
		if step < 5 then
			if details.refillSoftboots then
				walkerGotoLocation('Venore', 'soft.boots', function()
					-- Arrived at softboots
					shopRefillSoftboots(function()
						-- Refilled boots, continue resupply
						resupply(callback, 5, loot, details)
					end)
				end)
				return
			end
		end

		-- Step 6) Detected foreign runes to buy
		if step < 6 then
			if details.foreignRuneTown then
				walkerGotoLocation(details.foreignRuneTown, 'runes', function()
					-- Arrived at softboots
					shopBuySupplies('Runes', function()
						-- Refilled boots, continue resupply
						resupply(callback, 6, loot, details)
					end)
				end)
				return
			end
		end

		-- Step 7) Detected remaining supplies to buy (runes, potions, ammo, food)
		if step < 7 then
			-- Loop through all supplies needed to refill
			-- go to the closest supply location
			-- remove the group from the refill table
			-- repeat until none are left
			-- when none are left set step to 7
			local selfPos = xeno.getSelfPosition()
			local supplyTown = string.lower(_script.town)
			local supplyChosen = nil
			local supplyDistance = nil

			for supply, status in pairs(details.refillSupplyGroups) do
				if status then
					-- Find a label that starts at the destination (so we can determine distance)
					local label = supplyTown .. '|' .. string.lower(supply) .. '~depot'
					-- Route to supplies has to exist
					if walkerLabelExists(label) then
						local pos = walkerGetPosAfterLabel(label)
						local distance = getDistanceBetween(selfPos, pos)
						-- Closest label so far
						if supplyDistance == nil or distance < supplyDistance then
							supplyDistance = distance
							supplyChosen = supply
						end
					end
				end
			end


			-- No supply chose, this step is complete
			if not supplyChosen then
				resupply(callback, 7, loot, details)
				return
			end

			-- Walk to closest shop
			walkerGotoLocation(_script.town, string.lower(supplyChosen), function()
				-- Arrived at supplier
				shopBuySupplies(supplyChosen, function()
					-- Clear this supply
					details.refillSupplyGroups[supplyChosen] = nil
					-- Resupplied, trigger same step until we're out of resupplies
					resupply(callback, 6, loot, details)
				end)
			end)

			return
		end

		-- Done, go to town exit
		log('Ready to hunt. Walking to the spawn.')

		-- Update script state
		_script.state = 'Walking to town exit';
		
		walkerGotoLocation(_script.town, _script.townexit, function()

			-- Update script state
			_script.state = 'Walking to spawn';

			-- Exited town, go to spawn
			walkerStartPath(_script.town, _script.townexit, 'spawn', function()
				-- Enter spawn
				xeno.gotoLabel('enterspawn')
				resumeWalker()
				xeno.setTargetingEnabled(true)
				xeno.setLooterEnabled(true)
				-- Reached spawn
				if callback then
					callback()
					-- We finished our first resupply
					_script.firstResupply = false
				end
			end)
		end)
	end

	-- Export global functions
	return {
		checkSoftBoots = checkSoftBoots,
		checkAllSupplyThresholds = checkAllSupplyThresholds,
		resupply = resupply
	}
end)()
