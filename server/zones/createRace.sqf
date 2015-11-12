// Only one race active at a time
if ((count GW_ACTIVE_RACES) > 1) exitWith {
	GW_ACTIVE_RACES resize 1;
	publicVariable "GW_ACTIVE_RACES";
};

params ['_raceToInit', '_timeout'];
private ['_raceToInit', '_timeout', '_raceName', '_racePoints', '_raceHost', '_startPosition', '_firstPosition'];

_targetRace = [];
_id = 0;
{
	if (_raceToInit == ((_x select 0) select 0) ) exitWith {
		_targetRace = _x;
		_id = _forEachIndex;
	};
} foreach GW_ACTIVE_RACES;

if (count _targetRace == 0) exitWith { systemchat 'Error bad race data or no race found'; };

_meta = (_targetRace select 0);
_raceName = _meta select 0;
_minPlayers =  [_meta, 3, 1, [0]] call filterParam;
_maxTimeout = [_meta, 4, 120, [0]] call filterParam;
_racePoints = _targetRace select 1;
_raceHost = _targetRace select 2;
_startPosition = _racePoints select 0;
_firstPosition = _racePoints select 1;
_raceStatus = [_targetRace, 3, -1, [0]] call filterParam;

// Clear up start position of any stray vehicles
_objects = _startPosition nearEntities [["Car", "Tank"], 100];
{	
	{ deleteVehicle _x; } foreach (attachedObjects _x);
	deleteVehicle _x;
} foreach _objects;

// Then set race status to 'waiting phase' + SYNC
[_raceName, 0] call checkRaceStatus;
publicVariable "GW_ACTIVE_RACES";

// Wait for 60 seconds or players > minPlayers
_timeout = time + 15;
_v = [];
waitUntil {

	Sleep 1;

	// Ensure we only count vehicles with drivers
	_v = _startPosition nearEntities [["Car"], 300];
	{
		_isVehicle = _x getVariable ['isVehicle', false];
		_hasDriver = !isNull (driver _x);
		if (!_isVehicle || !_hasDriver || !alive _x) then { _v deleteAt _forEachIndex; };
	} foreach _v;

	_raceStatus = [_raceName] call checkRaceStatus;	

	if ( ((count _v) >= _minPlayers) ) then { 

		// Set race status to 'ready'
		if (_raceStatus == 0) then { [_raceName, 1] call checkRaceStatus; };

	} else {

		// Set race status to 'waiting'
		if (_raceStatus == 1) then { [_raceName, 0] call checkRaceStatus; };
	};

	_left = [([(_timeout - time), 0, _maxTimeout] call limitToRange), 0] call roundTo;

	// Send timer message to each vehicle in zone every few seconds
	if (_left % 2 == 0) then {		
		_string = if ((count _v) < _minPlayers) then { 'Waiting for players [ %1s ]' } else { 'Reached minimum players [ %1s ]' };
		pubVar_systemChat = format[_string, _left, (count _v)];
		{
			
			if (local _x) then { systemchat pubVar_systemChat; } else {
				(owner _x) publicVariableClient "pubVar_systemChat";
			};

		} foreach _v;
	};
	

	((time > _timeout) || _raceStatus == 2)
};

// If race has enough players, auto-start
_raceStatus = [_raceName] call checkRaceStatus;	
if (_raceStatus == 1) then {
	[_raceName,2] call checkRaceStatus;	
};

// Insufficient players or TIMEOUT
if (time > _timeout && _raceStatus == 0) exitWith {
	GW_ACTIVE_RACES deleteAt _id;
	publicVariable "GW_ACTIVE_RACES";
	systemchat 'Race failed to start - insufficient players.';
};

// If we are the host, create supply boxes along the route
// if (_raceHost == (name player)) then {
// 	_maxSupply = 15;
// 	_supplyCount = 0;
// 	{
// 		// Limit maximum number of supply drops
// 		if (_supplyCount >= _maxSupply) exitWith {};

// 		// Dont put crates at the last checkpoint
// 		if (_forEachIndex == ((count _racePoints)-1)) exitWith {}; 

// 		for "_i" from 0 to (random 3) step 1 do { 

// 			// Only a chance of a crate, increasing with proximity to end
// 			if (random 100 < (20 - (_forEachIndex * 2))) exitWith {};
// 			_supplyCount = _supplyCount + 1;			

// 			// Random position, between this and next point
// 			_nextPos = _racePoints select (_forEachIndex + 1);
// 			_dirNext = [_x, _nextPos] call dirTo;
// 			_distNext = _x distance _nextPos;
// 			_pos = ([_x, random _distNext, _dirNext] call relPos) vectorAdd [((random 150) - 75), ((random 150) - 75), 0];
// 			_pos set [2, 0];

// 			// Care packages at least 50% of the time
// 			_type = if (random 100 > 50) then { "care" } else { "" };
// 			[
// 				[_pos, false, _type],
// 				'createSupplyDrop',
// 				false,
// 				false
// 			] call bis_fnc_mp;	

// 		};

// 	} foreach _racePoints;
// };

// Wait for MAX timeout OR ALL players completed
_timeout = time + _maxTimeout;
waitUntil {
	Sleep 0.5;
	(time > _timeout)
};

// Set race status to complete
[_raceName, 3] call checkRaceStatus;

// 15 seconds of camera, then end race
_timeout = time + 10;
waitUntil {
	Sleep 1;
	(time > _timeout)
};

GW_ACTIVE_RACES deleteAt _id;
publicVariable "GW_ACTIVE_RACES";
systemchat 'Race complete.';



