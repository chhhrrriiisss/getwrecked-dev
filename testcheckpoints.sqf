//
//      Name: testCheckpoints
//      Desc: Checkpoints system for races
//      Return: 
//

private ['_points', '_targetRace', '_startPosition', '_raceStatus', '_raceName'];

_points = [];

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

		if (abs _dirDif > 90) exitWith { _isPast = false; 0 };		

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

		// 50/50 Chance of 10% Ammo or Fuel per checkpoint		
		if (random 100 > 50) then {

			// Give 10% ammo
			_maxAmmo = GW_CURRENTVEHICLE getVariable ["maxAmmo", 1];
			_targetAmmo = [_maxAmmo * 0.1, 1] call roundTo;
			_newAmmo = [(GW_CURRENTVEHICLE getVariable ["ammo", 0]) + _targetAmmo, 0, _maxAmmo] call limitToRange;
			GW_CURRENTVEHICLE setVariable ["ammo", _newAmmo];

			["", 1, plusAmmoIcon, [0,0,0,0.5], "slideUp", "upgrade"] execVM 'client\ui\hud\alert_new.sqf';

		} else {

			// Give 10% fuel per checkpoint
			_maxFuel = GW_CURRENTVEHICLE getVariable ["maxFuel", 1];
			_totalFuel = _maxFuel + fuel GW_CURRENTVEHICLE;
			_targetFuel = [_totalFuel * 0.1, 1] call roundTo;
			if (_targetFuel < 0.99) then {	
				_newFuel = [fuel GW_CURRENTVEHICLE + _targetFuel, 0, 1] call limitToRange;
				GW_CURRENTVEHICLE setFuel _newFuel;
			} else { 
				GW_CURRENTVEHICLE setFuel 1;
				__newFuel = [(GW_CURRENTVEHICLE getVariable ["fuel", 0]) + (_targetFuel - 1), 0, _maxFuel] call limitToRange;
				GW_CURRENTVEHICLE setVariable ["fuel", _newFuel];
			};	

			["", 1, plusFuelIcon, [0,0,0,0.5], "slideUp", "upgrade"] execVM 'client\ui\hud\alert_new.sqf';

		};

		_timeStamp = (serverTime - GW_CURRENTRACE_START) call formatTimeStamp;
		_timeStamp = format['+%1', _timeStamp];
		GW_CURRENTVEHICLE say "blipCheckpoint";		

	
		GW_CHECKPOINTS_COMPLETED pushback [(GW_CHECKPOINTS select GW_CHECKPOINTS_PROGRESS), _timeStamp, 1];

		GW_CHECKPOINTS_PROGRESS = GW_CHECKPOINTS_PROGRESS + 1;

		if (GW_CHECKPOINTS_PROGRESS == count GW_CHECKPOINTS) exitWith {};

		// Delete previous checkpoint group 
		{ 
			deleteVehicle _x;
		} foreach _checkpointGroup;

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

_raceID =  ((_raceName call getRaceID) select 1);

_vehiclesArray = [GW_ACTIVE_RACES, _raceID, [], [[]]] call filterParam;
_vehiclesArray = [_vehiclesArray, 4, allPlayers, [[]]] call filterParam;

if ( time <= (_timeout + 0.1) ) then {
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
};

if (alive GW_CURRENTVEHICLE && alive (driver GW_CURRENTVEHICLE)) then {

	// Slow vehicle down
	[] spawn { 
		_timeout = time + 3;
		waitUntil { [GW_CURRENTVEHICLE, 0.97] spawn slowDown;  time > _timeout };
	};

	GW_HUD_ACTIVE = false;
	GW_HUD_LOCK = TRUE;

	// Spawn camera transition
	_handle = [] execVM 'testorbitcamera.sqf';

	// Show blank title while waiting
	// waitUntil { (isNull (findDisplay 95000)) };
	// [] spawn { ["", "", [false, { false }] , { !isNil "GW_CR_F" }, 9999, true, { closeDialog 0; }] call createTitle; };

	// Wait 3 seconds for server to tell us our time/position
	GW_CR_F = nil;
	_timeout = time + 3;
	waitUntil {
		!isNil "GW_CR_F" || time > _timeout
	};

	// If server hasn't responded, use local time
	if (isNil "GW_CR_F") then { 
		_timeStamp = (serverTime - GW_CURRENTRACE_START) call formatTimeStamp;
		GW_CR_F = [_timeStamp, 0]; 
	};

	_raceTime = (GW_CR_F select 0);	
	_racePosition = (GW_CR_F select 1);	

	// If we came first, log as race win
	if (_racePosition == 1) then { ['racewin', GW_CURRENTVEHICLE, 1, true] call logStat; };

	// Show title if we have a time or DNC
	waitUntil { (isNull (findDisplay 95000)) };	

	_exitFunction =	{  	
		9999 cutText ["", "BLACK", 0.01]; 
		GW_IGNORE_DEATH_CAMERA = true; 
		closeDialog 0;	
		true
	};

	_racePosition = if (_racePosition == 0) then { 'RACE COMPLETE' } else {
		_desc = _racePosition call {
			if (_this == 1) exitWith {'ST'};
			if (_this == 2) exitWith {'ND'};
			if (_this == 3) exitWith {'RD'};
			'TH'
		};
		format['YOU FINISHED %1%2', _racePosition, _desc]
	};

	// Show new title with time/position
	[ format["<t size='3.3' color='#ffffff' align='center' valign='middle' shadow='0'>%1</t><br /><t size='3.3' color='#ffffff' align='center' valign='middle' shadow='0'>+%2</t>", _racePosition, _raceTime call formatTimestamp], "RESPAWN", [false, { true }] , { true }, 9999, true, _exitFunction] call createTitle;
	
	Sleep 0.5; 

	terminate _handle;

	GW_CURRENTVEHICLE call destroyInstantly;

	GW_CURRENTRACE = "";

};

// Delete previous checkpoint group 
{ 
	deleteVehicle _x;
} foreach _checkpointGroup;


