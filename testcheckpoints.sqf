// Creates a series of checkpoints, waits for player to enter correctly 

// _points = [_this, 0, [], [[]]] call bis_fnc_param;
_points = [
	(vehicle player) modelToWorldVisual [0, 30, 0],
	(vehicle player) modelToWorldVisual [50, 100, 0],
	(vehicle player) modelToWorldVisual [200, 200, 0]
];

_points = [_this, 0, _points, [[]]] call bis_fnc_param;

if (count _points == 0) exitWith {
	hint 'Could not start - bad point data';
};

_cpArray = [];
_dirNext = 0;
_totalCheckpoints = count _points;

// Create CP markers at each point
{
	_cp = "Sign_sphere100cm_F" createVehicleLocal _x;
	_dirNext = if (_forEachIndex == (count _points - 1)) then { _dirNext } else { ([_x, _points select (_forEachIndex + 1)] call dirTo) };
	_cp setDir _dirNext;

	_c = "Sign_Circle_F" createVehicleLocal _x;
	_c setPos [_x select 0, _x select 1, (_x select 2) - 5];
	_c setDir _dirNext;

	// Add to checkpoint 3d icons array
	GW_CHECKPOINTS pushBack _c;

	_l = "UserTexture10m_F" createVehicleLocal _x; 
	_l setObjectTextureGlobal [0,"client\images\stripes_fade.paa"]; 
	_offsetPos = (_cp modelToWorldVisual [5,-4.8,0]);
	_offsetPos set [2, 0.1];
	_l setPos _offsetPos;
	_l setVectorUp (surfaceNormal _offsetPos);
	[_l, [-90,0,[(_dirNext+180)] call normalizeAngle]] call setPitchBankYaw;  

	_r = "UserTexture10m_F" createVehicleLocal _x;   
	_r setObjectTextureGlobal [0,"client\images\stripes_fade.paa"]; 
	_offsetPos = (_cp modelToWorldVisual [-5,-4.8,0]);
	_offsetPos set [2, 0.1];
	_r setPos _offsetPos;
	_r setVectorUp (surfaceNormal _offsetPos);
	[_r, [-90,0,[(_dirNext+180)] call normalizeAngle]] call setPitchBankYaw;  

	
	_cpArray pushBack [_cp, _dirNext, [_cp, _c, _l, _r]];
} foreach _points;

_result = ['START', 5, false, true] call createTimer;
if (!_result) exitWith { hint 'Race aborted'; };
GW_CURRENTVEHICLE say "electronTrigger";

_maxTime = [_this, 1, 15, [0]] call bis_fnc_param;
_timeout = time + _maxTime;

hint '';
hint format['Race started! (%1s)', _maxTime];

_distTolerance = 10;
_dirTolerance = 80;
_startTime = time;

for "_i" from 0 to 1 step 0 do {

	if (count _cpArray == 0 || time > _timeout) exitWith {};

	_targetCp = (_cpArray select 0) select 0;
	if ((GW_CURRENTVEHICLE distance _targetCp) < _distTolerance) then {

		_correctDir = (_cpArray select 0) select 1;
		_currentDir = getDir GW_CURRENTVEHICLE;
		_difDir = abs ([_currentDir - _correctDir] call flattenAngle);

		if (_difDir > _dirTolerance) exitWith {};

		_group = ((_cpArray select 0) select 2);
		{ deleteVehicle _x; } foreach _group;

		_cpArray deleteAt 0;
		hint format['Reached checkpoint %1/%2!', _totalCheckpoints - (count _cpArray), _totalCheckpoints, time];
		GW_CURRENTVEHICLE say "blipCheckpoint";

		

	};

	_timeLeft = [_maxTime - (time - _startTime), 0, 99999] call limitToRange;
	systemchat format['timeleft: %1', _timeLeft];

	if (_timeLeft <= (_maxTime * 0.3) ) then {

		_left = (_timeout - time);
		_seconds = floor (_left);	
		_milLeft = floor ( abs ( floor( _left ) - _left) * 10);
		_hoursLeft = floor(_seconds / 3600);
		_minsLeft = floor((_seconds - (_hoursLeft*3600)) / 60);
		_secsLeft = floor(_seconds % 60);
		_timeLeft = format['-%1:%2:%3:%4', ([_hoursLeft, 2] call padZeros), ([_minsLeft, 2] call padZeros), ([_secsLeft, 2] call padZeros), ([_milLeft, 2] call padZeros)];

		hint _timeLeft;
		GW_CURRENTVEHICLE say "beepTarget";

	};

	Sleep 0.1;

};

if ((count _cpArray) == 0 && time <= (_timeout + 0.1) ) then {
	hint format['Race complete! (%1s)', ([time - _startTime, 2] call roundTo)];
	//_result = ['START', 5, false] call createTimer;
} else {
	hint format['Race failed! (Timeout)', time];
	GW_CURRENTVEHICLE say "siren";
	[GW_CURRENTVEHICLE, 9999, 'client\images\lock_halo.paa',{ (alive GW_CURRENTVEHICLE) }, false] spawn createHalo;

	[] spawn {
		Sleep (2 + random 5);
		(vehicle player) call destroyInstantly;		
	};
};

// Cleanup
{
	{ deleteVehicle _x; } foreach (_x select 2);
} foreach _cpArray;

