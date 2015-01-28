// Supply box custom effects
GW_SUPPLY_TYPES = [

	[		
		"care",
		0.4,
		randomSign,
		{	
			_crate = _this;
			_vehicle = (vehicle player);
			_vehicle setVariable ['fuel', (_vehicle getVariable ['maxFuel', 1]), true];				
			_vehicle setFuel 1;
			_vehicle setVariable ['ammo', (_vehicle getVariable ['maxAmmo', 1]), true];			
			_vehicle setDammage 0;

			['VEHICLE REFUELLED!', 0.75, fuelIcon, nil, "slideDown"] spawn createAlert; 
			Sleep 1.2;
			['VEHICLE REARMED!', 0.75, ammoIcon, nil, "slideDown"] spawn createAlert; 
			Sleep 1.2;
			['VEHICLE REPAIRED!', 0.75, healthIcon, nil, "slideDown"] spawn createAlert; 
		}
	],

	[		
		"money",
		0.5,
		randomSign,
		{	
			_crate = _this;
			_amount = ((random 15000) + 15000);
			_amount call changeBalance;
			[		
				[
					(vehicle player),
					"money",
					40
				],
				"playSoundAll",
				true,
				false
			] call BIS_fnc_MP;	 

			[ format['RECEIVED $%1!', ([_amount] call numberToCurrency)], 2, successIcon, nil, "slideDown"] spawn createAlert; 
		}
	],

	[		
		"pink",
		0.7,
		randomSign,
		{	
			_crate = _this;
			_vehicle = (vehicle player);
			// Spray paint sound effect
			[		
				[
					_vehicle,
					"paint",
					100
				],
				"playSoundAll",
				true,
				false
			] call BIS_fnc_MP;	 

			[[_vehicle,'Pink'],"setVehicleTexture",true,false] call BIS_fnc_MP;
		}
	],

	[		
		"tp",
		0.5,
		randomSign,
		{	
			_crate = _this;			
			_vehicle = (vehicle player);
			_vehicle setVariable ['status', [], true];

			

			_pos = (ASLtoATL getPosASL _vehicle);
			_newPos = GW_CURRENTZONE call findLocationInZone;

			playSound3D ["a3\sounds_f\sfx\special_sfx\sparkles_wreck_2.wss", _vehicle, false, (_pos), 2, 1, 150];
			playSound3D ["a3\sounds_f\sfx\earthquake1.wss", _vehicle, false, _pos, 10, 1, 150];

			[
				[
				_vehicle,
				3
				],
				"magnetEffect"
			] call BIS_fnc_MP;

			_vehicle setPos _newPos;
			
		}
	],

	[		
		"tpto",
		0.7,
		randomSign,
		{	
			_crate = _this;			
			_vehicle = (vehicle player);
			_vehicle setVariable ['status', [], true];		

			_vehiclesInZone = [GW_CURRENTZONE] call findAllInZone;

			_newPos = (getPos _vehicle);

			{
				if (_x != _vehicle) exitWith {
					_newPos = _x modelToWorldVisual [0, -40 + (random 10), 0];
				};

			} count _vehiclesInZone > 0;

			_pos = (ASLtoATL getPosASL _vehicle);
		
			playSound3D ["a3\sounds_f\sfx\special_sfx\sparkles_wreck_2.wss", _vehicle, false, (_pos), 2, 1, 150];
			playSound3D ["a3\sounds_f\sfx\earthquake1.wss", _vehicle, false, _pos, 10, 1, 150];

			[
				[
				_vehicle,
				3
				],
				"magnetEffect"
			] call BIS_fnc_MP;

			_vehicle setPos _newPos;
			
		}
	],


	[		
		"emp",
		0.7,
		randomSign,
		{	
			_crate = _this;
			_vehiclesInZone = [GW_CURRENTZONE] call findAllInZone;

			{
				[       
					[
						_x,
						['emp'],
						10
					],
					"addVehicleStatus",
					_x,
					false 
				] call BIS_fnc_MP; 	

				false

			} count _vehiclesInZone > 0;		

		}
	],

	[		
		"damage", // not working right now
		1.1,
		damageSign,
		{	
			_crate = _this;
			(vehicle player) setVariable ['status', [], true];

			[
				[
					(vehicle player),
					15,
					[0.812,0.208,0.22,0.05]
				],
				"shieldEffect"
			] call BIS_fnc_MP;

			[(vehicle player), ['extradamage'], 30] call addVehicleStatus;
			['EXTRA DAMAGE', 30, damageSupplyIcon, { ("extradamage" in ((vehicle player) getVariable ['status', []])) }] spawn createNotification;
		}
	],

	[		
		"speed",
		0.5,
		speedSign,
		{	
			_crate = _this;
			_condition = { ("overcharge" in ((vehicle player) getVariable ['status', []])) };
			_maxTime = 45;
			_vehicle = (vehicle player);
			_vehicle setVariable ['status', [], true];

			[_vehicle, ['overcharge'], _maxTime] call addVehicleStatus;
			[_vehicle, _maxTime, 'client\images\power_halo.paa', _condition] spawn createHalo;
			[_vehicle, 'client\images\vehicle_textures\special\speed.jpg', _maxTime, _condition] spawn swapVehicleTexture;
			['OVERCHARGE', _maxTime, speedSupplyIcon] spawn createNotification;
		}
	],

	[		
		"armor",
		0.5,
		armorSign,
		{	
			_crate = _this;
			_condition = { ("nanoarmor" in ((vehicle player) getVariable ['status', []])) };
			_maxTime = 60;
			_vehicle = (vehicle player);
			_vehicle setVariable ['status', [], true];
			
			[_vehicle, ['nanoarmor'], _maxTime] call addVehicleStatus;
			[_vehicle, _maxTime, 'client\images\power_halo.paa', _condition] spawn createHalo;
			[_vehicle, 'client\images\vehicle_textures\special\armor.jpg', _maxTime, _condition] spawn swapVehicleTexture;
			['NANO ARMOR', _maxTime, armorSupplyIcon, _condition] spawn createNotification;
		}
	],

	[		
		"jammer",
		0.5,
		jammerSign,
		{	
			_crate = _this;
			_condition = { ("jammer" in ((vehicle player) getVariable ['status', []])) };
			_maxTime = 60;
			_vehicle = (vehicle player);
			_vehicle setVariable ['status', [], true];
			
			[_vehicle, ['jammer'], _maxTime] call addVehicleStatus;
			[_vehicle, _maxTime, 'client\images\power_halo.paa', _condition] spawn createHalo;
			[_vehicle, 'client\images\vehicle_textures\special\jammer.jpg', _maxTime, _condition] spawn swapVehicleTexture;
			['JAMMING DEVICE', _maxTime, jammerSupplyIcon, _condition] spawn createNotification;	

		}
	],

	[		
		"explosive",
		0.85,
		randomSign,
		{	
			_crate = _this;
			_vehicle = (vehicle player);
			_pos = (getpos _vehicle);
			playSound3D ["a3\sounds_f\weapons\mines\electron_trigger_1.wss", _vehicle, false, _pos, 2, 1, 150]; 		
			createVehicle ["Bo_GBU12_LGB", _pos, [], 0, "CAN_COLLIDE"];
		}
	],


	[		
		"nuke",
		0.97,
		nukeSign,
		{	

			_crate = _this;
			_vehicle = (vehicle player);
			_vehiclesInZone = [GW_CURRENTZONE] call findAllInZone;

			{
				[		
					[
						_crate
					],
					"nukeEffect",
					_x,
					false
				] call BIS_fnc_MP;				

				false

			} count _vehiclesInZone > 0;

			// Simulate fallout
			GW_CURRENTZONE spawn {

				for "_i" from 0 to (random 20) do {

					_vehiclesInZone = [_this] call findAllInZone;

					{
						if (alive _x) then {
							_dmg = getDammage _x;
							_x setDammage (_dmg + (random 0.05));
						};

					} count _vehiclesInZone > 0;

					Sleep (0.5 + random 1);

				};

			};

		}
	]	

];