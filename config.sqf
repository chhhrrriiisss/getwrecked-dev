//
//
//
//		Game configuration variables
//
//
//

// Leaderboard stats tracking (default: false)
// Please message @getwreckeda3 (Sli) if you'd like to get this working as it involves the use of a third party add on
GW_LEADERBOARD_ENABLED = true;

// Spawn timer in seconds (default: 30)
GW_RESPAWN_DELAY = 30;

// Vehicle Respawn Settings (default: 10)
GW_ABANDON_DELAY = 10;

// Object respawn settings (default: 3, .5)
GW_OBJECT_ABANDON_DELAY = 3;
GW_OBJECT_DEAD_DELAY = .5;

// Damage system to use for vehicles (default: 2)
GW_DAMAGE_SYSTEM = 2; // 1 == (old)  // 2 == v2 (new)

// Weapon Damage vs vehicles 
GW_GDS = 0.2; 
WHEEL_COLLISION_DMG_SCALE = 0; 
COLLISION_DMG_SCALE = 0; 
FIRE_DMG_SCALE = 18; 
MORTAR_DMG_SCALE = (5 * GW_GDS); 
TITAN_AT_DMG_SCALE = (2 * GW_GDS); 
RPG_DMG_SCALE = (0.5 * GW_GDS); 
GUD_DMG_SCALE = (20 * GW_GDS);
HMG_DMG_SCALE = (7 * GW_GDS); 
LMG_DMG_SCALE = (3 * GW_GDS); 
HMG_HE_DMG_SCALE = (4 * GW_GDS); 
HMG_IND_DMG_SCALE = (4 * GW_GDS); 
GMG_DMG_SCALE = (0.9 * GW_GDS); 
EXP_DMG_SCALE = (5 * GW_GDS); 
LSR_DMG_SCALE = (1 * GW_GDS);
FLM_DMG_SCALE = (0 * GW_GDS); 
RLG_DMG_SCALE = 1 * GW_GDS; 

// Weapon Damage vs objects
GW_GHS = 4;
OBJ_COLLISION_DMG_SCALE = 1;
OBJ_MORTAR_DMG_SCALE = (40 * GW_GHS);
OBJ_TITAN_AT_DMG_SCALE = (20 * GW_GHS);
OBJ_RPG_DMG_SCALE = (10 * GW_GHS);
OBJ_GUD_DMG_SCALE = (20 * GW_GHS);
OBJ_HMG_DMG_SCALE = (6 * GW_GHS);
OBJ_LMG_DMG_SCALE = (10 * GW_GHS);
OBJ_HMG_HE_DMG_SCALE = (1 * GW_GHS);
OBJ_GMG_DMG_SCALE = (15 * GW_GHS);
OBJ_EXP_DMG_SCALE = (40 * GW_GHS);
OBJ_LSR_DMG_SCALE = (4 * GW_GHS);
OBJ_FLM_DMG_SCALE = (4 * GW_GHS);
OBJ_RLG_DMG_SCALE = 20 * GW_GHS;

// Lock on properties
GW_MINLOCKRANGE = 100; // (default: 100)
GW_MAXLOCKRANGE = 2500; // (default: 2500)
GW_MINLOCKTIME = 3; // Minimum amount of time to lock onto a target (default: 3)
GW_LOCKON_TOLERANCE = 10; // Difference in angle needed to acquire target (default: 10)

// Deployable items
GW_MAXDEPLOYABLES = 50; // Per player (default :50)

// Render distance of effects
GW_EFFECTS_RANGE = 1700; // Increasing this may add lag at the workshop (default: 2000)

// Value modifier for killed vehicles
GW_KILL_VALUE = 0.5; // How much of the vehicles value should the killer get? (default: 0.5)
GW_KILL_EMPTY_VALUE = 0.1;

// % Chance of eject system failing
GW_EJECT_FAILURE = 15;

// Default player start balance
GW_INIT_BALANCE = 5000; // (Default: 5000)

// Limit for supply boxes
GW_INVENTORY_LIMIT = 40; // (Default: 40)

// Supply Crates
GW_EVENTS_FREQUENCY = [(60), (45), 30]; // Frequency to perform checks for events (low/med/high pop) (default: 60, 45, 30)
GW_SUPPLY_ACTIVE = 0; // Dont change this
GW_SUPPLY_MAX = 30; // Maximum number of supply boxes active at once (default: 30)
GW_SUPPLY_CLEANUP = (3*60); // 10 Minute timeout before cleanup (default: (3*60) )

/*	
	If you edit below here, I hope you know what you're doing...
*/

// Available arenas and game type
GW_VALID_ZONES = [
	
	['swamp', 'battle'],
	['airfield', 'battle'],
	['downtown', 'battle'],
	['wasteland', 'battle'],
	['saltflat', 'battle'],	
	// ['highway', 'race'], Disabled until race game mode complete
	['workshop', 'safe']
];

// Default locked vehicles
GW_LOCKED_ITEMS = [
	
	"I_MRAP_03_F",
	"O_MRAP_02_F",
	"B_MRAP_01_F",

	"B_Truck_01_mover_F",
	"B_Truck_01_transport_F",
	"O_Truck_03_transport_F",
	"I_Truck_02_transport_F",

	"C_Kart_01_F",
	"C_SUV_01_F",
	"C_Van_01_box_F",
	"C_Offroad_01_F"

];

// Objects that cant be cleared by clearPad
GW_UNCLEARABLE_ITEMS = [

    'Land_spp_Transformer_F',
    'Land_HelipadSquare_F',
    'Land_File1_F',
    'Camera',
    'HouseFly',
    'Mosquito',
    'HoneyBee',
    '#mark',
    '#track',
    'Land_Bucket_painted_F',
    'UserTexture1m_F',
    'SignAd_Sponsor_ARMEX_F',
    'Land_Tyres_F'

];

GW_PROTECTED_ITEMS = [

	'Land_PaperBox_closed_F'
	
];

// Objects that cant be tilted (due to various bugs)
GW_TILT_EXCLUSIONS = [
	"Land_New_WiredFence_5m_F",
	"B_HMG_01_A_F",
	"B_GMG_01_A_F",
	"B_static_AT_F",
	"B_Mortar_01_F",
	"Land_Runway_PAPI",
	"launch_NLAW_F",
	"launch_RPG32_F",
	"srifle_LRR_LRPS_F",
	"Land_WaterTank_F"
];

// Weapons that use the lock-on mechanic
GW_LOCKONWEAPONS = [
	'MIS',
	'MOR'
];

// Weapons reference
GW_WEAPONSARRAY = [
	'HMG',
	'GMG',	
	'MOR',
	'RPG',
	'MIS',
	'GUD',
	'LSR',
	'RLG',
	'FLM',
	'HAR',
	'LMG'
];

// Weapons that use groundWeaponsHolder 
GW_HOLDERARRAY = [
	'launch_NLAW_F',
	'launch_RPG32_F',
	"srifle_LRR_LRPS_F",
	"srifle_GM6_F",
	"LMG_Zafir_F"
];


// Modules with an action menu ability
GW_TACTICALARRAY = [
	'SMK',
	'NTO',
	'OIL',
	'REP',
	'DES',
	'EMP',
	'PAR',
	'CAL',
	'SHD',
	'THR',
	'MIN',
	'EPL',
	'CLK',
	'MAG',
	'GRP',
	'JMR'
];

// Modules without an action menu entry, but that still do something
GW_SPECIALARRAY = [
	'IND',
	'EXP',
	'FRK'
];

// Texture selection config for specific vehicles
GW_TEXTURES_SPECIAL = [
	
	['C_SUV_01_F', [""]],
	['B_Truck_01_mover_F', ["B_Truck_01_mover_F", "default"] ],
	['B_Truck_01_transport_F', ["B_Truck_01_mover_F", "default"] ],
	["I_Truck_02_transport_F", ["default", "default"] ],
	['C_Hatchback_01_sport_F', [""]],
	['C_Van_01_transport_F', ["", "default"]]
];

GW_SPECIAL_TEXTURES_LIST = [
	'shield',
	'armor',
	'jammer',
	'speed'
];

// Available textures
GW_TEXTURES_LIST = [
	'Blue',
	'Digital',
	'Fire',
	'Leafy',
	'Red',
	'Safari',
	'White',
	'Yellow',
	'Camo',
	'Pink'
];

// Available taunts
GW_TAUNTS_LIST = [
	'toot',
	'horn',
	'squirrel',
	'surprise',
	'batman',
	'hax',
	'headshot',
	'herewego',
	'mlg',
	'party',
	'sparta'
];

