// Creates a series of checkpoints, waits for player to enter correctly 

// _points = [_this, 0, [], [[]]] call bis_fnc_param;


_points = [
	player modelToWorldVisual [10, 0, 0],
	player modelToWorldVisual [20, 0, 0],
	player modelToWorldVisual [30, 0, 0],
	player modelToWorldVisual [40, 0, 0]
];

// _timeout = [_this, 1, 30, [0]] call bis_fnc_param;

_timeout = time + 30;

if (count _points == 0) exitWith {
	hint 'Could not start - bad point data';
};

_totalCheckpoints = count _points;

hint format['Race started! %1', time];

_cpArray = [];

// Create CP markers at each point
{
	_cp = createVehicle ["Sign_Circle_F" , _x, [], 0, 'CAN_COLLIDE']; 
	_dirNext = if (_forEachIndex == (count _points - 1)) then { 0 } else { ([_x, _points select (_forEachIndex + 1)] call dirTo) };
	_cp setDir _dirNext;
	_cpArray pushBack [_cp, _dirNext];
} foreach _points;


_distTolerance = 5;
_dirTolerance = 45;
_startTime = time;

for "_i" from 0 to 1 step 0 do {

	if (count _cpArray == 0 || time > _timeout) exitWith {};

	_targetCp = (_cpArray select 0) select 0);
	if ((GW_CURRENTVEHICLE distance _targetCp) < _distTolerance) then {

		_correctDir = (_cpArray select 0) select 1);
		_currentDir = getDir GW_CURRENTVEHICLE;
		_difDir = [_currentDir - _correctDir] call flattenAngle;
		if (_difDir > _dirTolerance) exitWith {};

		_cpArray deleteAt 0;
		hint format['Reached checkpoint %1/%2! %2', _totalCheckpoints - (count _cpArray), _totalCheckpoints, time];

	};

	if (velocity GW_CURRENTVEHICLE <= 5) then { Sleep 1; };
};

hint format['Race complete in: %1s', ([time - _startTime, 2] call roundTo)];