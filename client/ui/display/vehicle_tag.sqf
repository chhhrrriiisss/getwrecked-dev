//
//      Name: vehicleTag
//      Desc: Draws a custom tag for vehicles and players currently in range
//      Return: None
//

_vehicle = _this select 0;

if (isNull _vehicle) exitWith {};
if (!alive _vehicle) exitWith {};

_owner = _vehicle getVariable ["owner", ""];

// If it has no owner, just skip it
if (count toArray _owner == 0 || _owner == "") exitWith {};

// Determine if the tag should be shown based off of signature distance
_dist = GW_CURRENTVEHICLE distance _vehicle;
_signature = _vehicle getVariable ['signature', 'Low'];

_visibleRange = _signature call {
	
	if (_this == "Large") exitWith { 450 };
	if (_this == "Medium") exitWith { 350 };
	if (_this == "Low") exitWith { 250 };
	if (_this == "Tiny") exitWith { 150 };
	250
};

if (_dist > _visibleRange) exitWith {};

// Adjust the alpha of the tag based off of distance
_alpha = [(1 - (_dist/_visibleRange)), 0, 1] call limitToRange;
_color = [0.99,0.14,0.09, _alpha];

_crew = crew _vehicle;
_name = _vehicle getVariable ["name", ""];

_oD = 3;
{
	_d = _vehicle getHit _x;
	_d = if (isNil "_d") then { 0 } else { _d };
	_oD = _oD - _d;
} count ['palivo', 'motor', 'karoserie'] > 0;
_health = round ( (_oD / 3) * 100);

// If its empty or our own vehicle, make it white
if (_owner == GW_PLAYERNAME || count _crew == 0) then {
	_color = [1,1,1, (_alpha * 0.5)];
};	

// If the name is blank, come up with something a bit more interesting
_str = if (count toArray _name == 0 || _name == ' ') then {	'Untitled' } else { _name };

// Long names are not cool
_str = [_str, 30, '...'] call cropString;

// Determine if object is visible (based off of multiple points)
// This is necessary as with large amounts of attached items in the way the vehicle tag sometimes doesnt show at all
_visible = false;
{
	_count = lineIntersectsWith[ATLtoASL (_x select 0), (GW_CURRENTVEHICLE modelToWorldVisual [0,0,2]), (vehicle player), _vehicle];

	// If no obstructions, its visible
	if (count _count <= 0) then {
		_visible = true;
	};

	if (GW_DEBUG) then {

		drawIcon3D [

			blankIcon,
			colorRed,
			(_x select 0),
			0,
			1,
			1,
			'x',
			0,
			0.035,
			"PuristaMedium"
		];

	};
	false
} count [ 
	[ (_vehicle modelToWorldVisual [0,_length * 2,0]) ],
	[ (_vehicle modelToWorldVisual [0,_length * -2,0]) ]
];

// If there's an obstruction, or the vehicle is cloaked/hidden
_status = _vehicle getVariable ["status", []];
_color = if ( !_visible || ('cloak' in _status) || ('nolock' in _status) ) then {

	_lastSeen = [_vehicle] call addToTagList;
	_color set[3, (_color select 3) - (0.35 * (time - _lastSeen))];
	_color

} else {
	
	[_vehicle] call removeFromTagList;
	_color set[3, (_color select 3) + 0.1];
	_color
};

// No point rendering if its invisible eh?
if ((_color select 2) <= 0) exitWith {};

_pos = (_vehicle modelToWorldVisual [0,0,2]);
if ( (_pos select 2) < 2) then { _pos set[2, 2]; };
drawIcon3D [
	blankIcon,
	_color,
	(_vehicle modelToWorldVisual [0,0,2]),
	1,
	1,
	0,
	format['%1 / %2%3', _name, _health, '%'],
	0,
	0.035,
	"PuristaMedium"
];

