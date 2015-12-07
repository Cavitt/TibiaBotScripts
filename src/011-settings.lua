Settings = (function()
	
	-- Imports
	local titlecase = Core.titlecase
	local formatList = Core.formatList
	local getSelfName = Core.getSelfName
	local split = Core.split
	local trim = Core.trim
	local setTimeout = Core.setTimeout
	local warn = Console.warn
	local error = Console.error
	local prompt = Console.prompt
	local walkerGetNeededTools = Walker.walkerGetNeededTools

	local function loadSettingsFile(callback)
		local file = io.input(FOLDER_SETTINGS_PATH .. _script.slug)
		local message = 'Make sure "'.._script.slug..'" is in the "Documents/XenoBot/Settings" folder. Type "retry" to continue.'
		local function promptXBST()
			prompt(message, function(response)
				if string.find(string.lower(response), 'retry') then
					loadSettingsFile(callback)
				else
					promptXBST()
				end
			end)
		end
		
		-- File does not exist
		if not file then
			promptXBST()
			return
		end

		-- Read whole file
		local xml = io.read("*all")
		io.close(file)
		
		-- Could not read
		if not xml then
			promptXBST()
			return
		end

		local tbl = {}

		local parseAttributes = function(str)
			local attr = {}
			string.gsub(str, PATTERN.XML_ATTR, function (w, _, a)
				attr[w] = a
			end)
			return attr
		end

		local index = 1
		local current = {panel=nil, control=nil}
		while true do
			local begin, final, closed, label, str, empty = string.find(xml, PATTERN.XML_TAG, index)
			if not begin then
				break
			end

			local attr = parseAttributes(str)

			-- Contains no inner value: <item name="ex" />
			if empty == '/' and tbl[current.panel] then
				local attr = parseAttributes(str)
				local target = (current.control ~= nil) and tbl[current.panel][current.control] or tbl[current.panel]
				if attr.name then
					target[attr.name] = attr.value
				else
					table.insert(target, attr)
				end

			-- New element start with possible children
			elseif closed == '' and attr.name then
				if label == 'panel' then
					tbl[attr.name] = {}
				elseif label == 'control' and tbl[current.panel] then
					tbl[current.panel][attr.name] = {}
				end
				current[label] = attr.name
			else -- close tag: </end> 
				current[label] = nil
			end
			index = final + 1
		end

		_settings = tbl
		
		callback()

		return true
	end

	local function setNeededTools(callback)
		local tools = walkerGetNeededTools()
		if tools then
			-- Loop through main backpack
			local mainbp = _backpacks['Main']
			for spot = 0, xeno.getContainerItemCount(mainbp) - 1 do
				local item = xeno.getContainerSpotData(mainbp, spot)
				-- Rope
				if tools.rope and ROPE_TOOLS[item.id] then
					-- Save tool id
					_script.rope = item.id
					_script.ropeCode = ROPE_TOOLS[item.id]
					-- Stay on the same spot if its a whacky tool
					if item.id == 9594 or item.id == 9596 or item.id == 9598 then
						_script.shovel = item.id
						_script.pick = item.id
						_script.shovelCode = SHOVEL_TOOLS[item.id]
					end
					-- No other tools needed to detect, break search
					if not tools.shovel and not tools.pick then
						break
					end
				-- Shovel
				elseif tools.shovel and SHOVEL_TOOLS[item.id] then
					-- Save tool id
					_script.shovel = item.id
					_script.shovelCode = SHOVEL_TOOLS[item.id]
					-- Stay on the same spot if its a whacky tool
					if item.id == 9594 or item.id == 9596 or item.id == 9598 then
						_script.shovel = item.id
						_script.pick = item.id
						_script.shovelCode = SHOVEL_TOOLS[item.id]
					end
					-- No other tools needed to detect, break search
					if not tools.rope and not tools.pick then
						break
					end
				-- Pick
				elseif tools.pick and PICK_TOOLS[item.id] then
					-- Save tool id
					_script.pick = item.id
					-- No other tools needed to detect, break search
					if not tools.rope and not tools.shovel then
						break
					end
				end
			end

			-- Error if we didn't find a tool we needed
			local missingTools = {}
			for tool, needed in pairs(tools) do
				if needed then
					if (tool == 'shovel' and not _script.shovel) or
					   (tool == 'rope' and not _script.rope) or
					   (tool == 'pick' and not _script.pick) then
						-- Add tool to missing list
						missingTools[#missingTools+1] = tool
					end
				end
			end
			if #missingTools > 0 then
				local message = 'You need a ' .. formatList(missingTools) .. ' in your main backpack. Type "retry" to continue.'
				local function promptTools()
					prompt(message, function(response)
						if string.find(string.lower(response), 'retry') then
							setNeededTools(callback)
						else
							promptTools()
						end
					end)
				end
				promptTools()
				return
			end
		end
		callback(tools)
	end

	local lureTemplate = '<panel name="Dynamic Lure"><control name="LureList"><item count="%d" prioMax="9" prioMin="%d" prioRaw="%d" until="%d" enabled="1" /></control><control name="AttackWhileLuring" value="%d"/></panel>'
	local function getDynamicLureXBST()
		local amount = _config['Lure']['Amount']
		local priority = _config['Lure']['MinPriority']
		local untilCount = _config['Lure']['Until'] or 0
		local attackWhileLure = _config['Lure']['AttackWhileLure'] and 1 or 0
		-- Validate config
		if not priority or priority > 9 or priority < 0 then
			error('[Config Error] Dynamic lure minimum priority is missing or invalid [0-9]!')
			return
		end
		-- Validate amounts
		if untilCount >= amount then
			error('[Config Error] Dynamic lure "until" cannot be greater than "amount"!')
			return
		end

		local rawPrio = 100 + priority
		return lureTemplate:format(amount, priority, rawPrio, untilCount, attackWhileLure)
	end

	local function getShooterXBST()
		local xbst = nil
		local shooterList = {}
		local maxMana = xeno.getSelfMaxMana()

		-- Loop through supplies, add Runes and Spells to the list.
		for supplyid, supply in pairs(_supplies) do
			-- Belongs to the correct section, and has shooter settings
			if supply.group == 'Spells' or supply.group == 'Runes' and supply.options then
				-- Titlecase monsters incase the user didn't
				local targets = supply.options['Targets']
				if type(targets) == 'table' then
					for i = 1, #targets do
						if targets[i] then
							targets[i] = titlecase(targets[i])
						end
					end
					targets = table.concat(targets, ',')
				elseif targets then
					targets = titlecase(targets)
				end

				-- Look up item details
				local details = MAGIC_SHOOTER_ITEM[supplyid]
				if details then
					if supply.group == 'Runes' or maxMana >= details.mana then
						-- Add new item
						shooterList[#shooterList+1] = {
							spell = supply.group == 'Spells' and supplyid or '',
							rune = supply.group == 'Runes' and supplyid or 0,
							srange = details.srange,
							type = details.type,
							mana = details.mana and math.ceil((details.mana / xeno.getSelfMaxMana()) * 100) or 0,
							creature = targets,
							minhp = supply.options['MinHP'],
							maxhp = supply.options['MaxHP'],
							count = supply.options['TargetMin'],
							utito = supply.options['Utito'],
							priority = supply.options['Priority']
						}
						-- If utito is enabled, make a shooter entry (copy spell conditions)
						if supply.options['Utito'] then
							shooterList[#shooterList+1] = {
								spell = 'utito tempo',
								rune = 0,
								srange = details.srange,
								type = 4,
								mana = 50,
								--mana = details.mana and math.ceil((details.mana / xeno.getSelfMaxMana()) * 100) or 0,
								creature = targets,
								minhp = supply.options['MinHP'],
								maxhp = supply.options['MaxHP'],
								count = supply.options['TargetMin'],
								priority = 0
							}
						end
					else
						warn('Could not add "'..supplyid..'" to the shooter. You do not have enough mana to cast this spell.')
					end
				else
					if supply.group == 'Runes' then
						warn('Could not add "'..xeno.getItemNameByID(supplyid)..'" to the shooter. If this is a valid attack rune, please contact support.')
					else
						warn('Could not add "'..supplyid..'" to the shooter. If this is a valid attack spell, please contact support.')
					end
				end
			end
		end

		if #shooterList > 0 then
			xbst = '<panel name="Spell Shooter"><control name="shooterList">'
			-- Sort shooter list by priority
			table.sort(shooterList, function(a, b)
				return a.priority < b.priority
			end)
			-- Add each list item
			for i = 1, #shooterList do
				local item = shooterList[i]
				xbst = xbst .. string.format(
					'<item spell="%s" rune="%d" srange="%s" type="%s" reason="0" minhp="%d" maxhp="%d" mana="%d" count="%d" creature="%s" danger="1" targ="1" enabled="1"/>',
					item.spell, item.rune, item.srange, item.type, item.minhp or 0, item.maxhp or 0, item.mana or 0, item.count or 0, item.creature
				)
			end
			xbst = xbst .. '</control></panel>'
		end
		return xbst
	end

	local function setDynamicSettings(callback)
		-- Detect needed tools
		setNeededTools(function(tools)
			local xbstContents = ''

			-- Walker Options
			if _script.ropeCode > 0 or _script.shovelCode > 0 then
				xbstContents = string.format([[<panel name="Walker Options"><control name="ropeOption" value="%d"/><control name="shovelOption" value="%d"/></panel>]], _script.ropeCode, _script.shovelCode)
			end

			-- Detect ammunition or distance weapons
			local disWeaponID = 0
			local disAmmoID = 0
			for itemid, supply in pairs(_supplies) do
				if supply.group == 'Ammo' then
					if DISTANCE_WEAPONS[itemid] then
						disWeaponID = itemid
					else
						disAmmoID = itemid
					end
				end
			end

			-- Equipment Manager
			if disWeaponID > 0 or disAmmoID > 0 then
				if not xbstContents then
					xbstContents = ''
				end
				xbstContents = xbstContents .. string.format([[<panel name="Equipment Manager"><control name="AmmoRefillID" value="%d"/><control name="AmmoRefillEnable" value="%d"/><control name="WeaponRefillID" value="%d"/><control name="WeaponRefillEnable" value="%d"/></panel>]], disAmmoID, disAmmoID > 0 and 1 or 0, disWeaponID, disWeaponID > 0 and 1 or 0)
			end

			-- Looter
			local lootStyle = _config['Loot']['Loot-Style'] == 'first' and '0' or '1'
			local unlisted = _script.name:find('Thais Paw Collector') and '0' or '1'
			local lootXML = '<panel name="Looter"><control name="LootList" mode="' .. lootStyle .. '" minimum="0" maximum="0" skinner="2" unlisted="' .. unlisted .. '">'
			
			-- Demonic Blood use/loot
			lootXML = lootXML .. '<item ID="6558" action="20"/><item ID="237" action="1"/><item ID="236" action="1"/>'
			
			-- Only add gold if enabled
			if _config['Loot']['Loot-Gold'] then
				lootXML = lootXML .. '<item ID="3031" action="' .. _backpacks['Gold'] .. '"/>'
			end

			-- Always add platinum coins to gold backpack (even if gold bp==main)
			lootXML = lootXML .. '<item ID="3035" action="' .. _backpacks['Gold'] .. '"/>'

			-- Loop through targetlist, get items to add to looter
			local targeting = _settings['Targeting']
			if targeting then
				local targets = targeting['TargetingList']
				if targets then
					local lootList = {}
					for i = 1, #targets do
						local creatures = split(targets[i].type, ',')
						for k = 1, #creatures do
							local creature = trim(creatures[k])
							local monsterLoot = MONSTER_LOOT[creature]
							if monsterLoot then
								for j = 1, #monsterLoot do
									lootList[monsterLoot[j]] = true
								end
							end
						end
					end
					-- Add loot items to looter
					local minValue = _config['Loot']['Loot-Min-Value']
					local maxWeight = _config['Loot']['Loot-Max-Weight']
					local whiteList = _config['Loot']['Loot-WhiteList']
					local blackList = _config['Loot']['Loot-BlackList']

					-- Convert strings to tables if needed
					if type(whiteList) ~= 'table' then
						whiteList = {whiteList}
					end
					if type(blackList) ~= 'table' then
						blackList = {blackList}
					end

					-- Sort loot by value
					local lootKeys = {}
					for itemid, _ in pairs(lootList) do
						lootKeys[#lootKeys+1] = itemid
					end
					table.sort(lootKeys, function(a, b)
						return xeno.getItemValue(a) > xeno.getItemValue(b)
					end)

					-- Iterate sorted keys
					for i = 1, #lootKeys do
						local itemid = lootKeys[i]
						local name = string.lower(xeno.getItemNameByID(itemid))
						local blackListed = blackList and #blackList > 0 and table.find(blackList, name, true)
						if not blackListed then
							-- POTIONS
							local whiteListed = whiteList and #whiteList > 0 and table.find(whiteList, name, true)
							-- Meets min value condition
							if whiteListed or ITEM_LIST_POTIONS[itemid] or ITEM_LIST_RUSTYARMORS[itemid] or (not minValue or minValue <= 0 or xeno.getItemValue(itemid) >= minValue) then
								-- Meets max weight condition
								if whiteListed or ITEM_LIST_POTIONS[itemid] or ITEM_LIST_RUSTYARMORS[itemid] or (not maxWeight or maxWeight <= 0 or xeno.getItemWeight(itemid) <= maxWeight) then
									lootXML = lootXML .. '<item ID="' .. itemid .. '" action="' .. _backpacks['Loot'] .. '"/>'
								end
							end
						end
					end
				end
			end

			-- End of list
			xbstContents = xbstContents .. lootXML .. '</control></panel>'

			-- Magic Shooter
			if not _config['General']['Manual-Shooter'] then
				local shooter = getShooterXBST()
				if shooter then
					if not xbstContents then
						xbstContents = ''
					end
					xbstContents = xbstContents .. shooter
				end
			end

			-- Dynamic Lure
			if _config['Lure'] and _config['Lure']['Amount'] and _config['Lure']['Amount'] > 0 then
				local lurexml = getDynamicLureXBST()
				if lurexml then
					if not xbstContents then
						xbstContents = ''
					end
					xbstContents = xbstContents .. lurexml
				end
			end

			-- Save XBST if needed
			if xbstContents then				
				local filename = 'tmp.' .. string.gsub(getSelfName(), ".", string.byte)
				local file = io.open(FOLDER_SETTINGS_PATH .. filename .. '.xbst', 'w+')
				if file then
					file:write(xbstContents)
					file:close()
					xeno.loadSettings(FOLDER_SETTINGS_PATH .. filename, 'All')
					setTimeout(function()
						os.remove(FOLDER_SETTINGS_PATH .. filename .. '.xbst')
					end, 500)
				end
			end
			callback()
		end)
	end

	-- Export global functions
	return {
		loadSettingsFile = loadSettingsFile,
		setDynamicSettings = setDynamicSettings
	}
end)()
