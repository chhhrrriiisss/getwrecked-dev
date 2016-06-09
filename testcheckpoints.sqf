//
//      Name: testCheckpoints
//      Desc: 
//      Return: 
//

// Creates a series of checkpoints, waits for player to enter correctly 
_abortSequence = {
	
	_toDelete = _this;

	GW_CURRENTVEHICLE say "siren";

	// Empty _cpArray
	{
		{
			deleteVehicle _x;
		} foreach (_x select 2);
	} foreach _toDelete;

};

// _points = [_this, 0, [], [[]]] call bis_fnc_param;
_points = [
	(vehicle player) modelToWorldVisual [0, 25, 0],
	(vehicle player) modelToWorldVisual [0, 50, 0],
	(vehicle player) modelToWorldVisual [0, 75, 0]
];

for "_i" from 1 to 2 step 1 do {
	_p = GW_CURRENTVEHICLE modelToWorldVisual [0 + ((random 50) - 25), 75*_i, 0];
	_p set [2, 0];
	_points set [_i, _p];
};

private ['_points', '_targetRace', '_startPosition', '_raceStatus', '_raceName'];

_targetRace = [_this, 0, [], [[], ""]] call bis_fnc_param;
_targetRace = if ((typename _targetRace) == "STRING") then { ((_targetRace call getRaceID) select 0) } else { _targetRace };
if (count _targetRace == 0) exitWith { hint 'Could not start - invalid race'; };

_points = [_targetRace, 1, _points, [[]]] call bis_fnc_param;

if (count _points == 0) exitWith { hint 'Could not start - bad point data'; };

_raceName = (_targetRace select 0) select 0;

_startPosition = _points select 0;
_firstPosition = _points select 1;
_raceStatus = [_targetRace, 3, -1, [0]] call filterParam;

_cpArray = [];

_totalCheckpoints = count _points;

GW_CHECKPOINTS = _points;
GW_CHECKPOINTS_COMPLETED = [];
GW_CHECKPOINTS_PROGRESS = 0;
GW_CHECKPOINTS_COMPLETED = [];

// Create checkpoint halo as a guide
[GW_CURRENTVEHICLE, 9999, 'client\images\checkpoint_halo.paa',{ 

	_rT = _this select 0;
	_rB = _this select 1;

	if (count GW_CHECKPOINTS == 0 || GW_CHECKPOINTS_PROGRESS == count GW_CHECKPOINTS) exitWith { false };
	_cP = GW_CHECKPOINTS select GW_CHECKPOINTS_PROGRESS;

	_dirDif = ([GW_CURRENTVEHICLE, _cP] call dirTo) - (getDir GW_CURRENTVEHICLE);
	_dirTo = [_dirDif] call normalizeAngle;
	_dirToRB = [_dirTo + 180] call normalizeAngle;

	[_rT, [-90,0,_dirTo]] call setPitchBankYaw;
	[_rB, [90,0,_dirToRB]] call setPitchBankYaw;

	// If the vehicle direction is too far from the required direction, flag vehicle as facing wrong way
	// _dif = abs ([_dirDif] call flattenAngle);
	// if (_dif > 70) then {
	// 	if ('wrwy' in GW_VEHICLE_STATUS) exitWith {};
	// 	[GW_CURRENTVEHICLE, ['wrwy'], 9999] call addVehicleStatus;	
	// } else {
	// 	[GW_CURRENTVEHICLE, ['wrwy']] call removeVehicleStatus;	
	// };

	// _rT setDir _dirTo;
	// _rB setDir _dirTo;

	((alive GW_CURRENTVEHICLE) || (count GW_CHECKPOINTS > 0))

}, false, [0,2,0.5], true] spawn createHalo;


// Function to create a new checkpoint
createCheckpoint = {
	
	params ['_index', '_cpArray'];	
	private ['_index', '_cpArray'];	

	_cPos = _cpArray select _index;

	_objArray = [];
	_dirNext = 0;

	_dirNext = if (_index == (count _cpArray - 1)) then { _dirNext } else { ([_cPos, _cpArray select (_index + 1)] call dirTo) };

	_cp = "Sign_Circle_F" createVehicleLocal _cPos;
	_cp setPos [_cPos select 0, _cPos select 1, (_cPos select 2) - 5];
	_cp setDir _dirNext;
	_cp enableSimulationGlobal false;

	_objArray pushBack _cp;

	{
		if ((surfaceNormal (_cp modelToWorldVisual _x)) distance [0,0,1] > 0.1) then {} else {

			_t = "UserTexture10m_F" createVehicleLocal _cPos; 
			_t setObjectTextureGlobal [0,"client\images\stripes_fade.paa"]; 
			_offsetPos = (_cp modelToWorldVisual _x);
			_offsetPos set [2, 0.1];
			_t setPos _offsetPos;	
			
			[_t, [-90,0, ( [(_dirNext+180)] call normalizeAngle )]] call setPitchBankYaw;  

			_t enableSimulationGlobal false;
			_objArray pushBack _t;

		};
		false
	} count [
		[10,-4.8,0],
		[0,-4.8,0],
		[-10,-4.8,0]
	];

	_objArray

};


// Temporary invulnerability until first checkpoint
[GW_CURRENTVEHICLE, ["noshoot", "nouse", "noammo", "nofuel"], 9999] call addVehicleStatus;

_maxTime = [_this, 1, 15, [0]] call bis_fnc_param;
_timeout = time + _maxTime;

hint format['Race started! (%1s)', _maxTime];

_startTime = time;

_totalDistance = [_points, false] call calculateTotalDistance;

// Checkpoint trigger config
_distTolerance = 10;
_dirTolerance = 80;

// Create initial checkpoint group
_checkpointGroup = [GW_CHECKPOINTS_PROGRESS, GW_CHECKPOINTS] call createCheckpoint;


for "_i" from 0 to 1 step 0 do {

	if ((GW_CHECKPOINTS_PROGRESS == count GW_CHECKPOINTS) || count GW_CHECKPOINTS == 0 || time > _timeout || !alive GW_CURRENTVEHICLE || !alive player) exitWith {};

	// Calculate how far through the race we are	
	_checkpointsCompleted = +GW_CHECKPOINTS;
	_checkpointsCompleted resize GW_CHECKPOINTS_PROGRESS;
	_distanceTravelled = [_checkpointsCompleted, FALSE] call calculateTotalDistance;
	
	_isPast = true;
	_distanceToLastCheckpoint = if (GW_CHECKPOINTS_PROGRESS > 0) then { 

		_vPos = (ASLtoATL visiblePositionASL GW_CURRENTVEHICLE);
		_currentCheckpoint = GW_CHECKPOINTS select GW_CHECKPOINTS_PROGRESS;
		_lastCheckpoint = _checkpointsCompleted select (count _checkpointsCompleted - 1);

		// Check we're on the correct side of the checkpoint
		_dirTo = [_lastCheckpoint, _currentCheckpoint] call dirTo;
		_dirV = [_lastCheckpoint, GW_CURRENTVEHICLE] call dirTo;
		_dirDif = [_dirTo - _dirV] call flattenAngle;

		if (_dirDif > 90) exitWith { _isPast = false; 0 };

		([(_vPos distance _lastCheckpoint), 0, (_lastCheckpoint distance _currentCheckpoint)] call limitToRange)

	} else { 0 };

	_distanceTravelled = _distanceTravelled + _distanceToLastCheckpoint;

	
	GW_CURRENTRACE_PROGRESS = 1 - ((_totalDistance - _distanceTravelled) / _totalDistance);
	
	// Publish updated progress once every 1.5 seconds
	if (round (time) % 1.5 == 0) then {
		GW_CURRENTVEHICLE setVariable ['GW_R_PR', GW_CURRENTRACE_PROGRESS, true];
	};

	_distanceToCheckpoint = (ASLtoATL visiblePositionASL GW_CURRENTVEHICLE) distance (GW_CHECKPOINTS select GW_CHECKPOINTS_PROGRESS);
	if (_distanceToCheckpoint < _distTolerance) then {			

		// Remove shooting/use restrictions after first WP
		if (GW_CHECKPOINTS_PROGRESS == 0) then {
			[GW_CURRENTVEHICLE, ["noshoot", "nouse", "noammo", "nofuel"]] call removeVehicleStatus;
		};

		// Give vehicle ammo/fuel equivalent to the percentage of total checkpoints complete
		// _percentComplete = if ((count GW_CHECKPOINTS -1) == 0) then { 1 } else { (count GW_CHECKPOINTS_COMPLETED / count GW_CHECKPOINTS) };

		// 10% Ammo & Fuel at each checkpoint
		// _maxAmmo = GW_CURRENTVEHICLE getVariable ["maxAmmo", 1];
		// _targetAmmo = [_maxAmmo * 0.1, 1] call roundTo;
		// GW_CURRENTVEHICLE setVariable ["ammo", _maxAmmo];
		
		// _maxFuel = GW_CURRENTVEHICLE getVariable ["maxFuel", 1];
		// _targetFuel = [_maxFuel * 0.1, 1] call roundTo;
		// GW_CURRENTVEHICLE setVariable ["fuel", _maxFuel];

		_timeStamp = (serverTime - GW_CURRENTRACE_START) call formatTimeStamp;
		_timeStamp = format['+%1', _timeStamp];
		GW_CURRENTVEHICLE say "blipCheckpoint";		

		// Delete previous checkpoint group 
		{ 
			deleteVehicle _x;
		} foreach _checkpointGroup;

		GW_CHECKPOINTS_COMPLETED pushback [(GW_CHECKPOINTS select GW_CHECKPOINTS_PROGRESS), _timeStamp, 1];

		GW_CHECKPOINTS_PROGRESS = GW_CHECKPOINTS_PROGRESS + 1;

		if (GW_CHECKPOINTS_PROGRESS == count GW_CHECKPOINTS) exitWith {};

		// Create new checkpoint if not last point
		_checkPointGroup = [GW_CHECKPOINTS_PROGRESS, GW_CHECKPOINTS] call createCheckpoint;

	};

	_timeLeft = [_maxTime - (time - _startTime), 0, 99999] call limitToRange;

	if (_timeLeft <= (_maxTime * 0.3) ) then {

		_timeLeft = (_timeout - time) call formatTimeStamp;
		hint format['-%1', _timeLeft];
		GW_CURRENTVEHICLE say "beepTarget";

	};

	Sleep 0.25;

};

// Delete previous checkpoint group 
{ 
	deleteVehicle _x;
} foreach _checkpointGroup;

_raceID =  ((_raceName call getRaceID) select 1);

_vehiclesArray = [GW_ACTIVE_RACES, _raceID, [], [[]]] call filterParam;
_vehiclesArray = [_vehiclesArray, 4, allPlayers, [[]]] call filterParam;

if ((count _cpArray) == 0 && time <= (_timeout + 0.1) ) then {
	hint format['Race complete! (%1s)', ([time - _startTime, 2] call roundTo)];	

	GW_CURRENTVEHICLE say "electronTrigger";
	GW_CURRENTVEHICLE say "summon";

	[
		[_raceName, GW_CURRENTVEHICLE],
		'endRace',
		false,
		false
	] call bis_fnc_mp;	
		
	GW_CHECKPOINTS = [];
	GW_CHECKPOINTS_COMPLETED = [];	

} else {
	hint format['Race failed! (Timeout)', time];
	_cpArray call _abortSequence;
};

if (alive GW_CURRENTVEHICLE && alive (driver GW_CURRENTVEHICLE)) then {

	_timeStamp = (serverTime - GW_CURRENTRACE_START) call formatTimeStamp;

	// Show title if we have a time or DNC
	waitUntil { (isNull (findDisplay 95000)) };
	[ format["<br /><t size='3.3' color='#ffffff' align='center' valign='middle' shadow='0'>+%1</t>", _timeStamp], "FINISH", [false, { true }] , { true }, 9999, true, { closeDialog 0; true }] call createTitle;

	GW_FLYBY_ACTIVE = FALSE;

	GW_CURRENTVEHICLE call destroyInstantly;

	GW_CURRENTRACE = "";

	9999 cutText ["", "BLACK OUT", 0.5];

	waitUntil { Sleep 0.5; (isNull (findDisplay 95000)) };

	//[_vehiclesArray] execVM 'testspectatorcamera.sqf';
	

};


