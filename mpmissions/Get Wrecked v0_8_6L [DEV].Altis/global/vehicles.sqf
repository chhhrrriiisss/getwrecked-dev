//
//
//		Vehicle Configuration
//		NOTE: To add additional or modded vehicles, please use custom.sqf instead
//		This just makes it easier to update the mission file in the future without breaking modded configs
//
//

GW_VEHICLE_LIST = [

	// Civilian

	[
		"C_Quadbike_01_F", // Class for this vehicle
		"Quadbike", // Display Name
		'The quadbike is ideal for fast and stealthy surprise attacks.', // Vehicle description
		[
			[
				0.05, // Mass Modifier [ Decrease to allow this vehicle to carry more weight ]
				850 // Mass limit [ Max weight cap at which adding more parts doesn't change vehicle agility ]
			],
			3, // Max Weapons
			3, // Max Modules
			1, // Default Ammo Capacity
			1, // Default Fuel Capacity
			2, // Armor Rating [ Doesnt impact gameplay, modifies visible armor rating in attributes list ]
			1.1, // Armor Modifier [ Lower value to increase time to kill, keep within 0.9 - 1.3 for best effect ]
			'Tiny', // Radar Signature [ Tiny | Low | Medium | Large ]
			1000 // ?
		],
		0 // Vehicle availability [ -1 Unspawnable, 0 Unlocked, > 0 Locked (And cost to unlock) ]
	],

	["C_Hatchback_01_sport_F", "Hatchback Sport", 'Although very lightly armoured, this vehicle is fast and difficult to catch.', [ [0.1, 3000], 3, 4, 1, 2, 3, 1.05, 'Low', 1000 ], 1000 ],
	["C_Offroad_01_F", "Civilian Offroad", 'The offroad is an agile, versatile albeit lightly armored utility vehicle.', [ [0.2, 99999], 3, 5, 2, 1, 5, 1, 'Low', 1000 ], 0 ],
	["C_SUV_01_F", "SUV", 'A capable and reliable vehicle with a low radar signature.', [ [0.1, 3000] , 3, 4, 1, 2, 4, 0.95, 'Low', 1000 ], 5000 ],
	["C_Van_01_transport_F", "Civilian Truck", 'Ample storage, fuel and ammo capacity, a great workhorse.', [ [0.5, 99999], 2, 7, 2, 2, 5, 1, 'Medium', 1000 ], 0 ],
	["C_Van_01_box_F", "Box Truck", 'An excellent choice for an especially special delivery.', [ [0.5, 99999], 2, 10, 1, 3, 5, 1, 'Large', 1000 ], 3000 ],
	["C_Kart_01_F", "Kart",  'Extremely quick and hard to hit which makes it quite unpredictable.', [ [0.03, 350], 2, 3, 1, 1, 1, 1.1, 'Tiny', 1000 ], 5000 ],

	// Trucks

	["C_Van_01_fuel_F", "Civilian Fuel Truck", 'Surprisingly sturdy unit with extra fuel capacity.', [ [0.5, 99999], 2, 4, 1, 10, 4, 1.1, 'Small', 1000 ], 6000 ],
	["O_truck_02_fuel_f", "Zamak Tanker", 'A fuel tank with additional wheels.', [ [0.1, 99999], 4, 5, 0.5, 18, 8, 1.1, 'Medium', 1000 ],  14000 ],
	["O_truck_03_ammo_f", "Tempest Ammo", 'For those in need of a fair few bullets.', [ [0.1, 99999], 6, 4, 22, 2, 8, 1.15, 'Large', 1000 ],  16000 ],

	["B_Truck_01_mover_F", "HEMTT Mover",  'A tough rig that can withstand quite a few hits.', [ [0.1, 99999], 3, 7, 3, 3, 8, 1, 'Medium', 1000 ], 7500 ],
	["B_Truck_01_transport_F", "HEMTT Transport", 'A slightly tougher HEMTT with upgraded storage.', [ [0.1, 99999], 3, 9, 5, 3, 8, 1, 'Large', 1000 ],  10000 ],
	["I_Truck_02_transport_F", "Zamak Truck", 'Smartly built, this clever rig presents lots of opportunities.', [ [0.1, 99999], 3, 8, 4, 2, 7, 1, 'Large', 1000 ],  12000 ],

	// Military

	["B_T_LSV_01_unarmed_F", "Prowler", 'Lightweight and agile offroad predator.', [ [0.9, 99999], 4, 3, 1, 1, 6, 1, 'Medium', 4000 ],  10000 ],
	["I_MRAP_03_F", "Strider", 'A fast, heavily armoured amphibious assault vehicle.', [ [2.25, 99999], 5, 3, 2, 0.5, 9, 1.22, 'Medium', 4000 ],  25000 ],
	["B_MRAP_01_F", "Hunter",  'An armoured jack of all trades.', [ [1.75, 99999], 4, 4, 2, 1, 8, 1.09, 'Medium', 3500 ], 20000 ],
	["O_MRAP_02_F", "Ifrit", 'Trades speed for upgraded armor and marginally better looks.', [ [1.5, 99999], 5, 3, 2, 0.75, 7, 1.13, 'Large', 1000 ], 15000 ],

	// AI Only

	["B_APC_Tracked_01_AA_F", "Cheetah", 'Ass-kicking wheeled vehicle of death.', [ [1.5, 99999], 10, 10, 2, 0.75, 20, 0.3, 'Large', 1000 ],  -1 ],
	["B_APC_Tracked_01_CRV_F", "Bobcat", 'Ass-kicking wheeled vehicle of death.', [ [1.5, 99999], 10, 10, 2, 0.75, 20, 0.7, 'Large', 1000 ],  -1 ],
	["I_APC_tracked_03_cannon_F", "Mora", 'Ass-kicking wheeled vehicle of death.', [ [1.5, 99999], 10, 10, 2, 0.75, 20, 0.9, 'Medium', 1000 ],  -1 ]

];
