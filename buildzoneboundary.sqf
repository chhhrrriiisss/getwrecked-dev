createBoundary = {

	//
	//      Name: createBoundary
	//      Desc: Create a two-sided boundary texture at specified position
	//      Return: Boundaries (inside and out)
	//

	_source = +(_this select 0);
	_step = (_this select 1);

	_source set[2, 0];				
	_newDestination = [_source, _step, (_this select 2)] call relPos;

	_isWater = (surfaceIsWater _newDestination);

	_normal = if (_isWater) then {
		_newDestination = ATLtoASL (_newDestination);
		_newDestination set[2, 0];
		[0,0,1]
	} else {
	 	(surfaceNormal _newDestination)
	};
		
	_wallInside = "UserTexture10m_F" createVehicleLocal _newDestination; 
	_wallOutside = "UserTexture10m_F" createVehicleLocal _newDestination; 

	if (_isWater) then {
		_wallInside setPosASL _newDestination;
		_wallOutside setPosASL _newDestination;
	};

	_wallInside setVectorDirAndUp [(_this select 3), _normal];
	_wallOutside setVectorDirAndUp [(_this select 4), _normal];

	_wallInside setObjectTexture [0,"client\images\stripes_fade.paa"];
	_wallOutside setObjectTexture [0,"client\images\stripes_fade.paa"];

	_wallInside enableSimulation false;
	_wallOutside enableSimulation false;

	[_wallInside, _wallOutside]

};

_zoneName = [_this, 0, "", [""]] call filterParam;

// Bad zone name
if (count toArray _zoneName == 0) exitWith {};

// Global zone doesn't need a boundary
if (_zoneName == "globalZone") exitWith { systemchat 'bad zone'; };

if (isNil "GW_ACTIVE_BOUNDARIES") then { GW_ACTIVE_BOUNDARIES = []; };

// Dont build a boundary for a zone that's already built
_found = false;
{
	if ((_x select 0) == _zoneName) exitWith { _found = true; };
} foreach GW_ACTIVE_BOUNDARIES;
if (_found) exitWith {  systemchat 'zone boundary already active'; };

_pointsArray = [];

{
	if ((_x select 0) == _zoneName) exitWith { _pointsArray = (_x select 1); };
} foreach GW_ZONE_BOUNDARIES;

// Abort if no point data to work with
if (count _pointsArray == 0) exitWith {  systemchat 'no point data';  };

_c = 0;
_bA = [];

{
	_p1 = ATLtoASL( _x );
	_next = if (_c == (count _pointsArray - 1)) then { 0 } else { _c + 1 };
	_p2 = ATLtoASL( _pointsArray select _next );

	_dirTo = [_p1, _p2] call dirTo;

	_dirIn = [(_dirTo - 90)] call normalizeAngle;
	_dirOut = [(_dirTo + 90)] call normalizeAngle;

	_distance = _p1 distance _p2;

	for "_i" from 0 to _distance step 5 do {
		_b = [_p1, (-2.5 + _i), _dirTo, ([_dirIn,0,0] call dirToVector), ([_dirOut, 0,0] call dirToVector)] call createBoundary;
		_bA pushback (_b select 0);
		_bA pushback (_b select 1);
	};	

	_c = _c + 1;

	false
} count _pointsArray > 0;

GW_ACTIVE_BOUNDARIES pushback [_zoneName, _bA];

systemchat format['%1 boundaries added.', _zonename];
