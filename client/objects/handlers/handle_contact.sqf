//
//      Name: handleEpeContactObject
//      Desc: Contact event handler for objects
//      Return: None
//

if (isServer) exitWith {};

_obj = _this select 0;
_remote = _this select 1;

systemchat 'contact!';

_isVehicle = _remote getVariable ["isVehicle", false];

if (_isVehicle && GW_CURRENTZONE == "workshopZone") then {


	// Apply velocity to vehicle
	if (local _remote) then {
		
		_remote setVelocity [0,0,0];

	} else {

		[       
			[
				_remote,
				[0,0,0]
			],
			"setVelocityLocal",
			_remote,
			false 
		] call BIS_fnc_MP;  

	};

	// Also disable simulation briefly to prevent it flying off

	if (simulationEnabled _remote) then {

		[		
			[
				_remote,
				false
			],
			"setObjectSimulation",
			false,
			false 
		] call BIS_fnc_MP;

		_remote spawn {

			Sleep 1;

			// Disable simulation on vehicle briefly
			[		
				[
					_veh,
					true
				],
				"setObjectSimulation",
				false,
				false 
			] call BIS_fnc_MP;

		};

	};

};

// Stop damage to the source object
_obj setDammage 0;