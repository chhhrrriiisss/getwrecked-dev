//
//      Name: vehiclePoint
//      Desc: Handles adding ammo, health or fuel to a vehicle when over a pad
//      Return: None
//

_vehicle = _this select 0;
_type = _this select 1;
_driver = (driver _vehicle);

// // If player is not in the driver seat abort
// if (player != _driver) exitWith {};
noServiceLock = {

	[       
		[
			_this,
			['noservice'],
			3
		],
		"addVehicleStatus",
		_this,
		false 
	] call BIS_fnc_MP; 

};

if (_type == "REPAIR" && {getDammage _vehicle > 0}) exitWith {

	_vehicle setVariable ['inUse', true];
	_vehicle spawn {

		["REPAIRING...      ", 1, healthIcon, nil, "flash"] spawn createAlert;

		// Start the ticker, timeout after 10 seconds
		_error = false;
		_timeout = time + 10;

		for "_i" from 0 to 1 step 0 do {

			if (getDammage _this <= 0 || time > _timeout) exitWith {};

			// If the vehicle is going too fast (ie leaves the pad)
			if ([0,0,0] distance (velocity _this) > 10) exitWith { _error = true; };
			_this setDamage (getDammage _this - 0.05);
			sleep 0.5;
		};				

		// Stop the animation		
		_this setVariable ["GW_NEARBY_SERVICE", nil];

		if (!_error) then {

			_this setDamage 0;
			["REPAIRED!   ", 0.5, successIcon, nil, "slideDown"] spawn createAlert;		

		};

		_this setVariable ["inUse", false];

		_this spawn noServiceLock;

	};
	
};

_maxFuel = (_vehicle getVariable ["maxFuel",1]);		
_currentFuel = (fuel _vehicle) + (_vehicle getVariable ["fuel",0]);

if (_type == "REFUEL" && (_currentFuel < _maxFuel) ) exitWith {

	_vehicle setVariable ['inUse', true];
	_vehicle spawn {

		["REFUELLING...      ", 1, fuelIcon, nil, "flash"] spawn createAlert;

		_error = false;
		_maxFuel = (_this getVariable ["maxFuel",1]);		
		_currentFuel = (fuel _this) + (_this getVariable ["fuel",0]);


		_timeout = time + 10;
		for "_i" from 0 to 1 step 0 do {

			if (_currentFuel >= _maxFuel || time > _timeout) exitWith {};
			if ([0,0,0] distance (velocity _this) > 10) exitWith { _error = true; };

			_currentFuel = (fuel _this) + (_this getVariable ["fuel",0]);
			_allocated = [ ( ( _currentFuel  + ( _maxFuel / 10) ) - 1), 0, 100 ] call limitToRange;
			_this setVariable["fuel", _allocated];
			_this setFuel _currentFuel;
			sleep 0.5;
		};	
		
		_this setVariable ["GW_NEARBY_SERVICE", nil];

		if (!_error) then {

			_this setFuel 1;
			_this setVariable ["fuel", ( (_this getVariable ["maxFuel",1]) - 1)];						
			["REFUELLED!   ", 1, successIcon, nil, "slideDown"] spawn createAlert;

		};		

		_this setVariable ["inUse", false];

		_this spawn noServiceLock;

	};
	
};


_maxAmmo= (_vehicle getVariable ["maxAmmo",1]);		
_currentAmmo = (_vehicle getVariable ["ammo",0]);

if (_type == "REARM" && (_currentAmmo < _maxAmmo) ) exitWith {

	_vehicle setVariable ['inUse', true];
	_vehicle spawn {

		["REARMING...      ", 1, ammoIcon, nil, "flash"] spawn createAlert;

		_error = false;
		_maxAmmo = (_this getVariable ["maxAmmo",1]);		
		_currentAmmo = (_this getVariable ["ammo",0]);

		_timeout = time + 10;

		for "_i" from 0 to 1 step 0 do {

			if (_currentAmmo >= _maxAmmo || time > _timeout) exitWith {};

			if ([0,0,0] distance (velocity _this) > 10) exitWith { _error = true; };

			_currentAmmo = (_this getVariable ["ammo",0]);
			_newAmmo =  [( _currentAmmo  + ( _maxAmmo / 10)), 0, _maxAmmo] call limitToRange;
			_this setVariable["ammo", _newAmmo];
			playSound3D ["a3\sounds_f\weapons\Reloads\1_reload.wss", _this, false, (ASLtoATL visiblePositionASL _this), 3, 1, 20];	
			sleep 0.5;
		};	

		_this setVariable ["GW_NEARBY_SERVICE", nil];

		if (!_error) then {

			_this setVariable["ammo", _maxAmmo];		
			["REARMED!   ", 1, successIcon, nil, "slideDown"] spawn createAlert;			 

		};		

		_this setVariable ["inUse", false];

		_this spawn noServiceLock; 
	};
	
};
