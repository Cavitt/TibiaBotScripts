local LIB_REVISION = '{{VERSION}}'
local LIB_CONFIG = [[{{CONFIG}}]]
local FOLDER_SETTINGS_PATH = '..\\Settings\\'
local FOLDER_CONFIG_PATH = '..\\'

local NORTH = NORTH
local EAST = EAST
local SOUTH = SOUTH
local WEST = WEST
local SOUTHWEST = SOUTHWEST
local SOUTHEAST = SOUTHEAST
local NORTHWEST = NORTHWEST
local NORTHEAST = NORTHEAST

local CREATURES_LOW = CREATURES_LOW
local CREATURES_HIGH = CREATURES_HIGH

local TIMER_TICK = TIMER_TICK
local WALKER_SELECTLABEL = WALKER_SELECTLABEL
local ERROR_MESSAGE = ERROR_MESSAGE
local LOOT_MESSAGE = LOOT_MESSAGE
local BATTLE_MESSAGE = BATTLE_MESSAGE
local EVENT_SELF_CHANNELSPEECH = EVENT_SELF_CHANNELSPEECH
local EVENT_SELF_CHANNELCLOSE = EVENT_SELF_CHANNELCLOSE
local PRIVATE_MESSAGE = PRIVATE_MESSAGE
local NPC_MESSAGE = NPC_MESSAGE

local CHANNEL_ORANGE = CHANNEL_ORANGE
local CHANNEL_YELLOW = CHANNEL_YELLOW
local CHANNEL_RED = CHANNEL_RED

local EVENT_LABEL = 'label'
local EVENT_ERROR = 'error'
local EVENT_BATTLE = 'battle'
local EVENT_LOOT = 'loot'
local EVENT_NPC = 'npc'
local EVENT_COMMAND = 'command'
local EVENT_PATH_END = 'pathend'
local EVENT_DEPOT_END = 'depotend'

local DELAY = {}
DELAY.USE_EQUIPMENT = 800
DELAY.CONTAINER_MOVE_ITEM = 300
DELAY.CONTAINER_USE_ITEM = 1500
DELAY.CONTAINER_BACK = 500
DELAY.BROWSE_FIELD = 800
DELAY.FOLLOW_WAIT = 2000
DELAY.TRADE_TRANSACTION = 500
DELAY.RANGE_TALK = {700, 1200}
DELAY.CLEAN_CONTAINERS_INTERVAL = 5 * 60 * 1000

local THROTTLE_CLEAR_PATH = {limit=2000, last=0}
local THROTTLE_CAP_DROP = {limit=7000, last=0}

local ERROR_CONTAINER_FULL = 'You cannot put more objects in this container.'
local ERROR_NOT_POSSIBLE = 'Sorry, not possible.'

local ITEMID = {
	SPIDER_WEB = 182,
	SOFTBOOTS_ACTIVE = 3549,
	SOFTBOOTS = 6529,
	SOFTBOOTS_WORN = 6530,
	OBSIDIAN_KNIFE = 5908,
	BLESSED_STAKE = 5942,
	FISHING_ROD = 3483,
	MECHANICAL_ROD = 9306,
	ADVENTURERS_STONE = 16277
}

local PRICE = {}
PRICE.SOFTBOOTS_REFILL = 10000

local PATTERN = {
	XML_ATTR = "(%w+)=([\"'])(.-)%2",
	XML_TAG = "<(%/?)([%w:]+)(.-)(%/?)>",
	LABEL_PATH = "(.+)%~(.+)"
}

local CONT_NAME_LOCKER = "Locker"
local CONT_NAME_DEPOT = "Depot Chest"

local LOG_STATUS = 'STATUS'
local LOG_WARNING = 'WARNING'
local LOG_ERROR = 'ERROR'
local LOG_PROMPT = 'PROMPT'

local TOWN_POSITIONS = {
	{name='Venore', x=32940, y=32081},
	{name='Edron', x=33209, y=31829},
	{name='Carlin', x=32350, y=31799},
	{name='Ankrahmun', x=33151, y=32825},
	{name='Darashia', x=33236, y=32431},
	{name='Liberty Bay', x=32314, y=32828},
	{name='Thais', x=32367, y=32223},
	{name='Svargrond', x=32248, y=31145},
	{name='Ab\'dendriel', x=32675, y=31651},
	{name='Port Hope', x=32628, y=32770},
	{name='Yalahar', x=32802, y=31204},
	{name='Farmine', x=33022, y=31513},
	{name='Gray Island', x=33458, y=31320},
	{name='Kazordoon', x=32630, y=31923},
	{name='Gnomebase', x=32797, y=31776},
	{name='Rathleton', x=33626, y=31894}
}

local THEME = {
	light = {
		title = {255, 255, 255},
		primary = {255, 243, 204},
		secondary = {206, 206, 206}
	},
	dark = {
		title = {50, 50, 50},
		primary = {95, 95, 95},
		secondary = {135, 135, 135}
	}
}

-- True = 'town|depot~loot'
-- Name = 'town|depot~loot.name'
local SELLABLE_LOOT = {
	['thais'] = {
		[3274] = true, -- axe
		[3266] = true, -- battle axe
		[3305] = true, -- battle hammer
		[3413] = true, -- battle shield
		[3337] = true, -- bone club
		[3338] = true, -- bone sword
		[3359] = true, -- brass armor
		[3354] = true, -- brass helmet
		[3372] = true, -- brass legs
		[3411] = true, -- brass shield
		[3283] = true, -- carlin sword
		[3358] = true, -- chain armor
		[3352] = true, -- chain helmet
		[3558] = true, -- chain legs
		[3270] = true, -- club
		[3562] = true, -- coat
		[3430] = true, -- copper shield
		[3304] = true, -- crowbar
		[3267] = true, -- dagger
		[3275] = true, -- double axe
		[3379] = true, -- doublet
		[3425] = true, -- dwarven shield
		[3269] = true, -- halberd
		[3268] = true, -- hand axe
		[3276] = true, -- hatchet
		[3353] = true, -- iron helmet
		[3561] = true, -- jacket
		[3300] = true, -- katana
		[3361] = true, -- leather armor
		[3552] = true, -- leather boots
		[3355] = true, -- leather helmet
		[3559] = true, -- leather legs
		[3374] = true, -- legion helmet
		[3285] = true, -- long sword
		[3286] = true, -- mace
		[3282] = true, -- morning star
		[3316] = true, -- orcish axe
		[3357] = true, -- plate armor
		[3557] = true, -- plate legs
		[3410] = true, -- plate shield
		[3272] = true, -- rapier
		[3273] = true, -- sabre
		[3377] = true, -- scale armor
		[3294] = true, -- short sword
		[3293] = true, -- sickle
		[3462] = true, -- small axe
		[3375] = true, -- soldier helmet
		[3409] = true, -- steel shield
		[3378] = true, -- studded armor
		[3336] = true, -- studded club
		[3376] = true, -- studded helmet
		[3362] = true, -- studded legs
		[3426] = true, -- studded shield
		[17824] = true, -- swampling club
		[3264] = true, -- sword
		[3298] = true, -- throwing knife
		[3265] = true, -- two handed sword
		[3367] = true, -- viking helmet
		[3412] = true -- wooden shield
	},
	['svargrond'] = {
		[3274] = true, -- axe
		[3266] = true, -- battle axe
		[3305] = true, -- battle hammer
		[3413] = true, -- battle shield
		[3337] = true, -- bone club
		[3338] = true, -- bone sword
		[3350] = true, -- bow
		[3359] = true, -- brass armor
		[3354] = true, -- brass helmet
		[3372] = true, -- brass legs
		[3411] = true, -- brass shield
		[3283] = true, -- carlin sword
		[3358] = true, -- chain armor
		[3352] = true, -- chain helmet
		[3558] = true, -- chain legs
		[3270] = true, -- club
		[3562] = true, -- coat
		[3430] = true, -- copper shield
		[3349] = true, -- crossbow
		[3304] = true, -- crowbar
		[3267] = true, -- dagger
		[3275] = true, -- double axe
		[3379] = true, -- doublet
		[3425] = true, -- dwarven shield
		[3269] = true, -- halberd
		[3268] = true, -- hand axe
		[3276] = true, -- hatchet
		[3353] = true, -- iron helmet        
		[3561] = true, -- jacket
		[3300] = true, -- katana
		[3361] = true, -- leather armor
		[3552] = true, -- leather boots
		[3355] = true, -- leather helmet
		[3559] = true, -- leather legs
		[3374] = true, -- legion helmet
		[3285] = true, -- long sword
		[3286] = true, -- mace
		[3282] = true, -- morning star
		[3316] = true, -- orcish axe
		[3357] = true, -- plate armor
		[3557] = true, -- plate legs
		[3410] = true, -- plate shield
		[3272] = true, -- rapier
		[3273] = true, -- sabre
		[3377] = true, -- scale armor
		[3294] = true, -- short sword
		[3293] = true, -- sickle
		[3462] = true, -- small axe
		[3375] = true, -- soldier helmet
		[3277] = true, -- spear
		[3351] = true, -- steel helmet
		[3409] = true, -- steel shield
		[3378] = true, -- studded armor
		[3336] = true, -- studded club
		[3376] = true, -- studded helmet
		[3362] = true, -- studded legs
		[3426] = true, -- studded shield
		[17824] = true, -- swampling club
		[3264] = true, -- sword
		[3298] = true, -- throwing knife
		[3265] = true, -- two handed sword
		[3367] = true, -- viking helmet
		[3431] = true, -- viking shield
		[3412] = true -- wooden shield
	},
	['port hope'] = {
		[3274] = true, -- axe
		[11511] = true, -- banana sash
		[3266] = true, -- battle axe
		[3305] = true, -- battle hammer
		[3413] = true, -- battle shield
		[3337] = true, -- bone club
		[3338] = true, -- bone sword
		[3350] = true, -- bow
		[3359] = true, -- brass armor
		[3354] = true, -- brass helmet
		[3372] = true, -- brass legs
		[3411] = true, -- brass shield
		[3283] = true, -- carlin sword
		[3358] = true, -- chain armor
		[3352] = true, -- chain helmet
		[3558] = true, -- chain legs
		[3407] = true, -- charmer's tiara
		[3270] = true, -- club
		[3562] = true, -- coat
		[3430] = true, -- copper shield
		[3556] = true, -- crocodile boots
		[3349] = true, -- crossbow
		[3304] = true, -- crowbar
		[3267] = true, -- dagger
		[3275] = true, -- double axe
		[3379] = true, -- doublet
		[3425] = true, -- dwarven shield
		[3406] = true, -- feather headdress
		[3269] = true, -- halberd
		[3268] = true, -- hand axe
		[3276] = true, -- hatchet
		[3405] = true, -- horseman helmet
		[3353] = true, -- iron helmet        
		[3561] = true, -- jacket
		[3300] = true, -- katana
		[11471] = true, -- kongra's shoulderpad
		[3361] = true, -- leather armor
		[3552] = true, -- leather boots
		[3355] = true, -- leather helmet
		[3559] = true, -- leather legs
		[3374] = true, -- legion helmet
		[3285] = true, -- long sword
		[3286] = true, -- mace
		[3282] = true, -- morning star
		[3316] = true, -- orcish axe
		[3357] = true, -- plate armor
		[3557] = true, -- plate legs
		[3410] = true, -- plate shield
		[3272] = true, -- rapier
		[3346] = true, -- ripper lance
		[3273] = true, -- sabre
		[3445] = true, -- salamander shield
		[3377] = true, -- scale armor
		[3444] = true, -- sentinel shield
		[3294] = true, -- short sword
		[3293] = true, -- sickle
		[3462] = true, -- small axe
		[3375] = true, -- soldier helmet
		[3351] = true, -- steel helmet
		[3409] = true, -- steel shield
		[3378] = true, -- studded armor
		[3336] = true, -- studded club
		[3376] = true, -- studded helmet
		[3362] = true, -- studded legs
		[3426] = true, -- studded shield
		[17824] = true, -- swampling club
		[3264] = true, -- sword
		[3345] = true, -- templar scytheblade
		[3298] = true, -- throwing knife
		[3265] = true, -- two handed sword
		[3367] = true, -- viking helmet
		[3431] = true, -- viking shield
		[3412] = true -- wooden shield
	},
	['liberty bay'] = {
		[3274] = true, -- axe
		[3266] = true, -- battle axe
		[3305] = true, -- battle hammer
		[3413] = true, -- battle shield
		[3337] = true, -- bone club
		[3338] = true, -- bone sword
		[3350] = true, -- bow
		[3359] = true, -- brass armor
		[3354] = true, -- brass helmet
		[3372] = true, -- brass legs
		[3411] = true, -- brass shield
		[3283] = true, -- carlin sword
		[3358] = true, -- chain armor
		[3352] = true, -- chain helmet
		[3558] = true, -- chain legs
		[3270] = true, -- club
		[3562] = true, -- coat
		[3430] = true, -- copper shield
		[3349] = true, -- crossbow
		[3304] = true, -- crowbar
		[3267] = true, -- dagger
		[3275] = true, -- double axe
		[3379] = true, -- doublet
		[3425] = true, -- dwarven shield
		[3269] = true, -- halberd
		[3268] = true, -- hand axe
		[3276] = true, -- hatchet
		[3353] = true, -- iron helmet        
		[3561] = true, -- jacket
		[3300] = true, -- katana
		[3361] = true, -- leather armor
		[3552] = true, -- leather boots
		[3355] = true, -- leather helmet
		[3559] = true, -- leather legs
		[3374] = true, -- legion helmet
		[3285] = true, -- long sword
		[3286] = true, -- mace
		[3282] = true, -- morning star
		[3316] = true, -- orcish axe
		[3357] = true, -- plate armor
		[3557] = true, -- plate legs
		[3410] = true, -- plate shield
		[3272] = true, -- rapier
		[3273] = true, -- sabre
		[3377] = true, -- scale armor
		[3294] = true, -- short sword
		[3293] = true, -- sickle
		[3462] = true, -- small axe
		[3375] = true, -- soldier helmet
		[3409] = true, -- steel shield
		[3378] = true, -- studded armor
		[3336] = true, -- studded club
		[3376] = true, -- studded helmet
		[3362] = true, -- studded legs
		[3426] = true, -- studded shield
		[17824] = true, -- swampling club
		[3264] = true, -- sword
		[3298] = true, -- throwing knife
		[3265] = true, -- two handed sword
		[3367] = true, -- viking helmet
		[3431] = true, -- viking shield
		[3412] = true -- wooden shield
	},
	['edron'] = {
		[3274] = true, -- axe
		[3317] = true, -- barbarian axe
		[3266] = true, -- battle axe
		[3305] = true, -- battle hammer
		[3413] = true, -- battle shield
		[3337] = true, -- bone club
		[3338] = true, -- bone sword
		[3350] = true, -- bow
		[3359] = true, -- brass armor
		[3354] = true, -- brass helmet
		[3372] = true, -- brass legs
		[3411] = true, -- brass shield
		[3283] = true, -- carlin sword
		[3358] = true, -- chain armor
		[3352] = true, -- chain helmet
		[3558] = true, -- chain legs
		[3311] = true, -- clerical mace
		[3270] = true, -- club
		[3562] = true, -- coat
		[3430] = true, -- copper shield
		[3349] = true, -- crossbow
		[3304] = true, -- crowbar
		[3267] = true, -- dagger
		[3275] = true, -- double axe
		[3379] = true, -- doublet
		[3425] = true, -- dwarven shield
		[3269] = true, -- halberd
		[3268] = true, -- hand axe
		[3276] = true, -- hatchet
		[3353] = true, -- iron helmet
		[3561] = true, -- jacket
		[3300] = true, -- katana
		[3361] = true, -- leather armor
		[3552] = true, -- leather boots
		[3355] = true, -- leather helmet
		[3559] = true, -- leather legs
		[3374] = true, -- legion helmet
		[3285] = true, -- long sword
		[3286] = true, -- mace
		[3282] = true, -- morning star
		[3316] = true, -- orcish axe
		[3357] = true, -- plate armor
		[3557] = true, -- plate legs
		[3410] = true, -- plate shield
		[3272] = true, -- rapier
		[3273] = true, -- sabre
		[3377] = true, -- scale armor
		[3294] = true, -- short sword
		[3293] = true, -- sickle
		[3462] = true, -- small axe
		[3375] = true, -- soldier helmet
		[3277] = true, -- spear
		[3351] = true, -- steel helmet
		[3409] = true, -- steel shield
		[3378] = true, -- studded armor
		[3336] = true, -- studded club
		[3376] = true, -- studded helmet
		[3362] = true, -- studded legs
		[3426] = true, -- studded shield
		[17824] = true, -- swampling club
		[3264] = true, -- sword
		[3298] = true, -- throwing knife
		[3265] = true, -- two handed sword
		[3367] = true, -- viking helmet
		[3412] = true -- wooden shield
	},
	['venore'] = {
		[3274] = 'romella', -- axe
		[3266] = 'romella', -- battle axe
		[3305] = 'romella', -- battle hammer
		[3337] = 'romella', -- bone club
		[3338] = 'romella', -- bone sword
		[3283] = 'romella', -- carlin sword
		[3270] = 'romella', -- club
		[3304] = 'romella', -- crowbar
		[3267] = 'romella', -- dagger
		[3275] = 'romella', -- double axe
		[3269] = 'romella', -- halberd
		[3268] = 'romella', -- hand axe
		[3276] = 'romella', -- hatchet
		[3300] = 'romella', -- katana
		[3285] = 'romella', -- long sword
		[3286] = 'romella', -- mace
		[3282] = 'romella', -- morning star
		[3316] = 'romella', -- orcish axe
		[3272] = 'romella', -- rapier
		[3273] = 'romella', -- sabre
		[3294] = 'romella', -- short sword
		[3462] = 'romella', -- small axe
		[3293] = 'romella', -- sickle
		[3336] = 'romella', -- studded club
		[17824] = 'romella', -- swampling club
		[3264] = 'romella', -- sword
		[3298] = 'romella', -- throwing knife
		[3265] = 'romella', -- two handed sword

		[3413] = 'yanni', -- battle shield
		[3359] = 'yanni', -- brass armor
		[3354] = 'yanni', -- brass helmet
		[3372] = 'yanni', -- brass legs
		[3411] = 'yanni', -- brass shield
		[3358] = 'yanni', -- chain armor
		[3352] = 'yanni', -- chain helmet
		[3558] = 'yanni', -- chain legs
		[3562] = 'yanni', -- coat
		[3430] = 'yanni', -- copper shield
		[3379] = 'yanni', -- doublet
		[3425] = 'yanni', -- dwarven shield
		[3353] = 'yanni', -- iron helmet
		[3561] = 'yanni', -- jacket
		[3361] = 'yanni', -- leather armor
		[3552] = 'yanni', -- leather boots
		[3355] = 'yanni', -- leather helmet
		[3559] = 'yanni', -- leather legs
		[3374] = 'yanni', -- legion helmet
		[3357] = 'yanni', -- plate armor
		[3557] = 'yanni', -- plate legs
		[3410] = 'yanni', -- plate shield
		[3377] = 'yanni', -- scale armor
		[3375] = 'yanni', -- soldier helmet
		[3409] = 'yanni', -- steel shield
		[3378] = 'yanni', -- studded armor
		[3376] = 'yanni', -- studded helmet
		[3362] = 'yanni', -- studded legs
		[3426] = 'yanni', -- studded shield
		[3367] = 'yanni', -- viking helmet
		[3412] = 'yanni' -- wooden shield
	},
	['darashia'] = {
		[3274] = 'habdel', -- axe
		[3266] = 'habdel', -- battle axe
		[3305] = 'habdel', -- battle hammer
		[3337] = 'habdel', -- bone club
		[3338] = 'habdel', -- bone sword
		[3283] = 'habdel', -- carlin sword
		[3270] = 'habdel', -- club
		[3304] = 'habdel', -- crowbar
		[3267] = 'habdel', -- dagger
		[3275] = 'habdel', -- double axe
		[3269] = 'habdel', -- halberd
		[3268] = 'habdel', -- hand axe
		[3276] = 'habdel', -- hatchet
		[3300] = 'habdel', -- katana
		[3285] = 'habdel', -- long sword
		[3286] = 'habdel', -- mace
		[3282] = 'habdel', -- morning star
		[3316] = 'habdel', -- orcish axe
		[3272] = 'habdel', -- rapier
		[3273] = 'habdel', -- sabre
		[3294] = 'habdel', -- short sword
		[3462] = 'habdel', -- small axe
		[3293] = 'habdel', -- sickle
		[3336] = 'habdel', -- studded club
		[17824] = 'habdel', -- swampling club
		[3264] = 'habdel', -- sword
		[3298] = 'habdel', -- throwing knife
		[3265] = 'habdel', -- two handed sword

		[3413] = 'azil', -- battle shield
		[3359] = 'azil', -- brass armor
		[3354] = 'azil', -- brass helmet
		[3372] = 'azil', -- brass legs
		[3411] = 'azil', -- brass shield
		[3358] = 'azil', -- chain armor
		[3352] = 'azil', -- chain helmet
		[3558] = 'azil', -- chain legs
		[3562] = 'azil', -- coat
		[3430] = 'azil', -- copper shield
		[3379] = 'azil', -- doublet
		[3425] = 'azil', -- dwarven shield
		[3353] = 'azil', -- iron helmet
		[3561] = 'azil', -- jacket
		[3361] = 'azil', -- leather armor
		[3552] = 'azil', -- leather boots
		[3355] = 'azil', -- leather helmet
		[3559] = 'azil', -- leather legs
		[3374] = 'azil', -- legion helmet
		[3357] = 'azil', -- plate armor
		[3557] = 'azil', -- plate legs
		[3410] = 'azil', -- plate shield
		[3377] = 'azil', -- scale armor
		[3375] = 'azil', -- soldier helmet
		[3409] = 'azil', -- steel shield
		[3378] = 'azil', -- studded armor
		[3376] = 'azil', -- studded helmet
		[3362] = 'azil', -- studded legs
		[3426] = 'azil', -- studded shield
		[3367] = 'azil', -- viking helmet
		[3431] = 'azil', -- viking helmet
		[3412] = 'azil' -- wooden shield
	},
	['ankrahmun'] = {
		[3274] = true, --axe
		[3266] = true, --battle axe
		[3305] = true, --battle hammer
		[3413] = true, --battle shield
		[3337] = true, --bone club
		[3338] = true, --bone sword
		[3359] = true, --brass armor
		[3354] = true, --brass helmet
		[3372] = true, --brass legs
		[3411] = true, --brass shield
		[3283] = true, --carlin sword
		[3358] = true, --chain armor
		[3352] = true, --chain helmet
		[3558] = true, --chain legs
		[3270] = true, --club
		[3562] = true, --coat
		[3430] = true, --copper shield
		[3304] = true, --crowbar
		[3267] = true, --dagger
		[3275] = true, --double axe
		[3379] = true, --doublet
		[3425] = true, --dwarven shield
		[3280] = true, --fire sword
		[3269] = true, --halberd
		[3268] = true, --hand axe
		[3276] = true, --hatchet
		[3353] = true, --iron helmet
		[3561] = true, --jacket
		[3300] = true, --katana
		[3361] = true, --leather armor
		[3552] = true, --leather boots
		[3355] = true, --leather helmet
		[3559] = true, --leather legs
		[3374] = true, --legion helmet
		[3285] = true, --longsword
		[3286] = true, --mace
		[3282] = true, --morning star
		[3316] = true, --orcish axe
		[3357] = true, --plate armor
		[3557] = true, --plate legs
		[3410] = true, --plate shield
		[3272] = true, --rapier
		[3273] = true, --sabre
		[3377] = true, --scale armor
		[3294] = true, --short sword
		[3293] = true, --sickle
		[3462] = true, --small axe
		[3375] = true, --soldier helmet
		[3351] = true, --steel helmet
		[3409] = true, --steel shield
		[3378] = true, --studded armor
		[3336] = true, --studded club
		[3376] = true, --studded helmet
		[3362] = true, --studded legs
		[3426] = true, --studded shield
		[17824] = true, --swampling club
		[3264] = true, --sword
		[3298] = true, --throwing knife
		[3265] = true, --two handed sword
		[3367] = true, --viking helmet
		[3431] = true, --viking shield
		[3412] = true, --wooden shield
		[3287] = true --throwing star
	}
}

local TRAVEL_ROUTES = {
	['thais~venore'] = {
		cost = 170,
		transcript = {
			['Captain Bluebear'] = {'hi', 'venore', 'yes'}
		}
	},
	['thais~edron'] = {
		cost = 160,
		transcript = {
			['Captain Bluebear'] = {'hi', 'edron', 'yes'}
		}
	},
	['thais~carlin'] = {
		cost = 110,
		transcript = {
			['Captain Bluebear'] = {'hi', 'carlin', 'yes'}
		}
	},
	['thais~ab\'dendriel'] = {
		cost = 130,
		transcript = {
			['Captain Bluebear'] = {'hi', 'ab\'dendriel', 'yes'}
		}
	},
	['thais~port hope'] = {
		cost = 160,
		transcript = {
			['Captain Bluebear'] = {'hi', 'port hope', 'yes'}
		}
	},
	['thais~liberty bay'] = {
		cost = 330,
		transcript = {
			['Captain Bluebear'] = {'hi', 'edron', 'yes'},
			['Captain Seahorse'] = {'hi', 'thais', 'yes'}
		}
	},
	['thais~svargrond'] = {
		cost = 180,
		transcript = {
			['Captain Bluebear'] = {'hi', 'svargrond', 'yes'}
		}
	},
	['thais~yalahar'] = {
		cost = 200,
		transcript = {
			['Captain Bluebear'] = {'hi', 'yalahar', 'yes'}
		}
	},
	['thais~roshamuul'] = {
		cost = 210,
		transcript = {
			['Captain Bluebear'] = {'hi', 'roshamuul', 'yes'}
		}
	},
	['thais~oramond'] = {
		cost = 150,
		transcript = {
			['Captain Bluebear'] = {'hi', 'oramond', 'yes'}
		}
	},
	['thais~darashia'] = {
		cost = 240,
		transcript = {
			['Captain Bluebear'] = {'hi', 'port hope', 'yes'},
			['Charles'] = {'hi', 'darashia', 'yes'}
		}
	},
	['thais~ankrahmun'] = {
		cost = 270,
		transcript = {
			['Captain Bluebear'] = {'hi', 'port hope', 'yes'},
			['Charles'] = {'hi', 'ankrahmun', 'yes'}
		}
	},
	['thais~gray island'] = {
		cost = 320,
		transcript = {
			['Captain Bluebear'] = {'hi', 'edron', 'yes'},
			['Captain Seahorse'] = {'hi', 'gray island', 'yes'}
		}
	},
	['venore~thais'] = {
		cost = 170,
		transcript = {
			['Captain Fearless'] = {'hi', 'thais', 'yes'}
		}
	},
	['venore~carlin'] = {
		cost = 130,
		transcript = {
			['Captain Fearless'] = {'hi', 'carlin', 'yes'}
		}
	},
	['venore~ab\'dendriel'] = {
		cost = 90,
		transcript = {
			['Captain Fearless'] = {'hi', 'ab\'dendriel', 'yes'}
		}
	},
	['venore~port hope'] = {
		cost = 160,
		transcript = {
			['Captain Fearless'] = {'hi', 'port hope', 'yes'}
		}
	},
	['venore~edron'] = {
		cost = 40,
		transcript = {
			['Captain Fearless'] = {'hi', 'edron', 'yes'}
		}
	},
	['venore~darashia'] = {
		cost = 340,
		transcript = {
			['Captain Fearless'] = {'hi', 'port hope', 'yes'},
			['Charles'] = {'hi', 'darashia', 'yes'}
		}
	},
	['venore~liberty bay'] = {
		cost = 180,
		transcript = {
			['Captain Fearless'] = {'hi', 'liberty bay', 'yes'}
		}
	},
	['venore~svargrond'] = {
		cost = 150,
		transcript = {
			['Captain Fearless'] = {'hi', 'svargrond', 'yes'}
		}
	},
	['venore~yalahar'] = {
		cost = 185,
		transcript = {
			['Captain Fearless'] = {'hi', 'yalahar', 'yes'}
		}
	},
	['venore~gray island'] = {
		cost = 160,
		transcript = {
			['Captain Fearless'] = {'hi', 'gray island', 'yes'}
		}
	},
	['venore~oramond'] = {
		cost = 320,
		transcript = {
			['Captain Fearless'] = {'hi', 'thais', 'yes'},
			['Captain Bluebear'] = {'hi', 'oramond', 'yes'}
		}
	},
	['venore~roshamuul'] = {
		cost = 380,
		transcript = {
			['Captain Fearless'] = {'hi', 'thais', 'yes'},
			['Captain Bluebear'] = {'hi', 'roshamuul', 'yes'}
		}
	},
	['venore~ankrahmun'] = {
		cost = 150,
		transcript = {
			['Captain Fearless'] = {'hi', 'ankrahmun', 'yes'}
		}
	},
	['darashia~edron'] = {
		route = 'carpet',
		cost = 40,
		transcript = {
			['Chemar'] = {'hi', 'edron', 'yes'}
		}
	},
	['darashia~svargrond'] = {
		route = 'carpet',
		cost = 60,
		transcript = {
			['Chemar'] = {'hi', 'svargrond', 'yes'}
		}
	},
	['darashia~ankrahmun'] = {
		cost = 100,
		transcript = {
			['Petros'] = {'hi', 'ankrahmun', 'yes'}
		}
	},
	['darashia~liberty bay'] = {
		cost = 200,
		transcript = {
			['Petros'] = {'hi', 'liberty bay', 'yes'}
		}
	},
	['darashia~port hope'] = {
		cost = 180,
		transcript = {
			['Petros'] = {'hi', 'port hope', 'yes'}
		}
	},
	['darashia~venore'] = {
		cost = 60,
		transcript = {
			['Petros'] = {'hi', 'venore', 'yes'}
		}
	},
	['darashia~yalahar'] = {
		cost = 210,
		transcript = {
			['Petros'] = {'hi', 'yalahar', 'yes'}
		}
	},
	['darashia~thais'] = {
		cost = 230,
		transcript = {
			['Petros'] = {'hi', 'venore', 'yes'},
			['Captain Fearless'] = {'hi', 'thais', 'yes'}
		}
	},
	['darashia~roshamuul'] = {
		cost = 440,
		transcript = {
			['Petros'] = {'hi', 'venore', 'yes'},
			['Captain Fearless'] = {'hi', 'thais', 'yes'},
			['Captain Bluebear'] = {'hi', 'roshamuul', 'yes'}
		}
	},
	['darashia~oramond'] = {
		cost = 380,
		transcript = {
			['Petros'] = {'hi', 'venore', 'yes'},
			['Captain Fearless'] = {'hi', 'thais', 'yes'},
			['Captain Bluebear'] = {'hi', 'oramond', 'yes'}
		}
	},
	['darashia~ab\'dendriel'] = {
		cost = 150,
		transcript = {
			['Petros'] = {'hi', 'venore', 'yes'},
			['Captain Fearless'] = {'hi', 'ab\'dendriel', 'yes'}
		}
	},
	['darashia~carlin'] = {
		cost = 190,
		transcript = {
			['Petros'] = {'hi', 'venore', 'yes'},
			['Captain Fearless'] = {'hi', 'carlin', 'yes'}
		}
	},
	['darashia~gray island'] = {
		cost = 160,
		transcript = {
			['Petros'] = {'hi', 'gray island', 'yes'}
		}
	},
	['svargrond~darashia'] = {
		route = 'carpet',
		cost = 60,
		transcript = {
			['Iyad'] = {'hi', 'darashia', 'yes'}
		}
	},
	['svargrond~edron'] = {
		route = 'carpet',
		cost = 60,
		transcript = {
			['Iyad'] = {'hi', 'edron', 'yes'}
		}
	},
	['svargrond~venore'] = {
		cost = 150,
		transcript = {
			['Captain Breezelda'] = {'hi', 'venore', 'yes'}
		}
	},
	['svargrond~thais'] = {
		cost = 180,
		transcript = {
			['Captain Breezelda'] = {'hi', 'thais', 'yes'}
		}
	},
	['svargrond~carlin'] = {
		cost = 110,
		transcript = {
			['Captain Breezelda'] = {'hi', 'carlin', 'yes'}
		}
	},
	['svargrond~yalahar'] = {
		cost = 335,
		transcript = {
			['Captain Breezelda'] = {'hi', 'venore', 'yes'},
			['Captain Fearless'] = {'hi', 'yalahar', 'yes'}
		}
	},
	['svargrond~ab\'dendriel'] = {
		cost = 240,
		transcript = {
			['Captain Breezelda'] = {'hi', 'venore', 'yes'},
			['Captain Fearless'] = {'hi', 'ab\'dendriel', 'yes'}
		}
	},
	['svargrond~ankrahmun'] = {
		cost = 300,
		transcript = {
			['Captain Breezelda'] = {'hi', 'venore', 'yes'},
			['Captain Fearless'] = {'hi', 'ankrahmun', 'yes'}
		}
	},
	['svargrond~gray island'] = {
		cost = 310,
		transcript = {
			['Captain Breezelda'] = {'hi', 'venore', 'yes'},
			['Captain Fearless'] = {'hi', 'gray island', 'yes'}
		}
	},
	['svargrond~liberty bay'] = {
		cost = 330,
		transcript = {
			['Captain Breezelda'] = {'hi', 'venore', 'yes'},
			['Captain Fearless'] = {'hi', 'liberty bay', 'yes'}
		}
	},
	['svargrond~port hope'] = {
		cost = 310,
		transcript = {
			['Captain Breezelda'] = {'hi', 'venore', 'yes'},
			['Captain Fearless'] = {'hi', 'port hope', 'yes'}
		}
	},
	['svargrond~roshamuul'] = {
		cost = 390,
		transcript = {
			['Captain Breezelda'] = {'hi', 'thais', 'yes'},
			['Captain Bluebear'] = {'hi', 'roshamuul', 'yes'}
		}
	},
	['svargrond~oramond'] = {
		cost = 330,
		transcript = {
			['Captain Breezelda'] = {'hi', 'thais', 'yes'},
			['Captain Bluebear'] = {'hi', 'oramond', 'yes'}
		}
	},
	['edron~thais'] = {
		cost = 160,
		transcript = {
			['Captain Seahorse'] = {'hi', 'thais', 'yes'}
		}
	},
	['edron~ab\'dendriel'] = {
		cost = 70,
		transcript = {
			['Captain Seahorse'] = {'hi', 'ab\'dendriel', 'yes'}
		}
	},
	['edron~ankrahmun'] = {
		cost = 160,
		transcript = {
			['Captain Seahorse'] = {'hi', 'ankrahmun', 'yes'}
		}
	},
	['edron~carlin'] = {
		cost = 110,
		transcript = {
			['Captain Seahorse'] = {'hi', 'carlin', 'yes'}
		}
	},
	['edron~darashia'] = {
		route = 'carpet',
		cost = 40,
		transcript = {
			['Pino'] = {'hi', 'darashia', 'yes'}
		}
	},
	['edron~gray island'] = {
		cost = 160,
		transcript = {
			['Captain Seahorse'] = {'hi', 'gray island', 'yes'}
		}
	},
	['edron~liberty bay'] = {
		cost = 170,
		transcript = {
			['Captain Seahorse'] = {'hi', 'liberty bay', 'yes'}
		}
	},
	['edron~port hope'] = {
		cost = 150,
		transcript = {
			['Captain Seahorse'] = {'hi', 'port hope', 'yes'}
		}
	},
	['edron~roshamuul'] = {
		cost = 370,
		transcript = {
			['Captain Seahorse'] = {'hi', 'thais', 'yes'},
			['Captain Bluebear'] = {'hi', 'roshamuul', 'yes'}
		}
	},
	['edron~oramond'] = {
		cost = 310,
		transcript = {
			['Captain Seahorse'] = {'hi', 'thais', 'yes'},
			['Captain Bluebear'] = {'hi', 'oramond', 'yes'}
		}
	},
	['edron~svargrond'] = {
		route = 'carpet',
		cost = 60,
		transcript = {
			['Pino'] = {'hi', 'svargrond', 'yes'}
		}
	},
	['edron~venore'] = {
		cost = 190,
		transcript = {
			['Captain Seahorse'] = {'hi', 'venore', 'yes'},
			['Captain Fearless'] = {'hi', 'svargrond', 'yes'}
		}
	},
	['edron~yalahar'] = {
		cost = 225,
		transcript = {
			['Captain Seahorse'] = {'hi', 'venore', 'yes'},
			['Captain Fearless'] = {'hi', 'yalahar', 'yes'}
		}
	},
	['liberty bay~edron'] = {
		cost = 170,
		transcript = {
			['Jack Fate'] = {'hi', 'edron', 'yes'}
		}
	},
	['liberty bay~thais'] = {
		cost = 180,
		transcript = {
			['Jack Fate'] = {'hi', 'thais', 'yes'}
		}
	},
	['liberty bay~venore'] = {
		cost = 180,
		transcript = {
			['Jack Fate'] = {'hi', 'venore', 'yes'}
		}
	},
	['liberty bay~darashia'] = {
		cost = 200,
		transcript = {
			['Jack Fate'] = {'hi', 'darashia', 'yes'}
		}
	},
	['liberty bay~ankrahmun'] = {
		cost = 90,
		transcript = {
			['Jack Fate'] = {'hi', 'ankrahmun', 'yes'}
		}
	},
	['liberty bay~yalahar'] = {
		cost = 275,
		transcript = {
			['Jack Fate'] = {'hi', 'yalahar', 'yes'}
		}
	},
	['liberty bay~port hope'] = {
		cost = 50,
		transcript = {
			['Jack Fate'] = {'hi', 'port hope', 'yes'}
		}
	},
	['liberty bay~svargrond'] = {
		cost = 330,
		transcript = {
			['Jack Fate'] = {'hi', 'thais', 'yes'},
			['Captain Fearless'] = {'hi', 'svargrond', 'yes'}
		}
	},
	['liberty bay~ab\'dendriel'] = {
		cost = 270,
		transcript = {
			['Jack Fate'] = {'hi', 'venore', 'yes'},
			['Captain Fearless'] = {'hi', 'ab\'dendriel', 'yes'}
		}
	},
	['liberty bay~carlin'] = {
		cost = 290,
		transcript = {
			['Jack Fate'] = {'hi', 'thais', 'yes'},
			['Captain Bluebear'] = {'hi', 'carlin', 'yes'}
		}
	},
	['liberty bay~gray island'] = {
		cost = 330,
		transcript = {
			['Jack Fate'] = {'hi', 'edron', 'yes'},
			['Captain Seahorse'] = {'hi', 'gray island', 'yes'}
		}
	},
	['liberty bay~roshamuul'] = {
		cost = 320,
		transcript = {
			['Jack Fate'] = {'hi', 'thais', 'yes'},
			['Captain Bluebear'] = {'hi', 'roshamuul', 'yes'}
		}
	},
	['liberty bay~oramond'] = {
		cost = 260,
		transcript = {
			['Jack Fate'] = {'hi', 'thais', 'yes'},
			['Captain Bluebear'] = {'hi', 'oramond', 'yes'}
		}
	},
	['port hope~ab\'dendriel'] = {
		cost = 250,
		transcript = {
			['Charles'] = {'hi', 'venore', 'yes'},
			['Captain Fearless'] = {'hi', 'ab\'dendriel', 'yes'}
		}
	},
	['port hope~svargrond'] = {
		cost = 310,
		transcript = {
			['Charles'] = {'hi', 'venore', 'yes'},
			['Captain Fearless'] = {'hi', 'svargrond', 'yes'}
		}
	},
	['port hope~roshamuul'] = {
		cost = 370,
		transcript = {
			['Charles'] = {'hi', 'thais', 'yes'},
			['Captain Bluebear'] = {'hi', 'roshamuul', 'yes'}
		}
	},
	['port hope~oramond'] = {
		cost = 310,
		transcript = {
			['Charles'] = {'hi', 'thais', 'yes'},
			['Captain Bluebear'] = {'hi', 'oramond', 'yes'}
		}
	},
	['port hope~carlin'] = {
		cost = 260,
		transcript = {
			['Charles'] = {'hi', 'edron', 'yes'},
			['Captain Seahorse'] = {'hi', 'carlin', 'yes'}
		}
	},
	['port hope~gray island'] = {
		cost = 210,
		transcript = {
			['Charles'] = {'hi', 'edron', 'yes'},
			['Captain Seahorse'] = {'hi', 'gray island', 'yes'}
		}
	},
	['port hope~ankrahmun'] = {
		cost = 110,
		transcript = {
			['Charles'] = {'hi', 'ankrahmun', 'yes'}
		}
	},
	['port hope~darashia'] = {
		cost = 180,
		transcript = {
			['Charles'] = {'hi', 'darashia', 'yes'}
		}
	},
	['port hope~edron'] = {
		cost = 150,
		transcript = {
			['Charles'] = {'hi', 'edron', 'yes'}
		}
	},
	['port hope~liberty bay'] = {
		cost = 50,
		transcript = {
			['Charles'] = {'hi', 'liberty bay', 'yes'}
		}
	},
	['port hope~thais'] = {
		cost = 160,
		transcript = {
			['Charles'] = {'hi', 'thais', 'yes'}
		}
	},
	['port hope~venore'] = {
		cost = 160,
		transcript = {
			['Charles'] = {'hi', 'venore', 'yes'}
		}
	},
	['port hope~yalahar'] = {
		cost = 260,
		transcript = {
			['Charles'] = {'hi', 'yalahar', 'yes'}
		}
	}
}

local MONSTER_LOOT = {
	["Acid Blob"] = {9054},
	["Acolyte of Darkness"] = {9615},
	["Acolyte of the Cult"] = {2828, 3032, 3052, 3065, 3085, 3282, 5810, 6087, 9639, 11455, 11492, 11652},
	["Adept of the Cult"] = {2828, 3030, 3053, 3054, 3067, 3311, 3566, 5810, 6087, 7424, 7426, 9639, 11455, 11492, 11652},
	["Amazon"] = {2920, 3008, 3030, 3114, 3267, 3273, 3602, 11443, 11444},
	["Ancient Scarab"] = {236, 830, 3018, 3025, 3032, 3033, 3042, 3046, 3328, 3357, 3440, 9631},
	["Apprentice Sheng"] = {2920, 3003, 3046, 3291, 3355, 3457, 3559, 3595, 4000, 5878},
	["Arachir the Ancient One"] = {236, 3098, 3114, 3434, 8192, 11449},
	["Armadile"] = {236, 237, 238, 239, 268, 813, 3053, 3428, 7413, 7428, 8050, 11447, 12600, 16122, 16127, 16138, 16142, 16143},
	["Arthei"] = {236, 3098, 11449},
	["Ashmunrah"] = {238, 3017, 3023, 3048, 3332, 3381, 10290},
	["Askarak Demon"] = {236, 237, 812, 2995, 3032, 3051, 3725, 5904, 7368, 7440, 8084},
	["Askarak Lord"] = {236, 237, 811, 3032, 3051, 3725, 5904, 7368, 7419, 7440, 8084},
	["Askarak Prince"] = {236, 237, 811, 3032, 3049, 3281, 3725, 5904, 7440, 8084, 12541},
	["Assassin"] = {2920, 3028, 3287, 3291, 3292, 3351, 3404, 3405, 3409, 3410, 3413, 7366},
	["Azure Frog"] = {3492},
	["Badger"] = {903, 8017, 10296},
	["Bandit"] = {3274, 3286, 3352, 3353, 3359, 3411, 3559, 3596},
	["Bane Bringer"] = {11982},
	["Bane Lord"] = {11982, 12519, 12548, 12549, 12550, 12802},
	["Bane of Light"] = {9615},
	["Banshee"] = {237, 811, 2917, 2949, 3004, 3007, 3017, 3026, 3027, 3054, 3059, 3061, 3081, 3098, 3122, 3299, 3566, 3567, 3568, 10420, 11446, 12320},
	["Barbaria"] = {2839, 3347, 3358, 7343, 7463},
	["Barbarian Bloodwalker"] = {266, 2914, 3266, 3269, 3344, 3352, 3358, 5911, 7290, 7457},
	["Barbarian Brutetamer"] = {268, 2839, 3289, 3347, 3358, 3597, 7343, 7379, 7457, 7463, 7464},
	["Barbarian Headsplitter"] = {266, 2920, 3052, 3114, 3291, 3354, 3367, 3377, 5913, 7457, 7461},
	["Barbarian Skullhunter"] = {266, 2920, 3052, 3114, 3291, 3354, 3367, 3377, 5913, 7449, 7457, 7462},
	["Bat"] = {5894},
	["Battlemaster Zunzu"] = {3032, 10289, 10384, 10386, 10387, 10413, 10414},
	["Bear"] = {5896, 5902},
	["Behemoth"] = {239, 2893, 3008, 3033, 3058, 3116, 3265, 3275, 3281, 3304, 3342, 3357, 3383, 3456, 3554, 5893, 5930, 7368, 7396, 7413, 11447},
	["Betrayed Wraith"] = {238, 3028, 3057, 3450, 5021, 5741, 5799, 5944, 6299, 6499, 6558, 7368, 7386, 7416, 7643, 10316},
	["Bibby Bloodbath"] = {266, 268, 817, 3049, 3265, 3281, 3287, 3316, 3383, 3391, 3557, 3578, 7395, 7412},
	["Big Boss Trolliver"] = {3054},
	["Black Knight"] = {822, 2995, 3003, 3016, 3079, 3265, 3269, 3275, 3277, 3302, 3305, 3318, 3351, 3357, 3369, 3370, 3371, 3372, 3383, 3384, 3602},
	["Black Sheep"] = {11448},
	["Blazing Fire Elemental"] = {763, 941, 9636, 12600},
	["Blightwalker"] = {238, 281, 647, 811, 812, 3057, 3063, 3067, 3083, 3147, 3306, 3324, 3453, 3605, 5944, 6299, 6499, 7368, 7643, 9058, 9688},
	["Blistering Fire Elemental"] = {941, 3030, 8093, 9636, 12600},
	["Blood Crab"] = {3026, 3358, 3372, 3578, 9633},
	["Blood Hand"] = {237, 3069, 3079, 3574, 5909, 5911, 7456, 8072, 8073, 10320, 18925, 18926, 18928, 18929, 18930},
	["Blood Priest"] = {237, 3030, 3039, 3079, 3324, 3574, 5909, 5911, 8074, 8082, 10320, 18925, 18926, 18928, 18929, 18930},
	["Blue Djinn"] = {268, 2829, 2933, 3029, 3574, 3595, 3659, 5912, 7378, 11456},
	["Boar"] = {12310},
	["Bog Raider"] = {239, 3557, 7642, 7643, 8044, 8063, 8084, 9667},
	["Bolfrim"] = {6571, 6572, 6578, 14672},
	["Bonebeast"] = {266, 3114, 3115, 3337, 3357, 3441, 3732, 5925, 10244, 10277},
	["Bonelord"] = {268, 3059, 3065, 3265, 3282, 3285, 3409, 3418, 5898, 11512},
	["Bones"] = {3029, 3061, 3366, 5741, 5944, 6299, 6499, 6570, 6571},
	["Boogey"] = {9378, 9379, 9384, 9385},
	["Boreth"] = {236, 3434, 11449},
	["Braindeath"] = {3059, 3311, 3338, 3408, 3409, 3418, 5898, 7364, 7407, 7452, 9663},
	["Bretzecutioner"] = {238, 239, 281, 3008, 3028, 3029, 3033, 3281, 3383, 3554, 5741, 6299, 6499, 7368, 7419, 7427, 7452, 7642, 10298},
	["Bride of Night"] = {9615},
	["Brimstone Bug"] = {236, 237, 3032, 3049, 3055, 5904, 9640, 10305, 10315, 11702, 11703},
	["Bruise Payne"] = {3027, 3033, 3051, 3429, 3736, 5894, 7386, 9103, 9662},
	["Brutus Bloodbeard"] = {239, 3114, 3357, 3370, 6099},
	["Bug"] = {3590},
	["Cake Golem"] = {12143},
	["Calamary"] = {3581},
	["Captain Jones"] = {3049},
	["Carniphila"] = {647, 3597, 3728, 3738, 3740, 10300, 12311},
	["Carrion Worm"] = {3492, 10275, 12600},
	["Cave Rat"] = {3492, 3598, 3607},
	["Centipede"] = {3299, 10301},
	["Chakoya Toolshaper"] = {3286, 3441, 3456, 3578, 3580, 7158, 7159, 7381, 7441},
	["Chakoya Tribewarden"] = {3294, 3441, 3578, 3580, 7158, 7159, 7381},
	["Chakoya Windcaller"] = {3354, 3441, 3578, 7158},
	["Charged Energy Elemental"] = {761, 945},
	["Chayenne"] = {281, 6571, 14681, 14682},
	["Chicken"] = {3492, 3606, 5890, 6541, 6542, 6543, 6544, 6545},
	["Chocking Fear"] = {238, 813, 3051, 3052, 3098, 5911, 5913, 5914, 7642, 7643, 8074, 16121, 16123, 16124, 20062, 20202, 20206},
	["Chopper"] = {238, 239, 3010, 3027, 3037, 9057, 14080, 14081, 14083, 14753},
	["Clay Guardian"] = {774, 1781, 3147, 9057, 10305, 10422},
	["Cliff Strider"] = {238, 3026, 3027, 3039, 3041, 3281, 3332, 3371, 3381, 3391, 3554, 5880, 5904, 5944, 7437, 7452, 7643, 9028, 9067, 10310, 16096, 16118, 16119, 16124, 16125, 16133, 16134, 16135, 16141, 16160, 16163},
	["Cobra"] = {9634},
	["Cockroach"] = {7882},
	["Coral Frog"] = {3492},
	["Corym Charlatan"] = {3607, 17809, 17810, 17812, 17813, 17817, 17818, 17819, 17820, 17821, 17846},
	["Corym Skirmisher"] = {3607, 17809, 17810, 17812, 17813, 17817, 17818, 17819, 17820, 17821, 17825, 17846},
	["Corym Vanguard"] = {3607, 17809, 17810, 17812, 17813, 17817, 17818, 17819, 17820, 17821, 17825, 17846, 17859},
	["Count Tofifti"] = {6571, 14681},
	["Countess Sorrow"] = {3049, 3084, 3123, 3312, 3557, 3567, 5944, 6499, 6536},
	["Crab"] = {3578, 10272},
	["Craban"] = {3155, 6571, 8759, 9642, 11609},
	["Crawler"] = {238, 239, 3037, 3279, 8084, 9057, 14079, 14083, 14087},
	["Crazed Beggar"] = {2389, 2950, 3097, 3122, 3459, 3470, 3473, 3601, 3658, 3738, 5552, 6091, 8894},
	["Crimson Frog"] = {3492},
	["Crocodile"] = {3556, 10279},
	["Crustacea Gigantica"] = {236, 237, 12317},
	["Crypt Defiler"] = {3274, 3286, 3353, 3359, 3409, 7533, 8010, 11456, 11492},
	["Crypt Shambler"] = {3028, 3112, 3115, 3265, 3287, 3338, 3353, 3441, 3492, 10283},
	["Crystal Crusher"] = {15793, 16122, 16123, 16124, 16138},
	["Crystal Spider"] = {237, 829, 3007, 3008, 3053, 3055, 3351, 3357, 3370, 3371, 5801, 5879, 7290, 7364, 7437, 7441, 7449},
	["Crystal Wolf"] = {762, 3067, 5897, 8050},
	["Cublarc the Plunderer"] = {3316, 3350, 8029, 10196, 10407, 10421, 11479},
	["Cyclops Drone"] = {236, 3093, 3269, 3294, 3384, 3410, 3413, 7398, 9657},
	["Cyclops Smith"] = {236, 3093, 3266, 3275, 3305, 3330, 3384, 3410, 3413, 7398, 7452, 9657},
	["Cyclops"] = {266, 3012, 3093, 3269, 3294, 3384, 3410, 3413, 7398, 9657},
	["Damaged Worker Golem"] = {953, 3091, 5880, 8894, 9655},
	["Dark Apprentice"] = {266, 268, 3072, 3075, 3147, 5934, 12308},
	["Dark Magician"] = {236, 237, 266, 268, 678, 3069, 3147, 12308},
	["Dark Monk"] = {268, 347, 2885, 2914, 3050, 3061, 3077, 3289, 3551, 3600, 9646, 10303, 11492, 11493},
	["Dark Torturer"] = {238, 239, 3364, 3461, 3554, 5021, 5479, 5801, 5944, 6299, 6499, 6558, 7368, 7388, 7412, 9058},
	["Deadeye Devious"] = {239, 3028, 3114, 3267, 3357, 3370, 5926, 6102},
	["Death Blob"] = {9055},
	["Death Priest"] = {266, 268, 3026, 3042, 3059, 3098, 5021, 12482},
	["Deathbine"] = {647, 813, 814, 3032, 3728, 3740, 5014, 8084, 10300, 12320},
	["Deathstrike"] = {16136, 16155, 16160, 16161, 16162, 16163, 16164, 16175},
	["Deepling Brawler"] = {3578, 5895, 12730, 14017},
	["Deepling Elite"] = {238, 239, 3032, 3052, 5895, 12683, 12730, 14012, 14013, 14040, 14041, 14042, 14085, 14252},
	["Deepling Guard"] = {238, 239, 3029, 12683, 12730, 14010, 14011, 14043, 14044, 14142, 14247, 14248, 14250},
	["Deepling Master Librarian"] = {3029, 3052, 3578, 5895, 12730, 13987, 13990, 14008, 14009, 14085, 14247},
	["Deepling Scout"] = {3032, 3052, 3347, 5895, 8895, 9016, 12683, 12730},
	["Deepling Spellsinger"] = {3029, 3052, 3578, 5895, 12730, 13987, 13990, 14008, 14009, 14085, 14247},
	["Deepling Tyrant"] = {238, 239, 3029, 12683, 12730, 14010, 14011, 14043, 14044, 14142, 14247, 14248, 14250},
	["Deepling Warrior"] = {238, 239, 3032, 3052, 5895, 12683, 12730, 14012, 14013, 14040, 14041, 14042, 14085, 14252},
	["Deepling Worker"] = {3032, 3578, 5895, 12683, 12730, 14017},
	["Deer"] = {10297},
	["Defiler"] = {3028, 3030, 3032, 3034, 3037, 3038, 3039, 3041, 5944, 6299, 6499, 9054, 9055},
	["Delany"] = {3598, 6571, 14671},
	["Demodras"] = {239, 2842, 2903, 3029, 3051, 3280, 3386, 3450, 3732, 5791, 5919, 5948, 7365},
	["Demon Outcast"] = {238, 3028, 3029, 3030, 3032, 3048, 3049, 3055, 3098, 3281, 3284, 3356, 3381, 3391, 3419, 3420, 3731, 5906, 5911, 7368, 7643, 9057, 20062},
	["Demon Skeleton"] = {266, 268, 2920, 3027, 3030, 3062, 3078, 3287, 3305, 3353, 3413, 3415, 9647},
	["Demon"] = {238, 2848, 3030, 3032, 3033, 3034, 3039, 3048, 3049, 3055, 3060, 3063, 3098, 3281, 3284, 3306, 3320, 3356, 3364, 3366, 3414, 3420, 3731, 5954, 6499, 7368, 7382, 7393, 7642, 7643, 9057},
	["Denson Larika"] = {281, 3032, 5875, 5910, 11634},
	["Desperate White Deer"] = {12544, 12545},
	["Destroyer"] = {239, 3008, 3033, 3062, 3281, 3304, 3357, 3383, 3449, 3456, 3554, 5741, 5944, 6299, 6499, 7419, 7427, 10298},
	["Dharalion"] = {238, 3037, 3082, 3103, 3147, 3593, 5922, 9635, 11465},
	["Diabolic Imp"] = {826, 827, 3033, 3049, 3069, 3147, 3275, 3307, 3415, 3451, 3471, 5944, 6299, 6499, 6558},
	["Diamond Servant"] = {236, 237, 816, 3037, 3048, 3061, 3073, 5944, 7428, 7440, 8050, 8775, 9063, 9304, 9655, 12601},
	["Diblis the Fair"] = {236, 3098, 3114, 3434, 8075, 8192, 11449},
	["Dipthrah"] = {238, 3029, 3041, 3051, 3062, 3077, 3241, 3324, 3334, 10290},
	["Dirtbeard"] = {9374, 9375, 9382, 9401},
	["Doctor Perhaps"] = {9372, 9373, 9383, 9399},
	["Doomsday Cultist"] = {9615},
	["Dracola"] = {238, 239, 3052, 3061, 3383, 5741, 5925, 5944, 6299, 6499, 6546, 7420},
	["Dragon Hatchling"] = {266, 11457},
	["Dragon Lord Hatchling"] = {268, 818, 3732},
	["Dragon Lord"] = {236, 2842, 2903, 3029, 3051, 3061, 3280, 3373, 3386, 3392, 3428, 3450, 3732, 5882, 5948, 7378, 7399, 7402},
	["Dragon"] = {236, 3028, 3061, 3071, 3275, 3285, 3297, 3301, 3322, 3349, 3351, 3409, 3416, 3449, 3557, 5877, 5920, 7430, 11457},
	["Dragonling"] = {236, 237, 16131},
	["Draken Abomination"] = {237, 238, 830, 4033, 7642, 7643, 8094, 9057, 10384, 10385, 10387, 11671, 11672, 11673, 11688, 11691, 12549},
	["Draken Elite"] = {238, 3028, 4033, 5904, 7404, 7643, 10384, 10385, 10387, 10390, 11651, 11657, 11658, 11659, 11660, 11661, 11674, 11691, 11693},
	["Draken Spellweaver"] = {238, 3006, 3030, 3038, 3071, 8043, 10386, 10387, 10397, 10398, 10438, 10439, 11454, 11658, 12307, 12549},
	["Draken Warmaster"] = {239, 3006, 3030, 3428, 7643, 10384, 10386, 10387, 10388, 10404, 10405, 10406},
	["Draptor"] = {236, 237, 8039, 12309},
	["Dreadbeast"] = {3114, 3115, 3116, 3337, 3357, 3441, 3732, 5925},
	["Dreadmaw"] = {9058, 10279},
	["Drillworm"] = {814, 3097, 3456, 3492, 5880, 7452, 10305, 10422, 12600, 16122, 16123, 16124, 16126, 16133, 16135, 16142},
	["Dryad"] = {647, 3033, 3723, 3726, 9013, 9014, 9015, 9017, 12311},
	["Duskbringer"] = {9615},
	["Dwarf Geomancer"] = {813, 3029, 3046, 3059, 3097, 3147, 3311, 3584, 3723, 5880, 11458, 11463},
	["Dwarf Guard"] = {266, 3033, 3092, 3275, 3305, 3351, 3377, 3413, 3552, 3723, 5880, 12600},
	["Dwarf Miner"] = {3097, 3274, 3378, 3456, 3559, 5880},
	["Dwarf Soldier"] = {3092, 3266, 3349, 3358, 3375, 3425, 3446, 3457, 3723, 5880, 7363},
	["Dwarf"] = {3097, 3274, 3276, 3378, 3430, 3456, 3505, 3559, 3723, 5880},
	["Dworc Fleshhunter"] = {2920, 3114, 3299, 3346, 3347, 3361, 3403, 3441, 3471},
	["Dworc Venomsniper"] = {647, 2920, 3114, 3298, 3299, 3361, 3403, 3448, 3560},
	["Dworc Voodoomaster"] = {266, 2920, 3002, 3056, 3058, 3114, 3115, 3116, 3299, 3361, 3403},
	["Earth Elemental"] = {237, 774, 1781, 3147, 8894, 9057, 10305, 10422, 12600},
	["Earth Overlord"] = {811, 947, 8052, 10305, 10310, 12600},
	["Eclipse Knight"] = {9615},
	["Efreet"] = {237, 647, 827, 2647, 2933, 3032, 3038, 3071, 3330, 3574, 3584, 5910, 7378, 11470, 11486},
	["Elder Bonelord"] = {237, 3059, 3265, 3408, 3409, 3418, 7364, 10276, 10280, 11512},
	["Elder Mummy"] = {3007, 3017, 3027, 3042, 3045, 3046, 3299, 3492, 9649, 11466, 12482, 12483},
	["Elder Wyrm"] = {236, 237, 816, 820, 822, 825, 3028, 3349, 5944, 7430, 7451, 8027, 8043, 8092, 8093, 9665},
	["Elephant"] = {3044, 3443},
	["Elf Arcanist"] = {237, 266, 347, 2917, 3037, 3061, 3073, 3082, 3147, 3447, 3509, 3551, 3563, 3593, 3600, 3661, 3738, 5922, 9635, 11465},
	["Elf Overseer"] = {3413, 9635},
	["Elf Scout"] = {2901, 3350, 3447, 3448, 3449, 3551, 3592, 5921, 7438, 9635, 11464},
	["Elf"] = {3285, 3376, 3378, 3410, 3447, 3552, 5921, 8011, 9635},
	["Elvira Hammerthrust"] = {13429},
	["Emerald Damselfly"] = {266, 268, 3447, 17458, 17463},
	["Energy Elemental"] = {237, 268, 761, 3007, 3033, 3051, 3054, 3073, 3287, 3313, 3415, 7449},
	["Energy Overlord"] = {948, 8051},
	["Enlightened of the Cult"] = {237, 2828, 2995, 3029, 3051, 3055, 3071, 3084, 3324, 3567, 5668, 5801, 5810, 6087, 7426, 9638, 11455, 11652},
	["Enraged Crystal Golem"] = {236, 237, 7449, 7454, 15793, 16124, 16125, 16138},
	["Enraged Soul"] = {3282, 3292, 3432, 3740, 9690},
	["Enraged Squirrel"] = {836},
	["Enraged White Deer"] = {12544, 12545},
	["Enslaved Dwarf"] = {238, 239, 3032, 3033, 3092, 3279, 3369, 3415, 3428, 3432, 3725, 5880, 7413, 7437, 7452, 7454, 10310, 12600, 16121, 16122, 16123, 16126, 16142},
	["Esmeralda"] = {811, 3030, 3098, 3269, 3326, 3370, 3428, 3735, 9668},
	["Eternal Guardian"] = {1781, 3315, 3428, 5880, 9632, 10310, 10390, 10406, 10408, 10422, 10426, 12600},
	["Ethershreck"] = {238, 239, 281, 6499, 7642, 7643, 9057, 10310, 10323, 10384, 10385, 10386, 10387, 10388, 10389, 10390, 10406, 10438, 10449, 10450, 10451, 12801},
	["Evil Mastermind"] = {9391},
	["Fahim the Wise"] = {237, 647, 827, 2933, 2948, 3041, 3574, 3588, 5912, 7378, 10310, 11470, 11486},
	["Fan"] = {2948, 2949, 2950, 2954, 3178},
	["Fazzrah"] = {236, 239, 3032, 5876, 5881, 10289, 10384, 10386, 10387, 10413, 10414},
	["Fernfang"] = {347, 2885, 2902, 2905, 2914, 3012, 3037, 3050, 3061, 3077, 3105, 3147, 3289, 3551, 3563, 3600, 3661, 3736, 3738, 5786, 9646, 11492, 11493},
	["Feverish Citizen"] = {3115, 3492, 12551, 12552, 12553, 12554, 12555, 12556, 12786, 12787},
	["Feversleep"] = {238, 3030, 3032, 3033, 3567, 7643, 9057, 16124, 16125, 20203, 20204},
	["Filth Toad"] = {3286, 3578, 9640},
	["Fire Devil"] = {2920, 3033, 3069, 3075, 3147, 3275, 3307, 3415, 3471, 11513},
	["Fire Overlord"] = {826, 946, 8049, 9636},
	["Firestarter"] = {763, 3285, 3350, 3592, 5921, 7438, 9635, 12600, 12806},
	["Flameborn"] = {239, 3369, 3371, 3419, 3724, 6499, 7368, 7421, 7439, 7452, 7643, 9034, 9056, 9057, 10304, 12311},
	["Flamecaller Zazrak"] = {238, 3052, 10328, 10386, 10439, 10444},
	["Flamingo"] = {11684},
	["Fleabringer"] = {3492, 10407},
	["Fleshcrawler"] = {236, 811, 3018, 3025, 3032, 3033, 3042, 3370, 3440, 7426, 8084, 9631, 11468},
	["Fleshslicer"] = {238, 3026, 3030, 3039, 3346, 7413, 7643, 14082, 14083, 14753},
	["Fluffy"] = {3115, 3271, 3318, 5944, 6499, 6558, 6570, 6571},
	["Foreman Kneebiter"] = {3351, 3413, 5880},
	["Forest Fury"] = {3349, 3446, 7363, 7438, 9057, 18994, 18995},
	["Frazzlemaw"] = {238, 239, 3104, 3110, 3111, 3114, 3115, 3116, 3125, 3265, 3578, 5880, 5895, 5925, 5951, 7404, 7407, 7418, 9058, 10389, 16120, 16123, 16126, 16279, 20062, 20198, 20199},
	["Frost Dragon Hatchling"] = {266, 8072, 9661},
	["Frost Dragon"] = {2842, 2903, 3029, 3051, 3061, 3284, 3373, 3386, 3392, 3428, 3450, 3732, 7290, 7402, 7441},
	["Frost Giant"] = {266, 3093, 3269, 3294, 3384, 3413, 7290, 7441, 7460, 9658},
	["Frost Giantess"] = {266, 268, 1781, 3093, 3294, 3384, 3413, 7290, 7441, 7460, 9658},
	["Frost Troll"] = {3130, 3272, 3277, 3412, 3562, 3578, 9648},
	["Furious Troll"] = {3279, 9689},
	["Fury"] = {239, 3007, 3033, 3065, 3364, 3554, 5021, 5911, 5944, 6499, 6558, 7368, 7404, 7456, 8016, 8899},
	["Gang Member"] = {3093, 3286, 3362, 3559, 3602},
	["Gargoyle"] = {1781, 3012, 3093, 3282, 3351, 3383, 3413, 3591, 8010, 10278, 10310, 10426},
	["Gazer"] = {11512},
	["General Murius"] = {236, 3275, 3359, 3413, 3450, 3483, 3558, 5878, 7363, 7401, 11472},
	["Ghastly Dragon"] = {238, 812, 813, 3032, 3383, 3557, 5944, 6499, 7642, 7643, 8896, 10310, 10323, 10384, 10385, 10386, 10387, 10388, 10390, 10392, 10406, 10438, 10449, 10450, 10451},
	["Ghost"] = {2828, 3049, 3282, 3292, 3432, 3565, 3740, 5909, 9690},
	["Ghoul"] = {2920, 3052, 3114, 3291, 3367, 3377, 3492, 5913, 10291, 11467, 11484},
	["Ghoulish Hyaena"] = {266, 3030, 3492},
	["Giant Spider"] = {236, 828, 3053, 3055, 3265, 3351, 3357, 3370, 3371, 3372, 3448, 3557, 5879},
	["Gladiator"] = {3264, 3286, 3352, 3353, 3359, 3409, 3410, 8044},
	["Gnarlhound"] = {3492, 10407},
	["Goblin Assassin"] = {1781, 3115, 3120, 3267, 3294, 3337, 3355, 3361, 3462, 3578},
	["Goblin Leader"] = {3115, 3120, 3267, 3294, 3337, 3355, 3361, 3462, 3578},
	["Goblin Scavenger"] = {1781, 3115, 3120, 3267, 3294, 3337, 3355, 3361, 3462, 3578, 11539},
	["Goblin"] = {1781, 3115, 3120, 3267, 3294, 3337, 3355, 3361, 3462, 3578, 11539},
	["Golden Servant"] = {266, 268, 3049, 3063, 3269, 3360, 3732, 8072, 8775, 12601, 12801},
	["Gorgo"] = {238, 811, 812, 814, 3032, 3436, 7413, 7643, 9302, 10309},
	["Gozzler"] = {2885, 3029, 3097, 3266, 3273, 3282, 3297, 3311, 3410},
	["Grand Mother Foulscale"] = {3275, 3322, 3349, 3416, 3557, 5877, 5920, 7430},
	["Grandfather Tridian"] = {237, 2995, 3725, 5801, 6087},
	["Grave Guard"] = {266, 268, 3042, 3328, 3661, 6299, 12482},
	["Grave Robber"] = {3274, 3286, 3353, 3359, 3409, 7533, 8010, 11456, 11492},
	["Gravedigger"] = {236, 237, 3037, 3071, 3155, 3324, 5668, 5925, 6299, 9692, 10316, 11484, 11493},
	["Gravelord Oshuran"] = {237, 3027, 3059, 3098, 3567, 8076},
	["Green Djinn"] = {268, 2831, 2933, 3032, 3574, 3607, 3661, 5910, 7378, 11456},
	["Grim Reaper"] = {238, 823, 3046, 3421, 3453, 5021, 6299, 6499, 6558, 7418, 7643, 8061, 8082, 8896, 9660},
	["Grimrat"] = {6571},
	["Groam"] = {3052, 3347, 8894},
	["Grorlam"] = {1781, 2920, 3007, 3033, 3039, 3050, 3283, 3377, 3409, 3456, 3554, 5880, 10310, 10315},
	["Groupie"] = {2948, 2949, 2950, 2954, 3178},
	["Grynch Clan Goblin"] = {836, 841, 2392, 2875, 2906, 2950, 2983, 2992, 2995, 3003, 3042, 3046, 3147, 3454, 3463, 3572, 3585, 3586, 3590, 3598, 3599, 3606, 4871, 5021, 5792, 5890, 5894, 5902, 6276, 6392, 6393, 6496, 6500},
	["Guzzlemaw"] = {238, 239, 3104, 3110, 3111, 3114, 3115, 3116, 3125, 3265, 3578, 5880, 5895, 5925, 5951, 7404, 7407, 7418, 10389, 16120, 16123, 16126, 16279, 20062, 20198, 20199},
	["Hacker"] = {2914, 3266, 3269, 3274, 3279, 6570, 6571},
	["Hairman The Huge"] = {3093, 3587},
	["Hand of Cursed Fate"] = {238, 3010, 3029, 3036, 3037, 3041, 3051, 3055, 3062, 3071, 3079, 3084, 3155, 3324, 3370, 3381, 5799, 5944, 6299, 6499, 6558, 7368, 7414, 7643, 9058},
	["Hatebreeder"] = {6499, 7642, 7643, 10323, 10385, 10386, 10387, 10388, 10390, 10392, 10406, 10438, 10449, 10450, 10451},
	["Haunted Treeling"] = {236, 266, 3032, 3097, 3723, 3724, 3726, 7443, 9683},
	["Hellfire Fighter"] = {821, 826, 3010, 3019, 3028, 3071, 3124, 3147, 3280, 3320, 5944, 6499, 9636, 9664, 12600},
	["Hellhound"] = {238, 239, 821, 826, 827, 3027, 3071, 3116, 3271, 3280, 3281, 3318, 4871, 5910, 5914, 5925, 5944, 6499, 6553, 6558, 7368, 7421, 7426, 8896, 9057, 9058, 9637},
	["Hellspawn"] = {239, 3282, 3369, 3371, 3413, 3724, 6499, 7368, 7421, 7439, 7452, 7643, 8895, 8896, 9034, 9056, 9057, 10304},
	["Hemming"] = {3027, 3053, 3081, 3725, 3741, 5479, 5897, 7419, 7428, 7439, 7643, 10317, 10389},
	["Herald of Gloom"] = {9615},
	["Hero"] = {239, 347, 2949, 2995, 3003, 3004, 3048, 3265, 3279, 3280, 3350, 3381, 3382, 3385, 3419, 3447, 3563, 3572, 3592, 3658, 5911, 7364, 11450, 11510},
	["Hide"] = {830, 3053, 3351, 3371, 5879},
	["Hideous Fungus"] = {238, 239, 268, 811, 812, 813, 814, 3279, 5909, 5910, 5911, 5912, 16099, 16103, 16117, 16140, 16143, 16164},
	["High Templar Cobrass"] = {3345, 3351, 3357, 3445, 5876, 5881},
	["Hirintror"] = {236, 237, 819, 829, 3028, 3284, 3373, 5912, 7290, 7441, 7449, 19362, 19363},
	["Hive Overseer"] = {238, 281, 3030, 3554, 7643, 9058, 14077, 14083, 14086, 14088, 14089, 14172, 14246},
	["Honour Guard"] = {3042, 3286, 3307, 3725, 11481},
	["Humongous Fungus"] = {236, 237, 238, 239, 268, 811, 812, 813, 814, 5909, 5911, 5912, 5913, 7436, 16099, 16103, 16117, 16139, 16142, 16164},
	["Hunter"] = {2920, 3030, 3085, 3350, 3354, 3359, 3447, 3448, 3449, 3586, 3601, 5875, 5907, 7394, 7397, 7400, 11469},
	["Hyaena"] = {3492},
	["Hydra"] = {237, 3029, 3061, 3079, 3081, 3098, 3369, 3370, 3392, 3436, 4839, 8014, 10282},
	["Ice Golem"] = {236, 237, 829, 3027, 3028, 3029, 3284, 3373, 7290, 7441, 7449, 9661},
	["Ice Overlord"] = {942, 8050},
	["Ice Witch"] = {237, 819, 823, 3067, 3311, 3574, 3732, 7290, 7387, 7441, 7449, 7459},
	["Infected Weeper"] = {12600},
	["Infernalist"] = {238, 239, 676, 818, 2852, 2995, 3051, 3324, 5904, 5911, 8012, 8074, 9045, 9056, 9058, 9067},
	["Insectoid Scout"] = {266, 3093, 3346},
	["Insectoid Worker"] = {266, 3032, 3326, 14083, 14225},
	["Iron Servant"] = {266, 3269, 8775, 8894, 12601},
	["Ironblight"] = {238, 812, 3032, 3033, 3039, 3041, 3326, 3333, 5904, 7437, 7643, 8027, 8084, 9028, 9067, 9654, 10310, 10451, 16118, 16121, 16123, 16126, 16138},
	["Island Troll"] = {901, 3003, 3054, 3268, 3277, 3336, 3355, 3412, 3552, 5096, 5901},
	["Jagged Earth Elemental"] = {647, 940, 1781, 3032, 3130, 5880, 10305, 10422, 12600},
	["Jellyfish"] = {3581},
	["Jesse the Wicked"] = {13429},
	["Juggernaut"] = {238, 239, 281, 3019, 3030, 3032, 3036, 3038, 3039, 3105, 3113, 3322, 3340, 3360, 3364, 3414, 5944, 6499, 6558, 7368, 7413, 7452, 8061, 8896, 9058},
	["Kerberos"] = {238, 817, 3027, 3038, 3280, 3318, 3360, 4871, 6499, 6553, 6558, 9058, 9637},
	["Killer Caiman"] = {281, 3032, 3313, 3556, 10279, 10328},
	["Kollos"] = {238, 281, 3030, 3098, 3554, 7643, 9058, 14077, 14083, 14086, 14088, 14089, 14249, 14251},
	["Kongra"] = {266, 3050, 3084, 3093, 3357, 3587, 5883, 11471},
	["Lancer Beetle"] = {3033, 9640, 9692, 10455, 10457},
	["Latrivan"] = {239, 3026, 3027, 3028, 3029, 3032, 3033, 3038, 3041, 3046, 3048, 3049, 3051, 3054, 3062, 3063, 3066, 3069, 3070, 3076, 3079, 3081, 3098, 3275, 3281, 3284, 3290, 3320, 3324, 3356, 3364, 3414, 3420, 6299, 6499, 7365, 7368, 9058},
	["Lava Golem"] = {236, 237, 238, 268, 817, 818, 826, 3037, 3039, 3071, 3280, 3320, 3419, 5880, 5909, 5911, 5914, 7643, 8074, 9636, 16115, 16120, 16122, 16126, 16130, 16131, 16141},
	["Leaf Golem"] = {3032, 3723, 17824, 19110, 19111},
	["Lersatio"] = {236, 3027, 3098, 3434, 7419, 11449},
	["Lethal Lissy"] = {3028, 3114, 3275, 3357, 3370, 5926, 6100},
	["Leviathan"] = {237, 3029, 7428, 8059, 8895, 8898, 9303, 9604, 9613},
	["Lich"] = {237, 820, 3026, 3027, 3032, 3037, 3055, 3059, 3062, 3098, 3289, 3324, 3373, 3432, 3435, 3567, 9057, 12304},
	["Lion"] = {9691},
	["Lionet"] = {6571, 11681, 12737, 14173},
	["Lizard Chosen"] = {239, 3028, 3428, 5876, 5881, 10384, 10385, 10386, 10387, 10408, 10409, 10410, 11673},
	["Lizard Dragon Priest"] = {237, 238, 3033, 3037, 3052, 3065, 3071, 5876, 5881, 8043, 10328, 10386, 10439, 10444},
	["Lizard Gate Guardian"] = {5881, 7643, 10385, 10387, 10390},
	["Lizard High Guard"] = {236, 239, 3032, 3428, 5876, 5881, 10289, 10328, 10384, 10386, 10387, 10408, 10415, 10416},
	["Lizard Legionnaire"] = {236, 3028, 5876, 5881, 10289, 10328, 10384, 10386, 10388, 10406, 10417, 10418, 10419},
	["Lizard Magistratus"] = {237, 238, 3030, 5881},
	["Lizard Noble"] = {236, 239, 3030, 5876},
	["Lizard Sentinel"] = {266, 3028, 3269, 3277, 3313, 3347, 3358, 3377, 3444, 5876, 5881},
	["Lizard Snakecharmer"] = {268, 3033, 3037, 3052, 3061, 3065, 3066, 3122, 3407, 3565, 4000, 5876, 5881},
	["Lizard Templar"] = {266, 3032, 3264, 3282, 3294, 3345, 3351, 3357, 3445, 5876, 5881},
	["Lizard Zaogun"] = {236, 239, 3032, 3428, 5876, 5881, 10289, 10384, 10386, 10387, 10413, 10414},
	["Lost Basher"] = {238, 813, 2995, 3097, 3318, 3320, 3342, 3371, 3429, 3725, 5880, 7427, 7452, 7643, 9057, 12600, 16119, 17826, 17827, 17828, 17829, 17830, 17831, 17847, 17855, 17856, 17857},
	["Lost Berserker"] = {238, 239, 813, 2995, 3097, 3318, 3320, 3392, 3415, 3428, 3429, 3725, 5880, 5904, 7427, 7452, 9057, 10422, 12600, 16120, 16123, 16124, 16127, 16142},
	["Lost Husher"] = {236, 238, 812, 813, 3097, 3318, 3320, 3324, 3415, 3428, 3725, 7452, 9057, 10422, 12600, 17829, 17830, 17831, 17847, 17848, 17849, 17850, 17855, 17856, 17857},
	["Lost Soul"] = {238, 239, 3016, 3026, 3027, 3039, 3081, 3147, 3324, 3428, 5741, 5806, 5944, 6299, 6499, 6525, 7407, 7413, 8895, 8896, 10316},
	["Lost Thrower"] = {238, 239, 3725, 5880, 12600, 17827, 17829, 17851, 17852, 17853, 17854, 17855, 17856, 17857},
	["Lyxoph"] = {6571, 14683, 14684, 14685, 14741},
	["Mad Scientist"] = {266, 268, 678, 3046, 3061, 3598, 3723, 3739, 6393, 7440},
	["Mad Technomancer"] = {396},
	["Magma Crawler"] = {238, 239, 817, 818, 3028, 3037, 3051, 3280, 3429, 5880, 5909, 5911, 5914, 8093, 9636, 12600, 15793, 16115, 16119, 16123, 16127, 16130, 16131},
	["Mahrdis"] = {239, 3024, 3030, 3039, 3052, 3240, 3320, 3439, 10290},
	["Mamma Longlegs"] = {239, 3049, 3051, 3053, 3055, 3351, 3370, 3371, 5879, 5886, 7416, 7419},
	["Mammoth"] = {3443, 7381, 7432, 10307, 10321},
	["Man in the Cave"] = {3003, 5913, 7290, 7386, 7458},
	["Marid"] = {237, 647, 827, 2659, 2933, 2948, 3029, 3041, 3067, 3330, 3574, 3588, 3659, 5912, 7378, 11470, 11486},
	["Marsh Stalker"] = {647, 3003, 3285, 3492, 3578, 17461, 17462},
	["Marziel"] = {236, 3098},
	["Massacre"] = {238, 239, 3106, 3116, 3340, 3360, 3422, 5021, 5944, 6104, 6499, 6540, 7403},
	["Massive Earth Elemental"] = {814, 1781, 3028, 3081, 3084, 3097, 7387, 8895, 9057, 10305, 10422, 12600},
	["Massive Energy Elemental"] = {237, 238, 761, 794, 816, 822, 3033, 8073, 8092, 8895, 9304},
	["Massive Fire Elemental"] = {817, 818, 821, 3030, 3071, 3280, 8895},
	["Massive Water Elemental"] = {238, 239, 3028, 3032, 3051, 3052, 7158, 7159},
	["Maw"] = {238, 281, 3027, 3030, 3039, 7643, 9058, 14077, 14083, 14172, 14246, 14753},
	["Medusa"] = {238, 811, 812, 814, 3032, 3370, 3436, 7413, 7643, 8896, 9302, 10309},
	["Mephiles"] = {9376, 9377, 9387, 9400},
	["Mercury Blob"] = {9053},
	["Merikh the Slaughterer"] = {237, 827, 3032, 3038, 3330, 3574, 5910, 7378, 10310, 11470, 11486},
	["Merlkin"] = {268, 3033, 3046, 3072, 3348, 3586, 3587, 5883, 11511},
	["Midnight Panther"] = {3052, 12039, 12040},
	["Midnight Spawn"] = {9615},
	["Midnight Warrior"] = {9615},
	["Mindmasher"] = {238, 239, 3029, 3032, 3097, 3346, 10392, 14083, 14753},
	["Minotaur Archer"] = {3349, 3359, 3377, 3446, 5878, 7363, 11451, 11472, 11483},
	["Minotaur Guard"] = {266, 3275, 3358, 3359, 3413, 3483, 5878, 7401, 11472, 11482},
	["Minotaur Mage"] = {268, 2920, 3073, 3355, 3559, 3595, 5878, 7425, 11472, 11473},
	["Minotaur"] = {3056, 3264, 3274, 3286, 3354, 3358, 3410, 3457, 5878, 11472},
	["Monk"] = {347, 2885, 2914, 3050, 3061, 3077, 3289, 3551, 3600, 9646, 11492, 11493},
	["Monstor"] = {9380, 9381, 9386, 9396},
	["Morguthis"] = {239, 3019, 3027, 3081, 3237, 3318, 3331, 3554, 7368, 10290},
	["Morik the Gladiator"] = {8820},
	["Mornenion"] = {13429},
	["Muddy Earth Elemental"] = {940, 1781, 3129, 10305, 10422, 12600},
	["Mummy"] = {3007, 3017, 3027, 3045, 3046, 3054, 3299, 3429, 3492, 5914, 9649, 10290, 11466},
	["Munster"] = {3337, 3492, 3607, 5792},
	["Mutated Bat"] = {3027, 3033, 3051, 3313, 3413, 3429, 3736, 5894, 7386, 8894, 8895, 9103, 9662},
	["Mutated Human"] = {841, 3045, 3054, 3111, 3264, 3377, 3492, 3607, 3737, 8894, 10308},
	["Mutated Rat"] = {266, 3049, 3114, 3120, 3269, 3410, 3428, 3732, 3735, 8072, 9668},
	["Mutated Tiger"] = {236, 3052, 3415, 7436, 7454, 9046, 10293, 10311},
	["Necromancer Servant"] = {3448, 10320, 11475, 18933},
	["Necromancer"] = {237, 3079, 3311, 3324, 3448, 3574, 3732, 7456, 8073, 10320, 11475},
	["Necropharus"] = {3070, 3079, 3114, 3116, 3311, 3324, 3337, 3441, 3574, 3732, 5809, 10320, 11475},
	["Nightfiend"] = {236, 237, 3010, 3030, 3039, 9685, 11449, 18924},
	["Nightmare Scion"] = {3385, 6299, 6574, 7387, 7451, 8043, 9027, 10306, 10312},
	["Nightmare"] = {3079, 3342, 3371, 3432, 3450, 5668, 5944, 6299, 6499, 6525, 6558, 10306, 10312},
	["Nightslayer"] = {9615},
	["Nightstalker"] = {237, 3007, 3055, 3079, 3084, 3740, 7407, 7427, 8042, 9028},
	["Nomad"] = {3274, 3286, 3353, 3359, 3409, 7533, 8010, 11456, 11492},
	["Novice of the Cult"] = {2828, 3028, 3074, 3083, 3097, 3572, 5810, 6087, 9639, 11492},
	["Ocyakao"] = {3026, 3441, 3578, 3580, 5909, 7381, 7441, 19369},
	["Omruc"] = {239, 3028, 3049, 3079, 3239, 3332, 3447, 3448, 3449, 3450, 3585, 7365, 10290},
	["Orc Berserker"] = {2914, 3266, 3269, 3347, 3358, 10196, 11477, 11479},
	["Orc Leader"] = {266, 3091, 3285, 3298, 3301, 3307, 3357, 3369, 3372, 3410, 3557, 3578, 3725, 7378, 10196, 11479, 11480},
	["Orc Marauder"] = {3313, 3316, 3349, 3350, 8029, 10196, 10407, 11451, 11479},
	["Orc Rider"] = {2920, 3012, 3313, 3316, 3377, 3413, 10196, 10318, 11479},
	["Orc Shaman"] = {2839, 3072, 3277, 3358, 3597, 10196, 11452, 11478, 11479},
	["Orc Spearman"] = {3277, 3308, 3362, 3376, 10196, 11479},
	["Orc Warlord"] = {266, 818, 3049, 3063, 3084, 3265, 3287, 3307, 3316, 3322, 3347, 3357, 3359, 3384, 3391, 3393, 3394, 3437, 3557, 3578, 7395, 10196, 11453, 11479, 11480},
	["Orc Warrior"] = {3299, 3358, 3430, 10196, 11453, 11479, 11480},
	["Orc"] = {3244, 3273, 3274, 3376, 3378, 3426, 10196, 11479},
	["Orchid Frog"] = {3492},
	["Orewalker"] = {236, 237, 238, 268, 3037, 3097, 3371, 3381, 3385, 5880, 5904, 7413, 7454, 7643, 8050, 9057, 10310, 10315, 16096, 16121, 16124, 16125, 16133, 16135, 16141, 16163},
	["Overcharged Energy Element"] = {239, 945, 3033, 3098, 7439, 8092},
	["Paiz the Pauperizer"] = {238, 239, 3032, 3037, 3038, 3039, 3041, 3386, 5881, 5904, 7642, 8052, 10384, 10389, 10390, 11651, 11657, 11658, 11659, 11660, 11661, 12307},
	["Panda"] = {11445},
	["Penciljack"] = {6571, 14683, 14684, 14685, 14741},
	["Penguin"] = {3578, 7158, 7159},
	["Phantasm"] = {238, 3030, 3032, 3033, 3049, 3147, 3381, 3740, 6299, 6499, 7414, 7451, 7643, 9057},
	["Pig"] = {9693},
	["Pirate Buccaneer"] = {236, 2920, 3123, 3273, 3298, 3357, 3413, 5552, 5706, 5792, 5926, 6095, 6097, 6098, 6126, 10302},
	["Pirate Corsair"] = {236, 2995, 3273, 3287, 3383, 3421, 5461, 5552, 5813, 5926, 6096, 6097, 6098, 6126, 10302},
	["Pirate Cutthroat"] = {3377, 3409, 5552, 5706, 5710, 5792, 5918, 5927, 6097, 6098, 6126, 10302},
	["Pirate Ghost"] = {2814, 3049, 3271, 3566, 9684},
	["Pirate Marauder"] = {2920, 3277, 3358, 3410, 5552, 5706, 5792, 5917, 5927, 5928, 6097, 6098, 6126, 10302},
	["Pirate Skeleton"] = {3114, 3115, 3116, 3264, 3294, 3337, 9642},
	["Plaguesmith"] = {239, 2958, 3010, 3017, 3033, 3092, 3093, 3110, 3120, 3122, 3265, 3279, 3282, 3305, 3332, 3371, 3409, 3554, 5887, 5888, 5889, 5944, 6499, 7365, 8896},
	["Poacher"] = {2920, 3350, 3355, 3447, 3448, 3481, 3559, 3601},
	["Poison Spider"] = {11485},
	["Polar Bear"] = {9650},
	["Priestess"] = {268, 2828, 2948, 2995, 3008, 3034, 3067, 3076, 3311, 3429, 3585, 3674, 3727, 3738, 3739, 9639, 9645, 10303},
	["Primitive"] = {3273, 3274, 3376, 3378, 3426, 6570, 6571},
	["Quara Constrictor Scout"] = {3033, 3285, 3359, 3581, 5895, 11487},
	["Quara Constrictor"] = {3033, 3285, 3359, 3581, 5895, 11487},
	["Quara Hydromancer Scout"] = {3026, 3027, 3032, 3073, 3098, 3313, 3370, 3578, 3581, 5895, 11488},
	["Quara Hydromancer"] = {238, 3026, 3027, 3032, 3073, 3098, 3370, 3581, 5895, 11488},
	["Quara Mantassin Scout"] = {3029, 3049, 3114, 3265, 3358, 5895, 11489},
	["Quara Mantassin"] = {3029, 3049, 3265, 3269, 3373, 3565, 3567, 3581, 5895, 11489},
	["Quara Pincher Scout"] = {3030, 3061, 3269, 3357, 5895, 11490, 12318},
	["Quara Pincher"] = {239, 824, 3030, 3269, 3369, 3381, 3581, 5895, 11490, 12318},
	["Quara Predator Scout"] = {3028, 3265, 3275, 3377, 3581, 5895, 8083, 11491},
	["Quara Predator"] = {239, 824, 3028, 3275, 3581, 5741, 5895, 7368, 7378, 7383, 11491, 12318},
	["Rabbit"] = {3595, 6541, 6542, 6543, 6544, 6545},
	["Rahemos"] = {238, 3033, 3036, 3060, 3068, 3098, 3235, 3335, 3573, 10290},
	["Rat"] = {3607},
	["Renegade Orc"] = {266, 3091, 3285, 3298, 3301, 3307, 3369, 3410, 3557, 3578, 3725, 10196, 11479},
	["Retching Horror"] = {238, 239, 3280, 3344, 3419, 3428, 3725, 7386, 8082, 8092, 20029, 20062, 20205, 20207},
	["Ribstride"] = {3028, 3441, 3732, 5741, 5925, 10244, 10277, 12304},
	["Roaring Water Elemental"] = {281, 944, 3029, 8083},
	["Robby the Reckless"] = {13429},
	["Ron the Ripper"] = {239, 3028, 3114, 3267, 3357, 3370, 5926, 6101},
	["Rorc"] = {3012, 3313, 3316, 3410, 18993, 18996, 18997},
	["Rotspit"] = {238, 3033, 3725, 7449, 14078, 14753},
	["Rottie the Rotworm"] = {3264, 3286, 3374, 3430, 3492, 9692},
	["Rotworm Queen"] = {3492, 8143},
	["Rotworm"] = {3264, 3286, 3492, 9692},
	["Rukor Zad"] = {3409, 7366},
	["Sacred Spider"] = {3042, 3357, 8031, 9058},
	["Salamander"] = {266, 3003, 3286, 3307, 3350, 3354, 3447, 17457},
	["Sandcrawler"] = {10456},
	["Sandstone Scorpion"] = {3032, 3327, 3351, 3429, 12546},
	["Scarab"] = {3032, 3033, 3042, 3327, 9641},
	["Scorpion"] = {9651},
	["Sea Serpent"] = {236, 237, 238, 815, 823, 3029, 3049, 3098, 3297, 3557, 8042, 8043, 8050, 8083, 9303, 9666},
	["Serpent Spawn"] = {238, 2903, 3029, 3051, 3052, 3061, 3066, 3369, 3373, 3381, 3392, 3407, 3428, 3450, 3732, 4831, 7386, 7456, 8052, 8074, 9694, 10313},
	["Shaburak Demon"] = {236, 237, 821, 2995, 3030, 3051, 3071, 3725, 5904, 7378, 7443},
	["Shaburak Lord"] = {236, 237, 826, 3030, 3051, 3071, 3554, 3725, 5904, 7443},
	["Shaburak Prince"] = {236, 237, 826, 3030, 3049, 3071, 3554, 3725, 5904, 7412, 7443, 12541},
	["Shadow Hound"] = {9615},
	["Shadow Pupil"] = {237, 3079, 3574, 3725, 8072, 10320, 18926, 18929, 18930},
	["Shadowstalker"] = {238, 239, 3032, 3037, 9057, 14079, 14083, 14753},
	["Shardhead"] = {236, 3027, 3028, 3029, 7290, 7441, 9661},
	["Shark"] = {281, 3029, 3578, 5895, 12730, 14017},
	["Sharptooth"] = {3111},
	["Sheep"] = {10319},
	["Shiversleep"] = {238, 3030, 3032, 3281, 3369, 3370, 3567, 5909, 5911, 7643, 9057, 16119, 16124, 16125, 20203, 20204},
	["Shock Head"] = {3029, 3392, 20205},
	["Sibang"] = {1781, 3586, 3587, 3589, 3593, 5883, 11511},
	["Sight of Surrender"] = {238, 3048, 3081, 3332, 3333, 3366, 3391, 3428, 3554, 7421, 7422, 7642, 7643, 16119, 16120, 16121, 16122, 16123, 16124, 20062, 20183, 20184, 20208},
	["Silencer"] = {239, 812, 813, 3049, 3079, 3421, 7368, 7387, 7407, 7413, 7451, 7454, 20062, 20200, 20201},
	["Silver Rabbit"] = {3595, 6541, 6542, 6543, 6544, 6545, 10292},
	["Sir Valorcrest"] = {236, 3091, 3098, 3114, 3434, 7427, 8192},
	["Siramal"] = {6571, 14673},
	["Skeleton Warrior"] = {3115, 3264, 3286, 3723, 3725, 11481},
	["Skeleton"] = {2920, 3115, 3264, 3276, 3286, 3367, 3411, 11481},
	["Skunk"] = {8197, 10274},
	["Skyrr"] = {6571},
	["Slick Water Elemental"] = {762, 944},
	["Slug"] = {3492},
	["Smuggler Baron Silvertoe"] = {3286, 3294},
	["Smuggler"] = {2920, 3264, 3291, 3292, 3294, 3355, 3559, 7397, 8012},
	["Souleater"] = {238, 3069, 3073, 5884, 6299, 7643, 11679, 11680, 11681},
	["Spectre"] = {238, 2949, 3017, 3019, 3049, 3073, 3147, 5909, 5944, 6299, 6499, 7383, 7451, 10310},
	["Spider"] = {8031},
	["Spidris Elite"] = {238, 281, 3030, 3036, 6299, 7413, 7643, 14082, 14083, 14086, 14088, 14089},
	["Spidris"] = {238, 281, 3030, 3036, 6299, 7413, 7643, 14082, 14083, 14086, 14088, 14089},
	["Spit Nettle"] = {647, 3661, 3738, 3740, 10314, 11476},
	["Spitter"] = {238, 239, 3033, 3038, 3053, 3055, 3391, 3725, 7440, 7449, 14078, 14083, 14086, 14087},
	["Squirrel"] = {836, 841, 10296},
	["Stalker"] = {3147, 3298, 3300, 3313, 3372, 3411, 11474},
	["Stampor"] = {236, 237, 3279, 3370, 7452, 9057, 12312, 12313, 12314},
	["Starving Wolf"] = {3105, 5897},
	["Stone Devourer"] = {236, 237, 238, 268, 3081, 3097, 3281, 3333, 3342, 7437, 7452, 7454, 7643, 9632, 12600, 15793, 16122, 16125, 16137, 16138},
	["Stone Golem"] = {1781, 3007, 3039, 3050, 3283, 5880, 9632, 10310, 10315, 10426, 12600},
	["Stonecracker"] = {3033, 3265, 3275, 3281, 3342, 3554, 5893, 5930, 7368, 7396, 10310},
	["Sulphur Scuttler"] = {236, 237, 3032, 3049, 3055, 5904, 9640, 10305, 10315, 11702, 11703},
	["Swamp Troll"] = {2920, 3120, 3277, 3483, 3552, 3578, 3741, 5901, 9686, 12517},
	["Swampling"] = {3003, 3723, 17822, 17823, 17824},
	["Swarmer"] = {3032, 3326, 14076, 14083},
	["Tarantula"] = {3053, 3351, 3372, 3410, 8031, 10281},
	["Tarnished Spirit"] = {2828, 3282, 3292, 3432, 3565, 3740, 5909, 9690},
	["Teleskor"] = {2920, 3264, 3276, 3286, 3367, 3411, 11481},
	["Terofar"] = {3038, 3415, 3420, 5954, 7642, 7643, 9058, 16121, 20062},
	["Terramite"] = {10452, 10453, 10454},
	["Terrified Elephant"] = {3044, 3443},
	["Terror Bird"] = {266, 647, 3406, 3492, 10273, 11514},
	["Terrorsleep"] = {238, 3030, 3032, 3281, 3369, 3370, 3567, 5909, 5911, 7643, 9057, 16119, 16124, 16125, 20203, 20204},
	["Thalas"] = {239, 3032, 3038, 3049, 3053, 3238, 3297, 3299, 3339, 10290},
	["The Abomination"] = {3027, 3029, 3030, 3032, 3033, 5944, 6499},
	["The Blightfather"] = {3033, 9640, 9692, 10455},
	["The Bloodtusk"] = {3044, 3443, 5911, 7432, 7463, 10321},
	["The Bloodweb"] = {237, 823, 829, 3053, 3370, 3371, 5801, 5879, 7290, 7437, 7441, 10389},
	["The Count"] = {3434, 7924},
	["The Evil Eye"] = {238, 811, 3059, 3265, 3282, 3285, 3409, 3418, 5898, 11512},
	["The Handmaiden"] = {3049, 3050, 3051, 3110, 3116, 3421, 3554, 3567, 5944, 6499, 6539},
	["The Horned Fox"] = {236, 3049, 3275, 3276, 3359, 3396, 3413, 3483, 3558, 5804, 5878, 7363, 11472, 11482},
	["The Imperor"] = {826, 3019, 3030, 3033, 3364, 3382, 3442, 3451, 5944, 6499, 6534},
	["The Keeper"] = {11367},
	["The Many"] = {237, 3029, 3081, 3369, 3370, 3392, 3436, 9058, 9302, 9606},
	["The Mutated Pumpkin"] = {3594, 6491, 6525, 8032, 8177, 8178},
	["The Noxious Spawn"] = {238, 2903, 3032, 3052, 3381, 3392, 3428, 3732, 7368, 7386, 7456, 8052, 8074, 9394, 9694, 10313},
	["The Old Whopper"] = {7398, 9657},
	["The Old Widow"] = {239, 3049, 3051, 3053, 3055, 3351, 3370, 3371, 5879, 5886, 7416, 7419, 12320},
	["The Pale Count"] = {236, 237, 3027, 3029, 3032, 3049, 3098, 3326, 3434, 5909, 5911, 5912, 7419, 7427, 8075, 8192, 9057, 18927, 18935, 18936, 19373, 19374},
	["The Plasmother"] = {3027, 3029, 3032, 3033, 5944, 6499, 6535},
	["The Snapper"] = {266, 3032, 3052, 3357, 3370, 3556, 3557},
	["The Voice of Ruin"] = {10408, 10410},
	["The Weakened Count"] = {7924},
	["The Welter"] = {236, 237, 281, 3029, 3079, 3081, 3284, 3369, 3370, 3392, 3436, 4839, 9058, 9302, 19083, 19356, 19357},
	["Thieving Squirrel"] = {836, 9843},
	["Thornback Tortoise"] = {266, 3026, 3027, 3279, 3578, 3723, 3725, 5678, 5899, 9643},
	["Thornfire Wolf"] = {763, 5897, 9636},
	["Thul"] = {238, 901, 3033, 3381, 3391, 5895, 7383},
	["Tiger"] = {10293},
	["Tiquandas Revenge"] = {647, 3728, 5014, 12311},
	["Toad"] = {3279, 3286, 3578, 9640},
	["Tomb Servant"] = {3042, 3112, 3115, 3285, 3441, 3492, 10283, 12546},
	["Tormentor"] = {3079, 3342, 3371, 5668, 6299, 6499, 6525, 6558, 7418, 10306, 10312},
	["Tortoise"] = {3305, 3410, 3578, 5678, 5899, 6131},
	["Troll Champion"] = {3054, 3277, 3336, 3412, 3447, 3552, 9689, 11515},
	["Troll Guard"] = {3003, 3336},
	["Troll Legionnaire"] = {3049, 3287, 9648},
	["Troll"] = {3003, 3054, 3268, 3277, 3336, 3355, 3412, 3552, 9689},
	["Tromphonyte"] = {236, 237, 3370, 7452, 9057, 12312, 12313, 12314},
	["Tyrn"] = {236, 237, 816, 3028, 3029, 3030, 3032, 3033, 3037, 3039, 3041, 3155, 3415, 5911, 7368, 7430, 9057, 9304, 9665, 19083},
	["Undead Cavebear"] = {266, 12315, 12316},
	["Undead Dragon"] = {238, 239, 2903, 3027, 3029, 3041, 3061, 3342, 3360, 3370, 3392, 3450, 5925, 6299, 6499, 7368, 7402, 7430, 8057, 8061, 9058, 10316, 10438},
	["Undead Gladiator"] = {266, 3049, 3084, 3265, 3287, 3307, 3318, 3347, 3357, 3359, 3372, 3384, 3391, 3557, 5885, 8044, 9656},
	["Undead Jester"] = {123, 651, 900, 901, 2995, 3578, 5909, 5910, 5911, 5912, 5913, 5914, 6574, 7158, 7159, 7377, 8779, 8780, 8781, 8782, 8783, 8784, 8853},
	["Undead Mine Worker"] = {3115, 3264, 3286, 3723, 3725},
	["Undead Minion"] = {3147, 3305, 3413, 3415, 6570, 6571},
	["Undead Prospector"] = {2920, 3052, 3114, 3291, 3354, 3367, 3377, 3492, 5913},
	["Valkyrie"] = {266, 3028, 3084, 3114, 3275, 3277, 3347, 3357, 3358, 3585, 11443, 11444},
	["Vampire Bride"] = {236, 237, 649, 3010, 3028, 3070, 3079, 5668, 8045, 8531, 8895, 8923, 9685, 11449, 12306},
	["Vampire Viscount"] = {236, 237, 3027, 3030, 3039, 3284, 3434, 5911, 9685, 11449, 18924, 18927},
	["Vampire"] = {236, 3010, 3027, 3056, 3114, 3271, 3284, 3300, 3373, 3434, 3661, 9685, 11449},
	["Vashresamun"] = {238, 2950, 2953, 3007, 3022, 3026, 3236, 3333, 3567, 10290},
	["Vulcongra"] = {236, 237, 817, 826, 3071, 3091, 3280, 3587, 9636, 12600, 16123, 16126, 16130, 16131},
	["Wailing Widow"] = {266, 268, 3269, 3410, 3732, 10406, 10411, 10412},
	["War Golem"] = {238, 820, 953, 3061, 3093, 3097, 3265, 3282, 3326, 3410, 3413, 3554, 5880, 7403, 7422, 7428, 7439, 7643, 8895, 9063, 9067, 9654, 12305},
	["War Wolf"] = {5897, 7394, 10318},
	["Warlock"] = {238, 239, 825, 2852, 2917, 2995, 3006, 3007, 3029, 3034, 3051, 3062, 3081, 3299, 3324, 3360, 3509, 3567, 3590, 3600, 3728, 7368, 11454},
	["Warlord Ruzad"] = {818, 3084, 3287, 3307, 3316, 3357, 3372, 3384, 3557, 3578},
	["Wasp"] = {5902},
	["Waspoid"] = {3010, 3027, 3037, 14080, 14081, 14083, 14087, 14088, 14089},
	["Water Elemental"] = {236, 237, 281, 3026, 3028, 3029, 3032, 3051, 3052, 3578, 7158, 7159, 9303},
	["Weak Gloombringer"] = {3029, 3030, 3032, 9058, 9615},
	["Weak Harbinger of Darkness"] = {3028, 3032, 9058, 9615},
	["Weak Spawn of Despair"] = {3028, 3030, 9058, 9615},
	["Weakened Shlorg"] = {238, 3032, 3037, 3038, 3297, 5910, 5911, 5914, 7642, 7643, 8044, 8084, 9057, 9667, 19083, 19371, 19372},
	["Weeper"] = {238, 821, 826, 3030, 3280, 3320, 7643, 9636, 12600, 16115, 16120, 16123, 16126, 16130, 16131, 16132, 16141},
	["Werewolf"] = {236, 3053, 3055, 3081, 3269, 3326, 3410, 3725, 3741, 5897, 7383, 7419, 7428, 7439, 7643, 8895, 10317},
	["White Pale"] = {3028, 3052, 3327, 9692, 10275, 19083, 19358, 19359},
	["White Shade"] = {5909},
	["Wiggler"] = {236, 237, 3065, 3297, 3429, 3723, 5912, 5914, 15793, 16122, 16127, 16142},
	["Wild Warrior"] = {2991, 3274, 3286, 3352, 3353, 3359, 3409, 3411, 3606},
	["Willi Wasp"] = {3054, 5902, 9057},
	["Wilting Leaf Golem"] = {3032, 3723, 17824, 19110, 19111},
	["Winter Wolf"] = {10295},
	["Wisp"] = {9604},
	["Witch"] = {3012, 3069, 3083, 3290, 3293, 3552, 3562, 3565, 3598, 3736, 9652, 9653, 10294, 12548},
	["Wolf"] = {5897},
	["Worker Golem"] = {238, 239, 953, 3028, 3048, 3061, 3279, 5880, 7428, 7439, 7452, 7642, 8775, 8895, 8898, 9063, 9655},
	["Wyrm"] = {236, 237, 816, 3028, 3349, 3449, 7430, 8027, 8043, 8045, 8092, 8093, 9304, 9665},
	["Wyvern"] = {236, 3010, 3029, 3071, 3450, 7408, 9644},
	["Xenia"] = {3114, 3273, 3426},
	["Yaga the Crone"] = {3012, 3069, 3083, 3454, 3562, 3565, 3598, 3736, 8074, 12548},
	["Yakchal"] = {238, 823, 824, 3052, 3079, 3085, 3324, 3333, 3732, 5912, 7290, 7410, 7439, 7440, 7443, 7449, 7459, 9058},
	["Yeti"] = {2992, 3553},
	["Yielothax"] = {236, 237, 816, 822, 3028, 3034, 3048, 3073, 3326, 3725, 7440, 9304, 12737, 12742, 12805},
	["Young Sea Serpent"] = {236, 237, 3029, 3049, 3061, 3266, 3282, 3305, 8894, 8895, 9666},
	["Young Troll"] = {3003, 3277, 3355, 3412, 3552, 9689},
	["Zanakeph"] = {238, 239, 2903, 3029, 3032, 3360, 3370, 3385, 3392, 5741, 5925, 6299, 6499, 7430, 7642, 8057, 8896, 9058, 10316, 10451, 12304},
	["Zarabustor"] = {825, 3006, 3029, 3051, 3299, 3324, 3567, 7368},
	["Zavarash"] = {238, 281, 3038, 3340, 3414, 3415, 3420, 5954, 7387, 7421, 7428, 7642, 8063, 16119, 16120, 16121, 20062, 20276},
	["Zevelon Duskbringer"] = {236, 3098, 3434, 7419, 8192},
	["Zomba"] = {3052, 3084, 9691},
	["Zombie"] = {268, 3052, 3269, 3286, 3305, 3351, 3354, 3568, 8894, 9659},
	["Blood Beast"] = {21195, 9640, 21194, 21146, 236, 7366, 21179, 21158, 21178, 21183, 21180},
	["Bullwark"] = {3028, 3033, 239, 238, 21199, 21200, 5878, 5911, 21219},
	["Death Priest Shargon"] = {238, 239, 9058, 9056, 3069, 8531},
	["Devourer"] = {3028, 3033, 3032, 3030, 9057, 3029, 21182, 21179, 21180, 21178, 21158, 21183, 8084, 3034, 3037, 21164},
	["Execowtioner"] = {9057, 3030, 11472, 21201, 5944, 239, 238, 5911, 3318, 7412, 3381, 21176, 7401},
	["Glooth Anemone"] = {9057, 3032, 21144, 3732, 21197, 236, 237, 21180, 21178, 21179, 21172, 21164, 7643},
	["Glooth Blob"] = {9057, 3033, 21182, 21183, 21180, 21178, 21179},
	["Glooth Fairy"] = {3030, 3033, 3028, 3029, 21158, 21178, 21183, 21180, 21167, 239, 21292, 21144, 21143, 21103, 5880, 8775},
	["Glooth Golem"] = {21103, 21143, 238, 7643, 3032, 9057, 3037, 8775, 21158, 21180, 21179, 21178, 5880, 21170, 21183, 21167, 21165, 3038},
	["Lisa"] = {3028, 3033, 9057, 3030, 239, 238, 7642, 21144, 21146, 21143, 21158, 21197, 21183, 21179, 21180, 21218},
	["Metal Gargoyle"] = {236, 237, 21193, 21171, 21169, 21168, 3051, 3052, 10310, 8082},
	["Minotaur Amazon"] = {7368, 5878, 11472, 3032, 3033, 3030, 9057, 239, 238, 21204, 3098, 5911, 21174, 21175},
	["Minotaur Hunter"] = {11472, 3033, 3030, 237, 236, 7378, 3147, 3347, 5944, 3037, 3039, 5878, 3049, 5912, 5910, 5911, 21175, 7401},
	["Mooh'Tah Warrior"] = {11472, 21202, 3032, 3030, 9057, 3032, 3033, 237, 236, 3091, 5911, 21177, 3415, 3371, 3370, 21166, 7401},
	["Moohtant"] = {21200, 3028, 3030, 238, 3098, 5911, 21199, 3037, 7427, 21173},
	["Rot Elemental"] = {3032, 9057, 3029, 236, 21182, 3052, 237, 21158, 21180, 21183},
	["Rustheap Golem"] = {21196, 3026, 3027, 953, 3279, 236, 237, 5880, 9016, 8894, 8897, 21170, 21171, 7452},
	["The Ravager"] = {238, 239, 3042, 3027, 3025},
	["Walker"] = {3032, 9057, 3033, 239, 7642, 21169, 21170, 21198, 3554},
	["Worm Priestess"] = {11472, 3028, 3033, 3032, 9057, 3029, 3030, 3037, 3039, 11473, 5878, 2920, 3066, 5912, 5911, 5910, 7425, 8082, 7401}
}

local SPELL_RANGE = {
	BIGWAVE = 1, -- Big Wave (flam hur, frigo hur)
	EXORI = 2, -- Adjacent (exori, exori gran)
	WAVE3X3 = 3, -- 3x3 Wave (vis hur, tera hur)
	SMALLAREA = 4, -- Small Area (mas san, exori mas)
	MEDIUMAREA = 5, -- Medium Area (mas flam, mas frigo)
	LARGEAREA = 6, -- Large Area (mas vis, mas tera)
	BEAM5 = 7, -- Short Beam (vis lux)
	BEAM8 = 8, -- Large Beam (gran vis lux)
	SWEEP = 9, -- Sweep (exori min)
	SMALLWAVE = 10 -- Small Wave (gran frigo hur)
}

local RUNE_RANGE = {
	EXPLO = 1, -- Cross (explosion)
	BOMB = 2, -- Bomb (fire bomb)
	THREE = 3, -- 3 Sqm
	BALL = 4, -- Ball (gfb, avalanche)
	FIVE = 5, -- 5 Sqm
	SIX = 6, -- 6 Sqm
	SEVEN = 7, -- 7 Sqm
	EIGHT = 8, -- 8 Sqm
	NINE = 9, -- 9 Sqm
	TEN = 10 -- 10 Sqm
}

local MAGIC_SHOOTER_ITEM = {
	-- Targeted Spells (type=0)

	['exori ico'] = {type=0, srange=1, mana=30},
	['exori gran ico'] = {type=0, srange=1, mana=300},
	['exori hur'] = {type=0, srange=5, mana=40},

	['exori san'] = {type=0, srange=4, mana=20},
	['exori con'] = {type=0, srange=7, mana=25},
	['exori gran con'] = {type=0, srange=7, mana=55},

	['exori moe ico'] = {type=0, srange=3, mana=20},

	['exori mort'] = {type=0, srange=3, mana=20},

	['exori infir vis'] = {type=0, srange=3, mana=6},
	['exori vis'] = {type=0, srange=3, mana=20},
	['exori amp vis'] = {type=0, srange=5, mana=60},
	['exori gran vis'] = {type=0, srange=3, mana=60},
	['exori max vis'] = {type=0, srange=3, mana=100},

	['exori min flam'] = {type=0, srange=3, mana=6},
	['exori flam'] = {type=0, srange=3, mana=20},
	['exori gran flam'] = {type=0, srange=3, mana=60},
	['exori max flam'] = {type=0, srange=3, mana=100},

	['exori frigo'] = {type=0, srange=3, mana=20},
	['exori gran frigo'] = {type=0, srange=3, mana=60},
	['exori max frigo'] = {type=0, srange=3, mana=100},

	['exori infir tera'] = {type=0, srange=3, mana=6},
	['exori tera'] = {type=0, srange=3, mana=20},
	['exori gran tera'] = {type=0, srange=3, mana=60},
	['exori max tera'] = {type=0, srange=3, mana=100},

	-- Area Spells (type=2)

	['exori'] = {type=2, srange=SPELL_RANGE.EXORI, mana=115},
	['exori gran'] = {type=2, srange=SPELL_RANGE.EXORI, mana=340},

	['exori mas'] = {type=2, srange=SPELL_RANGE.SMALLAREA, mana=160},
	['exevo mas san'] = {type=2, srange=SPELL_RANGE.SMALLAREA, mana=160},

	['exori min'] = {type=2, srange=SPELL_RANGE.SWEEP, mana=200},

	['exevo infir flam hur'] = {type=2, srange=SPELL_RANGE.BIGWAVE, mana=8},
	['exevo flam hur'] = {type=2, srange=SPELL_RANGE.BIGWAVE, mana=25},
	['exevo infir frigo hur'] = {type=2, srange=SPELL_RANGE.BIGWAVE, mana=8},
	['exevo frigo hur'] = {type=2, srange=SPELL_RANGE.BIGWAVE, mana=25},

	['exevo vis lux'] = {type=2, srange=SPELL_RANGE.BEAM5, mana=40},

	['exevo gran vis lux'] = {type=2, srange=SPELL_RANGE.BEAM8, mana=110},

	['exevo tera hur'] = {type=2, srange=SPELL_RANGE.WAVE3X3, mana=210},
	['exevo vis hur'] = {type=2, srange=SPELL_RANGE.WAVE3X3, mana=170},

	['exevo gran frigo hur'] = {type=2, srange=SPELL_RANGE.SMALLWAVE, mana=170},

	['exevo gran mas flam'] = {type=2, srange=SPELL_RANGE.MEDIUMAREA, mana=1100},
	['exevo gran mas frigo'] = {type=2, srange=SPELL_RANGE.MEDIUMAREA, mana=1050},

	['exevo gran mas vis'] = {type=2, srange=SPELL_RANGE.LARGEAREA, mana=600},
	['exevo gran mas tera'] = {type=2, srange=SPELL_RANGE.LARGEAREA, mana=700},

	-- Targeted Runes (type=1)
	[3155] = {type=1, srange=7}, -- sudden death
	[3189] = {type=1, srange=7}, -- fireball
	[3182] = {type=1, srange=7}, -- holy missile
	[3158] = {type=1, srange=7}, -- icicle
	[3165] = {type=1, srange=7}, -- paralyze
	[3195] = {type=1, srange=7}, -- soulfire
	[3198] = {type=1, srange=7}, -- heavy magic missle
	[3174] = {type=1, srange=7}, -- light magic missle
	[3179] = {type=1, srange=7}, -- stalagmite

	-- Area Runes (type=3)
	[3200] = {type=3, srange=RUNE_RANGE.EXPLO}, -- explosion

	[3192] = {type=3, srange=RUNE_RANGE.BOMB}, -- fire bomb
	[3149] = {type=3, srange=RUNE_RANGE.BOMB}, -- energy bomb
	[3173] = {type=3, srange=RUNE_RANGE.BOMB}, -- poison bomb

	[3161] = {type=3, srange=RUNE_RANGE.BALL}, -- avalanche
	[3191] = {type=3, srange=RUNE_RANGE.BALL}, -- great fireball
	[3175] = {type=3, srange=RUNE_RANGE.BALL}, -- stone shower
	[3202] = {type=3, srange=RUNE_RANGE.BALL} -- thunderstorm
}

local ITEM_LIST_POTIONS = {
	[236] = true,
	[237] = true,
	[238] = true,
	[239] = true,
	[266] = true,
	[268] = true,
	[7439] = true,
	[7440] = true,
	[7443] = true,
	[7642] = true,
	[7643] = true
}

local ITEM_LIST_ACTIVE_RINGS = {
	[3092] = 3095,
	[3091] = 3094,
	[3093] = 3096,
	[3052] = 3089,
	[3098] = 3100,
	[3097] = 3099,
	[3051] = 3088,
	[3053] = 3090,
	[3049] = 3086,
	[9593] = 9593,
	[9393] = 9392,
	[3007] = 3007,
	[6299] = 6300,
	[9585] = 9585,
	[3048] = 3048,
	[3050] = 3087,
	[3245] = 3245,
	[3006] = 3006,
	[349] = 349,
	[3004] = 3004,
	[16114] = 16264
}

local ITEM_LIST_RUSTYARMORS = {
	[8895] = true,
	[8896] = true,
	[8898] = true,
	[8899] = true
}

local ITEM_LIST_MONEY = {
	[3031] = true,
	[3035] = true,
	[3043] = true
}

local ITEM_LIST_FURNITURE_DESTROYERS = {
	[3267] = true,
	[3292] = true,
	[3291] = true
}

local RUNES_EXOTIC = {
	[3203] = true, -- animate dead rune
	[3147] = true, -- blank rune
	[3197] = true, -- desintegrate rune
	[3149] = true, -- energy bomb rune
	[3189] = true, -- fireball rune
	[3182] = true, -- holy missile rune
	[3158] = true, -- icicle rune
	[3180] = true, -- magic wall rune
	[3165] = true, -- paralyze rune
	[3173] = true, -- poison bomb rune
	[3195] = true, -- soulfire rune
	[3175] = true, -- stone shower rune
	[3202] = true, -- thunderstorm rune
	[3156] = true  -- wild growth rune
}

local RUNES_NORMAL = {
	[3161] = true, -- avalanche rune
	[3178] = true, -- chameleon rune
	[3177] = true, -- convince creature rune
	[3153] = true, -- cure poison rune
	[3148] = true, -- destroy field rune
	[3164] = true, -- energy field rune
	[3166] = true, -- energy wall rune
	[3200] = true, -- explosion rune
	[3192] = true, -- fire bomb rune
	[3188] = true, -- fire field rune
	[3190] = true, -- fire wall rune
	[3191] = true, -- great fireball rune
	[3198] = true, -- heavy magic missile rune
	[3152] = true, -- intense healing rune
	[3174] = true, -- light magic missile rune
	[3172] = true, -- poison field rune
	[3176] = true, -- poison wall rune
	[3179] = true, -- stalagmite rune
	[3155] = true, -- sudden death rune
	[3160] = true  -- ultimate healing rune
}

local EXOTIC_RUNE_TOWNS = {
	['Edron'] = true,
	['Gray Island'] = true,
	['Rathleton'] = true
}

local FISHING_RODS = {
	[3483] = true,
	[9306] = true
}

local ROPE_TOOLS = {
	[3003] = 0,
	[646] = 1,
	[9594] = 2,
	[9596] = 3,
	[9598] = 4
}

local SHOVEL_TOOLS = {
	[3457] = 0,
	[5710] = 1,
	[9594] = 2,
	[9596] = 3,
	[9598] = 4
}

local PICK_TOOLS = {
	[3456] = true,
	[9594] = true,
	[9596] = true,
	[9598] = true
}

local RODS = {
	[3065] = true,
	[3066] = true,
	[3067] = true,
	[3069] = true,
	[3070] = true,
	[8082] = true,
	[8083] = true,
	[8084] = true,
	[16117] = true,
	[16118] = true
}

local WANDS = {
	[3071] = true,
	[3072] = true,
	[3073] = true,
	[3074] = true,
	[3075] = true,
	[8092] = true,
	[8093] = true,
	[8094] = true,
	[12603] = true,
	[16096] = true,
	[16115] = true
}

local DISTANCE_WEAPONS = {
	[3277] = true,
	[7378] = true,
	[3347] = true,
	[7367] = true,
	[1781] = true,
	[3287] = true,
	[3298] = true,
	[7366] = true,
	[7368] = true,
	[20082] = true,
	[20083] = true,
	[20084] = true,
	[20085] = true,
	[20086] = true,
	[20087] = true
}

local NORMAL_BOOTS = {
	[10201] = true,
	[3246] = true,
	[3550] = true,
	[3553] = true,
	[10200] = true,
	[13997] = true,
	[3555] = true,
	[16112] = true,
	[4033] = true,
	[3079] = true,
	[10323] = true,
	[3554] = true,
	[818] = true,
	[813] = true,
	[819] = true,
	[820] = true,
	[10386] = true,
	[5461] = true,
	[7457] = true,
	[9017] = true,
	[3556] = true,
	[3552] = true,
	[3551] = true
}

local DEPOT = {
	SLOT_NONSTACK = 0,
	SLOT_STACK = 1,
	SLOT_SUPPLY = 2
}
