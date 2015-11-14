params ['_raceName', '_vehicle'];
private ['_raceName', '_id', '_vehicle'];

_raceStatus = [_raceName] call checkRaceStatus;
if (_raceStatus == -1) exitWith {};

_raceData = _raceName call getRaceID;
_raceID = (_raceData select 1);

((GW_ACTIVE_RACES select _raceID) select 6) pushBack _vehicle;
_position = (((GW_ACTIVE_RACES select _raceID) select 6) find _vehicle) + 1;
_desc = _position call {
	if (_this == 1) exitWith {
		'st'
	};
	if (_this == 2) exitWith {
		'nd'
	};
	if (_this == 3) exitWith {
		'rd'
	};
	'th'
};

if (_raceStatus == 3 && _position > 0) then {
	pubVar_systemChat = format['%1 - %2 finished %3%4!', _raceName, name (driver _vehicle), _position, _desc];
	systemchat pubVar_systemChat;
	publicVariable "pubVar_systemChat";
};

// Set race to 'end'
if (_raceStatus == 3) exitWith {};
[_raceName, 3] call checkRaceStatus;

// Get list of current vehicles
((GW_ACTIVE_RACES select _raceID) select 5) deleteAt (((GW_ACTIVE_RACES select _raceID) select 5) find _vehicle);

// Delete vehicles that are already dead
// {
// 	if (!alive _x) then { _vArray deleteAt _forEachIndex; };
// 	_x call destroyInstantly;
// } foreach _vArray;

pubVar_systemChat = format['%1 race ended — %2 finished 1st!', _raceName, name (driver _vehicle)];
systemchat pubVar_systemChat;
publicVariable "pubVar_systemChat";

GW_ACTIVE_RACES deleteAt _raceID;
publicVariable "GW_ACTIVE_RACES";

true