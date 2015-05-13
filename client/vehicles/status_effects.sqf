//
//      Name: triggerVehicleStatus
//      Desc: Spawns a status sffect dependent on active status
//      Return: None
//

private ['_abort', '_statusEffect', '_commandToLoop'];

_abort = false;
_statusEffect = _this select 0;
_maxTimeout = _this select 1;

if ("disabled" isEqualTo _statusEffect ||
	"tyresPopped" isEqualTo _statusEffect ||
	"emp" isEqualTo _statusEffect ||
	"forked" isEqualTo _statusEffect) then {

	['disabled', GW_CURRENTVEHICLE, 1] call logStat; 

};

_commandToLoop = switch (true) do { 

	case ("disabled" isEqualTo _statusEffect): {{

		GW_CURRENTVEHICLE sethit ["wheel_1_1_steering", 1];
		GW_CURRENTVEHICLE sethit ["wheel_1_2_steering", 1];
		GW_CURRENTVEHICLE sethit ["wheel_2_1_steering", 1];
		GW_CURRENTVEHICLE sethit ["wheel_2_2_steering", 1];

		[GW_CURRENTVEHICLE, 0] spawn slowDown;            

	}};

	case ("limpets" isEqualTo _statusEffect): {{

		_random = random 100;
		addCamShake [0.5, 0.25,30];

		if (_random > 70) then {

			_vel = velocity GW_CURRENTVEHICLE;
			_rnd = (random 4);

			_random = random 100;		

			GW_CURRENTVEHICLE setVelocity [_vel select 0, _vel select 1, (_vel select 2) + _rnd];      
			addCamShake [3, 0.25,10];
			[
				[
					GW_CURRENTVEHICLE,
					0.1,
					[0,0,0,0.2],
					2,
					-1
				],
				"smokeEffect"
			] call gw_fnc_mp;    

		};

	}};

	case ("tyresPopped" isEqualTo _statusEffect && !("invTyres" in GW_VEHICLE_STATUS) ): {{

		GW_CURRENTVEHICLE sethit ["wheel_1_1_steering", 1];
		GW_CURRENTVEHICLE sethit ["wheel_1_2_steering", 1];
		GW_CURRENTVEHICLE sethit ["wheel_2_1_steering", 1];
		GW_CURRENTVEHICLE sethit ["wheel_2_2_steering", 1];

		[GW_CURRENTVEHICLE, 0.97] spawn slowDown;                 

	}};

	case ("invTyres" isEqualTo _statusEffect): {{

		GW_CURRENTVEHICLE sethit ["wheel_1_1_steering", 0];
		GW_CURRENTVEHICLE sethit ["wheel_1_2_steering", 0];
		GW_CURRENTVEHICLE sethit ["wheel_2_1_steering", 0];
		GW_CURRENTVEHICLE sethit ["wheel_2_2_steering", 0];        

	}};

	case ("inferno" isEqualTo _statusEffect && !("nanoarmor" in GW_VEHICLE_STATUS)): {{

		// Put out fire if we drive in water
		if (surfaceIsWater (getPosASL GW_CURRENTVEHICLE)) then {

			[GW_CURRENTVEHICLE, ['fire', 'inferno']] call removeVehicleStatus;

		} else {                                         

		    _dmg = getDammage GW_CURRENTVEHICLE;
		    _rnd = (random 7) + 14;
		    _rnd = (_rnd / 10000) * FIRE_DMG_SCALE;
		    _newDmg = _dmg + _rnd;
		    GW_CURRENTVEHICLE setDammage _newDmg;
		};

		
	}};

	case ("fire" isEqualTo _statusEffect): {{

		// Put out fire if we drive in water
		if (surfaceIsWater (getPosASL GW_CURRENTVEHICLE)) then {

			[GW_CURRENTVEHICLE, ['fire', 'inferno']] call removeVehicleStatus;

		} else {                                         

		    _dmg = getDammage GW_CURRENTVEHICLE;
		    _rnd = (random 5) + 10;
		    _rnd = (_rnd / 10000) * FIRE_DMG_SCALE;
		    _rnd = if ("nanoarmor" in GW_VEHICLE_STATUS) then { (_rnd * 0.1) } else { _rnd };
		    _newDmg = _dmg + _rnd;
		    GW_CURRENTVEHICLE setDammage _newDmg;
		};

	}};

	case ("emp" isEqualTo _statusEffect): {{
		
		if ("nuke" in GW_VEHICLE_STATUS) then {} else {
			[GW_CURRENTVEHICLE, 0.3] spawn slowDown;   
		};

		if ('EMF' in GW_VEHICLE_SPECIAL) then {
			for "_i" from 0 to (['EMF', GW_CURRENTVEHICLE] call hasType) step 1 do {
				if ((random 100) > 98) exitWith { [GW_CURRENTVEHICLE, ['emp']] call removeVehicleStatus; };
			};
		};
	}}; 

	default
	{
		_abort = true;
	};
};

if (_abort) exitWith {};

[_statusEffect, _commandToLoop, _maxTimeout] spawn {
	
	_timeout = time + (_this select 2);

	waitUntil {
		[] call (_this select 1);
		Sleep 0.25;
		(!((_this select 0) in GW_VEHICLE_STATUS) || (time > _timeout) )
	};

};