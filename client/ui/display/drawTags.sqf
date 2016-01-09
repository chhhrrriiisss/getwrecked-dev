params ['_arr'];
private ['_arr'];

// Show player/vehicle tags for nearby units
_vehicleRendered = false;
{	
	_inVehicle = if (_x == (driver (vehicle _x))) then { true } else { false };

	if (_inVehicle) then {

		_isVehicle = (vehicle _x) getVariable ['isVehicle', false];
		if (!_isVehicle) exitWith {};

		_x = (vehicle _x);

		_name = _x getVariable ["name", ''];
		_owner = _x getVariable ["GW_Owner",''];

		// Only render tags we can see
		if ( !(_owner isEqualTo '') && _isVehicle && GW_CURRENTZONE != "workshopZone") then {

			if ('radar' in GW_VEHICLE_STATUS && !(_x in GW_TARGETICON_ARRAY) && _x != GW_CURRENTVEHICLE) then { 
				GW_TARGETICON_ARRAY pushback _x;
			};

			IF (!('radar' in GW_VEHICLE_STATUS)) then {
				GW_TARGETICON_ARRAY = [];
			};	

			// Only render first vehicle captured by this loop that's in scope
			_inScope = [GW_TARGET_DIRECTION, _x, 12.5] call checkScope;
			if (_vehicleRendered && !_inScope) exitWith {};
			_vehicleRendered = true;
			[_x] call vehicleTag;
		};	
		

	} else {

		if (!isPlayer _x) exitWith {};
		if ( (_x == player || !alive _x) && !GW_DEBUG  ) exitWith {};
		if (_x == (vehicle _x)) then { // (isPlayer _x)

			_name = (name _x);
			_pos = _x modelToWorldVisual [0, 0, 2.2];
			_dist = GW_CURRENTPOS distance _pos;
			
			drawIcon3D [
				blankIcon,
				[1,1,1,( (1 - (_dist/150)) max 0 )],
				_pos,
				1,
				1,
				0,
				_name,
				0,
				0.03,
				"PuristaMedium"
			];

		};

	};

	false
} count _arr > 0;