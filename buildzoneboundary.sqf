//
//      Name: buildZoneBoundary
//      Desc: Handles mass generation of boundaries along pre-defined points
//      Return: None
//

addBoundary = {

	private ['_target', '_dir', '_vector'];

	_target = _this select 0;
	_dir = _this select 1;
	_normal = _this select 2;

	_wallInside = "UserTexture10m_F" createVehicleLocal _target; 
	_wallOutside = "UserTexture10m_F" createVehicleLocal _target; 

	_wallInside setPosASL _target;
	_wallOutside setPosASL _target;	

	_wallInside setVectorDirAndUp [(_dir select 0), _normal];
	_wallOutside setVectorDirAndUp [(_dir select 1), _normal];

	_wallInside setObjectTexture [0,"client\images\stripes_fade.paa"];
	_wallOutside setObjectTexture [0,"client\images\stripes_fade.paa"];

	_wallInside enableSimulation false;
	_wallOutside enableSimulation false;

	[_wallInside, _wallOutside]

};

private ['_zoneName', '_index', '_pointsArray', '_active', '_c', '_bA'];

if !((_this select 0) isEqualType "") exitWith {};
_zoneName = _this select 0;

// Bad zone name
if (count toArray _zoneName == 0) exitWith {};

// Global zone doesn't need a boundary
if (_zoneName == "globalZone") exitWith { systemchat 'bad zone'; };

// Dont build a boundary for a zone that's already built
_active = false;
{
	if ((_x select 0) == _zoneName && count (_x select 3) > 0) exitWith { _active = true; };
} foreach GW_ZONE_BOUNDARIES;
if (_active) exitWith { };

_pointsArray = [];
_index = -1;

{
	if ((_x select 0) == _zoneName) exitWith { _index = _foreachindex; _pointsArray = (_x select 2); };
} foreach GW_ZONE_BOUNDARIES;

// Bad zone index/not found
if (_index == -1) exitWith {};

// Abort if no point data to work with
if (count _pointsArray == 0) exitWith {};

_bA = [];

{	
	_pos = _x select 0;
	_dirAndUp = _x select 1;

	_wallInside = "UserTexture10m_F" createVehicleLocal _pos; 
	if (surfaceIsWater _pos) then { _wallInside setPosASL _pos; };
	_wallInside setVectorDirAndUp _dirAndUp;
	_wallInside setObjectTexture [0,"client\images\stripes_fade.paa"];
	_wallInside enableSimulation false;
	_bA pushBack _wallInside;

	false
} count _pointsArray > 0;

(GW_ZONE_BOUNDARIES select _index) set [3, _bA];

systemchat format['%1 boundaries added.', _zonename];
