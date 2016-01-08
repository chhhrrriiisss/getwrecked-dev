_zoneName = [_this, 0, "", [""]] call filterParam;
_section = [_this, 1, [0, 9999], [[]]] call filterParam;

GW_BOUNDARY_BUILD = nil;

// Bad zone name
if (count toArray _zoneName == 0) exitWith {};

// Global zone doesn't need a boundary
if (_zoneName == "globalZone") exitWith { systemchat 'Bad zone...'; };

if (isNil "GW_ACTIVE_BOUNDARIES") then { GW_ACTIVE_BOUNDARIES = []; };

if (isNil "GW_ZONE_BOUNDARIES_CACHED") exitWith {
	systemchat 'Boundaries have not been cached yet...';
};

// Dont build a boundary for a zone that's already built
_found = false;
{
	if ((_x select 0) == _zoneName) exitWith { _found = true; };
} foreach GW_ACTIVE_BOUNDARIES;
if (_found) exitWith {};

_pointsArray = [];

{
	if ((_x select 0) == _zoneName) exitWith { _pointsArray = (_x select 2); false };
		false
} count GW_ZONE_BOUNDARIES;

// Abort if no point data to work with
if (count _pointsArray == 0) exitWith { };

_bA = [];


{

	if (true) then {

		if (_forEachIndex < (_section select 0) || _forEachIndex > (_section select 1)) exitWith {};

		_pos = _x select 0;
		_dirAndUp = _x select 1;

		_wallInside = "UserTexture10m_F" createVehicleLocal _pos; 
		if (surfaceIsWater _pos) then { _wallInside setPosASL _pos; };
		_wallInside setVectorDirAndUp _dirAndUp;
		_wallInside setObjectTexture [0,"client\images\stripes_fade.paa"];
		_wallInside enableSimulation false;



		_bA pushBack _wallInside;

	};
} foreach _pointsArray;

GW_ACTIVE_BOUNDARIES pushback [_zoneName, _bA];
GW_BOUNDARY_BUILD = true;

if (GW_DEBUG) then { systemchat format['%1 boundaries added.', _zonename]; };
