GW_AI_LIBRARY = [
	
	[
		["C_Van_01_transport_F","AKBAR","",[],0,[["Land_Device_assembled_F","[-0.000976563,-1.529297,-0.341187]",[-1.12673,0.793632,359.944],["-1","1"]],["land_wired_fence_4m_f","[0.976563,-1.511719,-1.0488892]",[0.647595,1.19629,274.491],["-1","1"]],["land_wired_fence_4m_f","[-0.992188,-1.974609,-0.892395]",[-0.59694,-1.15607,90.0109],["-1","1"]],["land_wired_fence_4m_f","[-0.949219,-1.693359,-0.0583496]",[0.659782,1.16227,270.012],["-1","1"]],["land_wired_fence_4m_f","[0.975586,-1.513672,-0.126831]",[0.704266,1.15168,270.016],["-1","1"]],["Land_Portable_generator_F","[-0.47168,-3.609375,0.0338745]",[-1.14209,0.738292,359.945],["-1","1"]],["Land_Portable_generator_F","[0.294922,-3.566406,0.0341797]",[-1.12665,0.793735,359.837],["-1","1"]],["Land_MetalBarrel_F","[-0.624023,-3.203125,-0.972656]",[-1.12743,0.792633,359.893],["-1","1"]],["Land_MetalBarrel_F","[0.0234375,-3.197266,-0.994324]",[-1.1319,0.872044,359.947],["-1","1"]],["Land_MetalBarrel_F","[0.630859,-3.154297,-1.0362549]",[-1.13104,0.873148,359.891],["-1","1"]],["Box_IND_Wps_F","[-0.0429688,-0.21875,0.683472]",[-1.1319,0.872044,359.947],["-1","1"]],["Land_CnCBarrier_stripes_F","[-0.0244141,2.117188,-1.311096]",[-1.1319,0.872044,359.947],["-1","1"]],["Land_CnCBarrier_stripes_F","[-0.0244141,2.0644531,-0.783813]",[-1.13019,0.874253,359.835],["-1","1"]],["Land_BarrelEmpty_F","[-0.487305,-3.5,-0.258972]",[-1.1319,0.872044,359.947],["-1","1"]]],[83,"SLI",11,2,[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],[["HORN",""],["UNFL",""],["EPLD",""],["LOCK",""],["OILS",""],["DCLK",""],["PARC",""],["TELP",""]],[]]],
		3000
	],

	[
		["B_APC_Tracked_01_AA_F","SHEELA","Pink",[],0,[["land_mil_wallbig_4m_f","[0.128906,3.289063,-4.392662]",[0.545515,-0.420967,179.999],["-1","1"]],["land_mil_wallbig_4m_f","[1.902344,1.734375,-4.392426]",[0.442006,0.637095,270.118],["-1","1"]],["land_mil_wallbig_4m_f","[1.864258,-1.322266,-4.42717]",[0.462484,0.730194,270.007],["-1","1"]],["land_mil_wallbig_4m_f","[-1.795898,1.769531,-4.320801]",[-0.476101,-0.818783,90.2325],["-1","1"]],["land_mil_wallbig_4m_f","[-1.765625,-1.132813,-4.297043]",[-0.494945,-0.864103,90.0095],["-1","1"]],["Land_FireExtinguisher_F","[1.206055,-4.867188,-1.64949]",[-1.21515,-0.0484633,0.00166001],["-1","1"]],["Land_Suitcase_F","[-0.743164,-4.912109,-1.457031]",[-1.2467,-0.0493663,0.00172319],["-1","1"]],["land_mil_wallbig_4m_f","[-0.0410156,-5.332031,-4.365143]",[-0.551612,-0.0202874,359.945],["-1","1"]],["Land_Coil_F","[-0.0185547,-4.0566406,-2.30838]",[-0.588812,-0.0219866,0.000637568],["-1","1"]],["land_mil_wallbig_4m_f","[1.850586,-3.783203,-4.359802]",[-0.0703101,0.606738,274.48],["-1","1"]],["land_mil_wallbig_4m_f","[-1.796875,-3.765625,-4.409134]",[0.0233752,-0.629615,90.0005],["-1","1"]],["Land_CnCBarrier_stripes_F","[1.046875,3.738281,-2.745132]",[-0.638434,-0.0236996,0.000736434],["-1","1"]],["Land_CnCBarrier_stripes_F","[-0.880859,3.738281,-2.754089]",[-0.654596,-0.0243095,0.000770756],["-1","1"]],["Land_CnCBarrier_stripes_F","[2.263672,2.427734,-2.82312]",[0.0251603,-0.675508,90.0005],["-1","1"]],["Land_CnCBarrier_stripes_F","[-2.0996094,2.544922,-2.76297]",[-0.025684,0.68747,270.001],["-1","1"]],["Land_CnCBarrier_stripes_F","[-2.120117,0.0449219,-2.782867]",[-0.0245787,0.692961,269.889],["-1","1"]]],[83,"SLI",1,2,[0,54,0,164.946,400,546.44,4,281,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,14,0,140.906,400,295.904,2,62,0,24,0,140.906,400,295.904,2,74,0,24,0,140.906,400,295.904,2,74,0],[["HORN",""],["UNFL",""],["EPLD",""],["LOCK",""],["OILS",""],["DCLK",""],["PARC",""],["TELP",""]],[]]],
		15000
	]

];

findAITarget = {
	
	private ['_currentPos', '_currentTarget', '_skill'];

	_currentPos = (ASLtoATL getPosASL _this);
	_currentTarget = objNull;
	_skill = _this getVariable ['GW_Skill', 1];

	// Determine current zone
	{
		_z = format['%1Zone', (_x select 0)];
		_inZone = [_currentPos, _z] call checkInZone;
		if (_inZone) exitWith { _currentZone = _z; false };
		false
	} count GW_VALID_ZONES;

	_targetsInZone = [_currentZone] call findAllInZone;	
	{
		_tStatus = _x getVariable ['status', []];
		_canSee = if ("cloak" in _tStatus) then { false } else {
			if (_this distance _x > (1700 + (_skill * 100))) exitWith { false }; 
			if ("nolock" in _tStatus && (random 100) > (_skill * 10)) exitWith { false };
			true 
		};

		if (isPlayer _x && (alive _x) && _x != _vehicle && _canSee) exitWith {			
			_currentTarget = _x;
			false
		};
		false
	} count _targetsInZone;	

	_currentTarget

};

fireAtTargetAI = {
	
	private ['_v', '_t', '_s'];

	_v = _this select 0;
	_t = _this select 1;
	_s = _v getVariable ['GW_Skill', 1];

	for "_i" from 0 to 5 + (_s * 10) step 1 do {
		_v fireAtTarget [_t, (currentWeapon _v)];
		Sleep ([0.25 - (_s / 10), 0.1, 0.25] call limitToRange);
	};

};

GW_AI_MODULE_DEFAULTS = 
[

	[
		"NTO", // Tag
		1, // Reload
		100, // Chance of use %
		{
			_t = (_this select 1) getVariable ['GW_Target', nil];
			if (isNil "_t") exitWith {};
			_inScope = ([(_this select 1), _t, 15] call checkScope);
			( !("emp" in (_this select 2)) && !("disabled" in (_this select 2)) && _inScope)
		},
		{	
			_t = (_this select 0) getVariable ['GW_Target', nil];
			_d = if (isNil "_t") then { 3 } else { ([(_t distance (_this select 0)) / 75, 1, 10] call limitToRange) };

			for "_i" from 0 to (floor _d) step 1 do {
				_this call nitroBoost;
			};
		}
	],
	[
		"DES", // Tag
		1, // Reload
		100, // Chance of use %
		{
			_nearby = (ASLtoATL getPosASL (_this select 1)) nearEntities [["Car"], 30];			
			( !("emp" in (_this select 2)) && ({ if (isPlayer (driver _x)) exitWith {1}; false } count _nearby isEqualTo 1) )
		},
		{
			_this spawn {
				[		
					[
						(_this select 0),
						"surprise",
						100
					],
					"playSoundAll",
					true,
					false
				] call gw_fnc_mp;

				Sleep 1;

				_this call selfDestruct;
			};

		}
	],
	[
		"MAG", // Tag
		15, // Reload
		30, // Chance of use %
		{
			(count (_this select 0) > 1)
		},
		magneticCoil
	],
	[
		"EMP", 
		10,
		75, 
		{
			(count (_this select 0) > 1)
		},
		{ _this call empDevice; [(_this select 0), ['emp']] call removeVehicleStatus; (_this select 0) doMove ((_this select 0) modelToWorld [0,(random 20), 0]); }
	],
	[
		"REP", // Tag
		30, // Reload
		80, // Chance of use %
		{
			_health = (_this select 1) getVariable ['GW_Health', 0];
			(_health <= 50)
		},
		emergencyRepair
	],
	[
		"SHD", // Tag
		30, // Reload
		80, // Chance of use %
		{
			_health = (_this select 1) getVariable ['GW_Health', 0];
			(_health <= 25)
		},
		shieldGenerator
	],
	[
		"SMK", // Tag
		10, // Reload
		80, // Chance of use %
		{
			("locking" in (_this select 2) || "locked" in (_this select 2) || "fire" in (_this select 2) || "inferno" in (_this select 2))
		},
		smokeBomb
	]

];
