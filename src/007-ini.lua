Ini = (function()
	-- Imports
	local split = Core.split
	local trim = Core.trim
	local countPairs = Core.countPairs
	local indexTable = Core.indexTable
	local setTimeout = Core.setTimeout
	local getSelfName = Core.getSelfName
	local debug = Core.debug
	local error = Console.error
	local log = Console.log
	local prompt = Console.prompt

	local function loadIniFile(file)
		-- Could not load config
		if not file then
			error('Could not load the config.')
		end

		local tbl = {}
		local section
		for line in file:lines() do
			local s = string.match(line, "^%[([^%]]+)%]$")
			if s then
				section = s
				tbl[section] = tbl[section] or {}
			end

			local key, value = string.match(line, "^([^%s]+)%s+=%s+([^;]+)")

			-- If the first try didnt work, check for a multi-word key
			if not key then
				key, value = string.match(line, '"(.+)"%s+=%s+([^;]*)')
			end
			if key and value then
				-- Type casting
				if tonumber(value) ~= nil then
					value = tonumber(value)
				else
					value = string.gsub(value, "^%s*(.-)%s*$", "%1")
					if value == "true" then
						value = true
					elseif value == "false" then
						value = false
					-- Transform comma-delimited string to table
					elseif string.find(value, ',') then
						value = split(value, ',')
						for i = 1, #value do
							value[i] = trim(value[i])
						end
					end
				end
				if section then
					if not tbl[section] then
						tbl[section] = {}
					end
					tbl[section][key] = value
				end
			end
		end

		file:close()
		return tbl
	end

	local function loadMarketPrices()
		local file = io.open(PRICES_CONFIG_PATH, 'r')

		-- Found config, compare config version against embedded config
		if file then
			local match = false
			for line in file:lines() do
				if string.match(line, '^; ::' .. _script.pricesConfigHash .. '$') then
					match = true
					break
				end
			end
			if not match then
				log('Updating script config file...')
				file:close()
				file = nil
			end
		end
		-- Could not find a config anywhere (or we wanted to update)
		if not file then
			-- Write the embedded config to disk
			local defaultConfig = io.open(PRICES_CONFIG_PATH, 'w+')
			if defaultConfig then
				defaultConfig:write(LIB_PRICES_CONFIG)
				defaultConfig:close()
			else
				error('Could not write default config file.')
			end
			
			-- Try again
			file = io.open(PRICES_CONFIG_PATH, 'r')
		end

		local priceConfig = loadIniFile(file)
		local prices = {}

		-- Load default prices
		if priceConfig['Default'] then
			for name, price in pairs(priceConfig['Default']) do
				local id = xeno.getItemIDByName(name)
				prices[id] = price
			end
		end

		-- Load and overwrite with character specific config
		if priceConfig[getSelfName()] then
			for name, price in pairs(priceConfig[getSelfName()]) do
				local id = xeno.getItemIDByName(name)
				prices[id] = price
			end
		end

		return prices
	end


	local function updateSupplyConfig()
		local function loadBlockSection(sectionName, extras)
			local section = _config[sectionName]
			if section then
				for key, value in pairs(section) do
					local start, stop = string.find(key, 'Name')
					if start and value then
						-- Base name of the key (ex: 'Mana' of 'ManaName')
						local name = string.sub(key, 1, start-1)
						local enabled = section[name .. 'Enabled']
						-- Supply is enabled
						if enabled ~= false then
							-- TODO: validate user submitted name/id
							local id = nil
							if sectionName == 'Spells' then
								id = string.lower(value)
							else
								id = type(value) == 'string' and xeno.getItemIDByName(value) or tonumber(value)
							end

							local min = section[name .. 'Min'] or 0
							local max = section[name .. 'Max'] or 0

							-- Noob proofing
							if min > max then
								error('Config error. The "' .. name .. 'Min" value is higher than the "' .. name .. 'Max" value.')
							end

							local alarm = section[name .. 'Alarm'] or 0
							local options = nil

							-- Extra fields
							if extras then
								options = {}
								for i = 1, #extras do
									local extraKey = extras[i]
									local extraValue = section[name .. extraKey]
									if extraValue ~= nil then
										if extraKey == 'Creatures' then
										    options[extraKey] = indexTable(extraValue, true)
										else
										    options[extraKey] = extraValue
										end
									end
								end
							end

							-- Add item to supplies list
							_supplies[id] = {
								name = name,
								id = id,
								group = sectionName,
								count = 0,
								needed = 0,
								min = min,
								max = max,
								alarm = alarm,
								options = options
							}
						end
					end
				end
			end
		end

		loadBlockSection('Potions')
		loadBlockSection('Ammo')
		loadBlockSection('Food')
		loadBlockSection('Supplies')
		loadBlockSection('Runes', {'Priority', 'TargetMin', 'Targets', 'MaxHP', 'MinHP'})
		loadBlockSection('Spells', {'Priority', 'TargetMin', 'Targets', 'Utito', 'MaxHP', 'MinHP'})
		loadBlockSection('Ring', {'Creatures', 'CreatureCount', 'MinHP', 'MinMP'})
		loadBlockSection('Amulet', {'Creatures', 'CreatureCount', 'MinHP', 'MinMP'})
	end

	local function loadMasterConfig()
		local file = io.open(MASTER_CONFIG_PATH, 'r')
		if not file then
			return nil
		end
		local config = loadIniFile(file)

		local groups = {}
		-- Multi Script #1
		for name, rules in pairs(config) do
			local priority = tonumber(name:match('Multi Script #(%d)'))
			if rules.Enabled then
				rules.priority = priority
				groups[#groups+1] = rules
			end
		end

		table.sort(groups, function(a, b)
			return a.priority < b.priority
		end)

		return groups
	end

	local function loadConfigFile(callback, isReload)
		local configName = '[' .. getSelfName() .. '] ' .. _script.name .. '.ini'
		local configPath = FOLDER_CONFIG_PATH .. configName

		local function parse(file)
			local tbl = loadIniFile(file)

			-- Convert anti-lure creatures to key,value table
			if tbl['Anti Lure'] then
				local lureCreatures = tbl['Anti Lure']['Creatures']
				if lureCreatures then
					local lureTbl = {}
					if type(lureCreatures) == 'table' then
						for i = 1, #lureCreatures do
							lureTbl[string.lower(lureCreatures[i])] = true
						end
						tbl['Anti Lure']['Creatures'] = lureTbl
					else
						tbl['Anti Lure']['Creatures'] = {
							[string.lower(lureCreatures)] = true
						}
					end
				end
			end

			-- Update start config values
			if not isReload and tbl['HUD'] then
				_script.theme = tbl['HUD']['Theme'] or 'light'
			end

			_config = tbl
			_config['Prices'] = loadMarketPrices()
			updateSupplyConfig()
			callback()
		end

		local function promptConfig()
			local message = 'A new config file was generated, please reconfigure before proceeding. Type "ok" to continue.'
			-- Print in server console (this is not a debug, do not remove)
			print(message)
			prompt(message, function(response)
				if string.find(string.lower(response), 'ok') then
					local newFile = io.open(configPath, 'r')
					parse(newFile)
				else
					promptConfig()
				end
			end)
		end

		-- Open config file
		local file = io.open(configPath, 'r')

		-- Found config, compare config version against embedded config
		if file then
			local match = false
			for line in file:lines() do
				if string.match(line, '^; ::' .. _script.configHash .. '$') then
					match = true
					break
				end
			end
			if not match then
				log('Updating script config file...')
				file:close()
				file = nil
			end
		end

		-- Could not find a config anywhere (or we wanted to update)
		if not file then
			-- Write the embedded config to disk
			local defaultConfig = io.open(configPath, 'w+')
			if defaultConfig then
				defaultConfig:write(LIB_CONFIG)
				defaultConfig:close()
				promptConfig()
			else
				error('Could not write default config file.')
			end
			return
		end

		-- Using existing config
		parse(file)
	end

	local function parseRange(value)
		local range = type(value) == 'number' and {value, value} or split(value, '-')
		return tonumber(range[1]), tonumber(range[2])
	end

	local function checkChainRules(groups, initCheck)
		local switchScript = nil
		-- TODO: balance
		local ruleChecks = {
			-- Randomly choose between the range, always trigger if reached or above range
			['Rounds'] = function(req)
				if req == 0 then return false end
				local min, max = parseRange(req)
				local target = math.random(min, max)
				local round = _script.round - 1
				local status = round == target or round >= max
				debug(('Rounds rule: %s [%d = %d]'):format(tostring(status), round, target))
				return status
			end,
			-- Randomly choose between the range, always trigger if reached or above range
			['Level'] = function(req)
				if req == 0 then return false end
				local min, max = parseRange(req)
				local target = math.random(min, max)
				local level = xeno.getSelfLevel()
				local status = level == target or level >= max
				debug(('Level rule: %s [%d = %d]'):format(tostring(status), level, target))
				return status
			end,
			-- Trigger within the range
			['Experience'] = function(req)
				if req == 0 then return false end
				local min, max = parseRange(req)
				local timediff = os.time() - _script.start
				local gain = xeno.getSelfExperience() - _script.baseExp
				local hourlyexp = tonumber(math.floor(gain / (timediff / 3600))) or 0
				local status = hourlyexp >= min and hourlyexp <= max
				debug(('Hourly exp rule: %s [%d, %s]'):format(tostring(status), hourlyexp, req))
				return status
			end,
			-- Trigger within the range
			['Profit'] = function(req)
				if req == 0 then return false end
				local min, max = parseRange(req)
				local timediff = os.time() - _script.start
				local totalLooted = _hud.index['Statistics']['Looted'].value
				local totalWaste = _hud.index['Statistics']['Wasted'].value
				local profit = totalLooted - totalWaste
				local hourlygain = tonumber(math.floor(profit / (timediff / 3600))) or 0
				local status = hourlygain >= min and hourlygain <= max
				debug(('Hourly profit rule: %s [%d, %s]'):format(tostring(status), hourlygain, req))
				return status
			end,
			-- Randomly choose between the range, always trigger if reached or above range
			['Time'] = function(req)
				if req == 0 then return false end
				local min, max = parseRange(req)
				local target = math.random(min, max)
				local hours = math.floor((os.time() - _script.start) / 3600)
				local status = hours == target or hours >= max
				debug(('Time rule: %s [%d = %d]'):format(tostring(status), hours, target))
				return status
			end,
			-- Randomly choose between the range, always trigger if reached or above range
			['Strangers'] = function(req)
				if req == 0 then return false end
				local min, max = parseRange(req)
				local target = math.random(min, max)
				local strangers = _script.strangers
				local status = strangers == target or strangers >= max
				debug(('Crowded rule: %s [%d = %d]'):format(tostring(status), strangers, target))
				return status
			end
		}

		for i = 1, #groups do
			local properties = groups[i]
			-- Character is in group or no character list supplied
			local players = indexTable(properties.Characters, true)
			if not players or players[getSelfName():lower()] then
				local scriptList = indexTable(properties.From, true)
				local currentScript = _script.slug:gsub('.xbst', '')
				if not scriptList or scriptList[currentScript:lower()] then

					local rules = {}
					-- Get rule list from properties
					for property, value in pairs(properties) do
						if ruleChecks[property] then
							rules[property] = value
						end
					end

					-- How many rules it takes to trigger a switch for this group of rules
					local ruleLimit = properties.Check == 'all' and countPairs(rules) or properties.Check
					local failedRules = 0

					-- Start checking rules
					for rule, requirement in pairs(rules) do
						if not initCheck or (initCheck and (rule == 'Level')) then
							local status = ruleChecks[rule](requirement)
							if status then
								failedRules = failedRules + 1
								-- Found a script, stop checking rules in this group
								if failedRules >= ruleLimit then
									local scripts = properties.Goto
									local tries = 20
									local function getTargetScript()
										local target = type(scripts) == 'string' and scripts or scripts[math.random(1, #scripts)]
										if target:lower() == currentScript:lower() then
											if type(scripts) == 'string' then
												return nil
											end
											tries = tries - 1
											if tries <= 0 then
												return nil
											end
											return getTargetScript()
										end
										return target
									end
									local targetScript = getTargetScript()
									if targetScript then
										switchScript = targetScript
										break
									end
								end
							end
						end
					end

					debug(('Rule Group #%d: %d/%d'):format(i, failedRules, ruleLimit))

					-- Found a script, stop checking groups of rules
					if switchScript then
						debug('Chaining to script: ' .. switchScript)
						xeno.loadSettings(switchScript, 'All')
						break
					end
				end
			end
		end

		return switchScript ~= nil
	end

	-- Export global functions
	return {
		loadConfigFile = loadConfigFile,
		loadMasterConfig = loadMasterConfig,
		checkChainRules = checkChainRules
	}
end)()
