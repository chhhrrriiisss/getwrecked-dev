// Max 3 races active at a time
if ((count GW_ACTIVE_RACES) > 3) exitWith {
	GW_ACTIVE_RACES resize 3;
	publicVariable "GW_ACTIVE_RACES";
};

// Delay race requests by 2 seconds to minimize traffic/too many races ending at the same time
if (isNil "GW_LAST_RACE_REQUEST") then { GW_LAST_RACE_REQUEST = time - 2; };
_dif = (time - GW_LAST_RACE_REQUEST);
if (_dif < 2) exitWith {
	[_this, _dif] spawn {
		Sleep (_this select 1);
		(_this select 0) call createRace;
	};
};
GW_LAST_RACE_REQUEST = time;

params ['_raceToInit', '_timeout'];
private ['_raceToInit', '_timeout', '_raceName', '_racePoints', '_raceHost', '_startPosition', '_firstPosition'];

_targetRace = [];
_raceInfo = _raceToInit call getRaceID;
_targetRace = _raceInfo select 0;
_id = _raceInfo select 1;

if (count _targetRace == 0) exitWith { diag_log 'Error bad race data or no race found'; };

_meta = (_targetRace select 0);
_raceName = _meta select 0;
_minPlayers =  [_meta, 3, 2, [0]] call filterParam; // 1 for testing (2 default)
_maxWaitPeriod = [_meta, 4, 60, [0]] call filterParam;
_racePoints = _targetRace select 1;
_raceHost = _targetRace select 2;
_startPosition = _racePoints select 0;
_firstPosition = _racePoints select 1;
_raceStatus = [_targetRace, 3, -1, [0]] call filterParam;

// Clear up start position of any stray vehicles
_objects = nearestObjects [_startPosition, [], 100];
{	
	{ deleteVehicle _x; } foreach (attachedObjects _x);
	deleteVehicle _x;
} foreach _objects;

// Generate 12 unique start positions at first checkpoint
_gridPositions = [];
_invert = -1;
_gap = 2;
_size = 1;
_startDistance = 50;

_dirTo = [_startPosition, _firstPosition] call dirTo;
_dirOpp = [_dirTo + 180] call normalizeAngle;
_initPosition = [([_startPosition, _startDistance, _dirOpp] call relPos), (_gap/2), 90] call relPos;

for "_i" from 0 to 11 step 1 do {

	_invert = _invert * -1;
	_a = [_dirTo + (90 * _invert)] call normalizeAngle;
	_p = [_initPosition, (_gap * _i) + (_size * _i), _a] call relPos;
	_p set [2, 5];
	_gridPositions pushBack _p;

};

// Then set race status to 'waiting phase' + SYNC
(GW_ACTIVE_RACES select _id) set [4, _gridPositions];
[_raceName, 0] call checkRaceStatus;

// Announce race to all players
pubVar_systemChat = format['%1 started a race — use the race menu to join it.',_raceHost];
publicVariable "pubVar_systemChat";
systemchat pubVar_systemChat;

// Wait for 60 seconds or players > minPlayers
_timeout = time + _maxWaitPeriod;
_v = [];
waitUntil {

	Sleep 1;

	

	// Ensure we only count vehicles with drivers
	_v = _startPosition nearEntities [["Car"], 300];
	{
		_isVehicle = _x getVariable ['isVehicle', false];
		_hasDriver = !isNull (driver _x);
		_hasDriver = true;
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

	_left = [([(_timeout - time), 0, _maxWaitPeriod] call limitToRange), 0] call roundTo;

	// Send timer message to each vehicle in zone every few seconds
	if (_left % 2 == 0) then {		
		_string = if ((count _v) < _minPlayers) then { 'Waiting for players... %1s' } else { 'Reached minimum players — starting in %1s' };
		pubVar_systemChat = format[_string, _left, (count _v)];
		{
			
			if (local _x) then { systemchat pubVar_systemChat; } else {
				(owner _x) publicVariableClient "pubVar_systemChat";
			};

		} foreach _v;
	};
	

	((time > _timeout) || _raceStatus == 2)
};

// Get race ID again incase the array has updated
_id = (_raceName call getRaceID) select 1;
(GW_ACTIVE_RACES select _id) set [5, _v];
(GW_ACTIVE_RACES select _id) set [6, []];
publicVariable "GW_ACTIVE_RACES";

// If race has enough players, auto-start
_raceStatus = [_raceName] call checkRaceStatus;	
if (_raceStatus == 1) then {
	[_raceName,2] call checkRaceStatus;	
};

// Insufficient players or TIMEOUT
if (time > _timeout && _raceStatus == 0) exitWith {
	GW_ACTIVE_RACES deleteAt _id;
	publicVariable "GW_ACTIVE_RACES";

	// Announce race to all players
	pubVar_systemChat = 'A race failed to start — not enough players.';
	publicVariable "pubVar_systemChat";
	systemchat pubVar_systemChat;

};

// Warning message
// pubVar_systemChat = "Note: Weapons/items are disabled until first checkpoint.";
// {
// 	if (local _x) then { systemchat pubVar_systemChat; } else {
// 		(owner _x) publicVariableClient "pubVar_systemChat";
// 	};
// } foreach _v;

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

// // Set race status to complete
// [_raceName, 3] call checkRaceStatus;

// // 15 seconds of camera, then end race
// _timeout = time + 10;
// waitUntil {
// 	Sleep 1;
// 	(time > _timeout)
// };




