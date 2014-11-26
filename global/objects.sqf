// 0 Class Name, 1 Name, 2 Mass, 3 Health, 4 Ammo, 5 Fuel, 6 Module 7 Description 8 Rarity

GW_LOOT_LIST = [	

	// Building Supplies 

	["Land_CnCBarrier_stripes_F", "Concrete Barrier", 600, 6, 0, 0, '', "", 0, barrierIcon],
	["Land_BagFence_Short_F", "Sandbag", 200, 4, 0, 0, '', "", 0, sandbagsIcon],
	["Land_BagFence_Long_F", "Long Sandbag", 400, 4, 0, 0, '', "", 0, sandbagsIcon],
	["Land_BagFence_Round_F", "Curved Sandbag", 500, 4, 0, 0, '', "", 1, sandbagsIcon],
	["Land_Wall_Tin_4", "Light Metal Sheet", 150, 4, 0, 0, '', "", 0.1, metalfenceIcon],
	["Land_Wall_IndCnc_2deco_F", "Large Steel Panel", 1500, 20, 0, 0, '', "", 1, steelPanelIcon],
	["Land_CnCBarrierMedium4_F", "Long Concrete Wall", 8000, 12, 0, 0, '', "", 1, concretebarrierlargeIcon],
	["Land_CnCBarrierMedium_F", "Short Concrete Wall", 2000, 4, 0, 0, '', "", 0.2, concretebarrierIcon],
	["Land_Shoot_House_Wall_Prone_F", "Plywood Barrier", 50, 3, 0, 0, '', "", 0, plywoodIcon],
	["Land_Shoot_House_Corner_Crouch_F", "Plywood Corner", 50, 3, 0, 0, '', "", 0, plywoodIcon],
	["Land_Shoot_House_Wall_Crouch_F", "Plywood Wall", 50, 6, 0, 0, '', "", 0, plywoodIcon],
	["Land_Pallets_F", "Wooden Pallets", 50, 2, 0, 0, '', "", 0, palletsIcon],
	["Land_Pallet_vertical_F", "Vertical Wooden Pallets", 50, 2, 0, 0, '', "", 0.1, palletsIcon],
	["Land_New_WiredFence_5m_F", "Wired Fence", 100, 6, 0, 0, '', "", 0.25, wirefenceIcon],

	// Weapons

	["B_HMG_01_A_F", "HMG .50 Cal", 400, 9999, 0, 0, 'HMG', "High calibre machine gun", 0.1, hmgIcon],
	["B_GMG_01_A_F", "GMG 20mm HE", 500, 9999, 0, 0, 'GMG', "High explosive grenade launcher", 0.3, gmgIcon],
	["B_static_AT_F", "Lock-On Missile Launcher", 1000, 9999, 0, 0, 'MIS', "Fires heat seeking missiles", 1, lockonIcon],
	["B_Mortar_01_F", "Mk6 Mortar", 750, 9999, 0, 0, 'MOR', "Heat seeking mounted mortar", 0.1, mortarIcon],
	["Land_Runway_PAPI", "Tactical Laser", 400, 9999, 0, 0, 'LSR', "High Energy Laser", 0.9, laserIcon],
	["launch_NLAW_F", "Guided Missile", 750, 9999, 0, 0, 'GUD', "Guided Missile", 1, guidedIcon], 
	["launch_RPG32_F", "Rocket Launcher", 750, 9999, 0, 0, 'RPG', "Rocket Launcher", 0.3, rpgIcon],
	["srifle_LRR_LRPS_F", "SR2 Railgun", 750, 9999, 0, 0, 'RLG', "Railgun", 1, railgunIcon],
	["Land_DischargeStick_01_F", "Flamethrower", 750, 9999, 0, 0, 'FLM', "Flamethrower", 1, flameIcon],

	// Fuel

	["Land_MetalBarrel_F", "Large Fuel Tank",  1500, 8, 0, 3, '', "", 0.4, fuelIcon],	
	["Land_CanisterPlastic_F", "Fuel Tank",  500, 4, 0, 1, '', "", 0.2, fuelIcon],
	["Land_CanisterFuel_F", "Small Fuel Container",  250, 4, 0, 0.5, '', "", 0.1, fuelIcon],

	// Ammo

	["Box_NATO_Ammo_F", "Small Ammo Box", 500, 8, 1, 0, '', "", 0.2, ammoIcon],
	["Box_Nato_AmmoVeh_F", "Large Ammo Container",  2000, 16, 4, 0, '', "", 0.8, ammoIcon],

	// Special

	["Box_East_AmmoOrd_F", "Incendiary Ammo", 500, 8, 0.3, 0, 'IND', "Hit vehicles will be set alight", 1, flameIcon],
	["Box_IND_Grenades_F", "HE Ammo", 500, 8, 0.3, 0, 'EXP', "Projectiles have a small explosive effect", 1, minesIcon],	

	// Claw [Disabled]
	// ["Land_PalletTrolley_01_khaki_F", "Metal Forks", 1000, 8, 0, 0, 'FRK', "Used to damage vehicles at close range", 1, warningIcon],	

	// Tactical	

	["Land_Portable_generator_F", "Nitro Booster",  125, 8, 0, 0, 'NTO', "Increases vehicle speed temporarily", 0.5, nitroIcon],
	["Land_FireExtinguisher_F", "Smoke Generator",  50, 5, 0, 0, 'SMK', "Generates white smoke", 0.25, smokeIcon],
	["Land_WaterTank_F", "Oil Slick",  500, 10, 0, 1, 'OIL', "", 0.2, oilslickIcon],
	["Land_PowerGenerator_F", "Emergency Repair Device",  1000, 10, 0, 0, 'REP', "Instantly repairs the vehicle", 0.6, emergencyRepairIcon],
	["Land_Device_assembled_F", "Self Destruct System",  400, 30, 0, 0, 'DES', "", 0.8, warningIcon],
	["Land_BarrelEmpty_grey_F", "Vertical Thruster",  50, 8, 0, 0, 'THR', "Activates a short burst of downward force", 0.6, thrusterIcon],
	["Land_BarrelEmpty_F", "Cloaking Device",  50, 8, 0, 0, 'CLK', "Temporarily gives the vehicle near-invisibility", 1, cloakIcon],
	["Land_Suitcase_F", "EMP Device",  50, 8, 0, 0, 'EMP', "Deploys a pulse that disables vehicles", 0.7, empIcon],
	["Land_Sack_F", "Eject System",  5, 500, 0, 0, 'PAR', "Ejects the driver and deploys a parachute", 0.2, ejectIcon],
	["Land_WoodenBox_F", "Caltrops",  5, 500, 0, 0, 'CAL', "Drops road spikes that disable tyres", 0.25, caltropsIcon],
	["Land_Sacks_heap_F", "Bag of Explosives",  5, 500, 0, 0, 'EPL', "Deploys an especially large bag of explosives", 0.1, warningIcon],
	["Land_FoodContainer_01_F", "Proximity Mines",  5, 500, 0, 0, 'MIN', "Drops a handful of mines", 0.7, minesIcon],
	["Box_IND_Wps_F", "Shield Generator",  5, 500, 0, 0, 'SHD', "Shield that grants temporary invulnerability", 1, shieldIcon],
	["Land_Coil_F", "Magnetic Coil",  5, 6000, 0, 0, 'MAG', "Deploys a magnetic pulse that pulls in vehicles", 1, magneticIcon]

];


// Price List and Categories for all loot

// Building
GW_LOOT_BUILDING = [
	["Land_CnCBarrier_stripes_F", 25],
	["Land_BagFence_Short_F", 20],
	["Land_BagFence_Long_F", 40],
	["Land_BagFence_Round_F", 50],
	["Land_Wall_Tin_4", 50],
	["Land_Wall_IndCnc_2deco_F", 200],
	["Land_CnCBarrierMedium4_F", 100],
	["Land_CnCBarrierMedium_F", 25],
	["Land_Shoot_House_Wall_Prone_F", 10],
	["Land_Shoot_House_Corner_Crouch_F", 10],
	["Land_Shoot_House_Wall_Crouch_F", 10],
	["Land_Pallets_F", 20],
	["Land_Pallet_vertical_F", 20],
	["Land_New_WiredFence_5m_F", 30]
];

// Weapons
GW_LOOT_WEAPONS = [
	["B_HMG_01_A_F", 100],
	["B_GMG_01_A_F", 150],
	["B_static_AT_F", 300],
	["B_Mortar_01_F", 200],
	["Land_Runway_PAPI", 400],
	["launch_NLAW_F", 300],
	["launch_RPG32_F", 200],
	["srifle_LRR_LRPS_F", 600],
	["Land_DischargeStick_01_F", 300]
];

// Performance
GW_LOOT_PERFORMANCE = [
	["Land_MetalBarrel_F", 300],
	["Land_CanisterPlastic_F", 150],
	["Land_CanisterFuel_F", 75],
	["Land_Portable_generator_F", 100],
	["Box_NATO_Ammo_F", 150], 
	["Box_Nato_AmmoVeh_F", 300]
];

// Incendiary
GW_LOOT_INCENDIARY = [
	["Land_WaterTank_F", 100],
	["Box_East_AmmoOrd_F", 400],
	["Box_IND_Grenades_F", 300],
	["Land_FireExtinguisher_F", 100],
	["Land_Runway_PAPI", 400],
	["Land_DischargeStick_01_F", 300]
];

// Electronics
GW_LOOT_ELECTRONICS = [
	["Land_BarrelEmpty_F", 400],
	["Land_Suitcase_F", 200],
	["launch_NLAW_F", 300],
	["Land_Coil_F", 1000]
];


// Deployables
GW_LOOT_DEPLOYABLES = [
	["Land_Sacks_heap_F", 50],
	["Land_WoodenBox_F", 200],
	["Land_FoodContainer_01_F", 500],
	["Land_WaterTank_F", 100]
];

// Defense
GW_LOOT_DEFENCE = [
	["Land_PowerGenerator_F", 400],
	["Box_IND_Wps_F", 500],
	["Land_Wall_IndCnc_2deco_F", 200],
	["Land_Device_assembled_F", 250],
	["Land_PalletTrolley_01_khaki_F", 300]
];

// Evasion
GW_LOOT_EVASION = [
	["Land_Portable_generator_F", 100],
	["Land_Sack_F", 100],
	["Land_FireExtinguisher_F", 100],
	["Land_BarrelEmpty_grey_F", 100],
	["Land_Device_assembled_F", 250]
];

GW_LOOT_VEHICLES = [

	// Civilian
	
	["C_Offroad_01_F", 3000],
	["C_SUV_01_F", 5000],
	["C_Van_01_box_F", 1000],
	["C_Hatchback_01_sport_F", 1000],	
	["C_Kart_01_F", 5000],
	["C_Quadbike_01_F", 1000],

	// Trucks

	["B_Truck_01_mover_F", 7500],
	["B_Truck_01_transport_F", 10000],
	["O_Truck_03_transport_F", 10000],
	["I_Truck_02_transport_F", 12000],

	// Military

	["I_MRAP_03_F", 25000],
	["B_MRAP_01_F", 20000],
	["O_MRAP_02_F", 15000]

];