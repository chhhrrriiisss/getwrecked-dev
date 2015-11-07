// Creates a series of checkpoints, waits for player to enter correctly 


// _points = [_this, 0, [], [[]]] call bis_fnc_param;
_points = [
	(vehicle player) modelToWorldVisual [0, 50, 0]
];

for "_i" from 1 to 2 step 1 do {
	_p = GW_CURRENTVEHICLE modelToWorldVisual [0 + ((random 50) - 25), 75*_i, 0];
	_p set [2, 0];
	_points set [_i, _p];
};

_points = [_this, 0, _points, [[]]] call bis_fnc_param;

if (count _points == 0) exitWith {
	hint 'Could not start - bad point data';
};

_cpArray = [];
_dirNext = 0;
_totalCheckpoints = count _points;

// Clear any pre-existing icon checkpoints
if (count GW_CHECKPOINTS > 0) then { {  deletevehicle _x; } foreach GW_CHECKPOINTS;};
GW_CHECKPOINTS = [];
GW_CHECKPOINTS_COMPLETED = [];

// Create checkpoint halo as a guide
[GW_CURRENTVEHICLE, 9999, 'client\images\checkpoint_halo2.paa',{ 

_rT = _this select 0;
_rB = _this select 1;

if (count GW_CHECKPOINTS == 0) exitWith { false };
_cP = GW_CHECKPOINTS select 0;

_dirTo = [([GW_CURRENTVEHICLE, _cP] call dirTo) - (getDir GW_CURRENTVEHICLE)] call normalizeAngle;
_dirToRB = [_dirTo + 180] call normalizeAngle;

[_rT, [-90,0,_dirTo]] call setPitchBankYaw;
[_rB, [90,0,_dirToRB]] call setPitchBankYaw;

// _rT setDir _dirTo;
// _rB setDir _dirTo;

((alive GW_CURRENTVEHICLE) || (count GW_CHECKPOINTS > 0))

}, false, [0,2,0.5]] spawn createHalo;

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
	_offsetPos = (_cp modelToWorldVisual [10,-4.8,0]);
	_offsetPos set [2, 0.1];
	_l setPos _offsetPos;
	_l setVectorUp (surfaceNormal _offsetPos);
	[_l, [-90,0,[(_dirNext+180)] call normalizeAngle]] call setPitchBankYaw;  

	_cen = "UserTexture10m_F" createVehicleLocal _x;   
	_cen setObjectTextureGlobal [0,"client\images\stripes_fade.paa"]; 
	_offsetPos = (_cp modelToWorldVisual [0,-4.8,0]);
	_offsetPos set [2, 0.1];
	_cen setPos _offsetPos;
	_cen setVectorUp (surfaceNormal _offsetPos);
	[_cen, [-90,0,[(_dirNext+180)] call normalizeAngle]] call setPitchBankYaw;  

	_r = "UserTexture10m_F" createVehicleLocal _x;   
	_r setObjectTextureGlobal [0,"client\images\stripes_fade.paa"]; 
	_offsetPos = (_cp modelToWorldVisual [-10,-4.8,0]);
	_offsetPos set [2, 0.1];
	_r setPos _offsetPos;
	_r setVectorUp (surfaceNormal _offsetPos);
	[_r, [-90,0,[(_dirNext+180)] call normalizeAngle]] call setPitchBankYaw;  

	
	_cpArray pushBack [_cp, _dirNext, [_cp, _c, _l, _cen, _r]];

	hideObject _cp;

} foreach _points;

GW_CURRENTVEHICLE engineOn false;
GW_CURRENTVEHICLE setFuel 0;
_result = ['START', 5, false, true] call createTimer;
if (!_result) exitWith { hint 'Race aborted'; };
GW_CURRENTVEHICLE say "electronTrigger";
GW_CURRENTVEHICLE setFuel 1;
GW_CURRENTVEHICLE engineOn true;

_maxTime = [_this, 1, 15, [0]] call bis_fnc_param;
_timeout = time + _maxTime;

hint '';
hint format['Race started! (%1s)', _maxTime];

_distTolerance = 10;
_dirTolerance = 80;
_startTime = time;

for "_i" from 0 to 1 step 0 do {

	if (count _cpArray == 0 || time > _timeout || !alive GW_CURRENTVEHICLE) exitWith {};

	_targetCp = (_cpArray select 0) select 0;
	if ((GW_CURRENTVEHICLE distance _targetCp) < _distTolerance) then {

		_correctDir = (_cpArray select 0) select 1;
		_currentDir = getDir GW_CURRENTVEHICLE;
		_difDir = abs ([_currentDir - _correctDir] call flattenAngle);

		if (_difDir > _dirTolerance) exitWith {};

		_group = ((_cpArray select 0) select 2);
		{ deleteVehicle _x; } foreach _group;

		_timeStamp = (time - _startTime) call formatTimeStamp;
		_timeStamp = format['+%1', _timeStamp];

		GW_CHECKPOINTS_COMPLETED pushback [(getpos ((_cpArray select 0) select 0)), _timeStamp, 1];
		_cpArray deleteAt 0;
		GW_CHECKPOINTS deleteAt 0;
		hint format['Reached checkpoint %1/%2!', _totalCheckpoints - (count _cpArray), _totalCheckpoints, time];
		GW_CURRENTVEHICLE say "blipCheckpoint";

		

	};

	_timeLeft = [_maxTime - (time - _startTime), 0, 99999] call limitToRange;

	if (_timeLeft <= (_maxTime * 0.3) ) then {

		_timeLeft = (_timeout - time) call formatTimeStamp;
		hint format['-%1', _timeLeft];
		GW_CURRENTVEHICLE say "beepTarget";

	};

	Sleep 0.1;

};

if ((count _cpArray) == 0 && time <= (_timeout + 0.1) ) then {
	hint format['Race complete! (%1s)', ([time - _startTime, 2] call roundTo)];	

	_timeStamp = (time - _startTime) call formatTimeStamp;
	_text = format["<t size='3.5' color='#ffffff' align='center' valign='middle'>+%1</t>", _timeStamp];
	["SPECTATE", _text, 10] execVM 'client\ui\dialogs\title.sqf';
	[] execVM 'testflycamera.sqf';

	GW_CURRENTVEHICLE say "electronTrigger";
	GW_CURRENTVEHICLE say "summon";
	//_result = ['START', 5, false] call createTimer;

	[] spawn { 
		Sleep 3;
		GW_CHECKPOINTS = [];
		GW_CHECKPOINTS_COMPLETED = [];
	};

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

