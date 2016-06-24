dirTo = {

	//
	//      Name: dirTo
	//      Desc: Gets heading between object a > b
	//      Return: Direction
	//

	private ['_p1', '_p2', '_dx', '_dy', '_h', '_o1', '_o2'];
	params ['_o1', '_o2'];

	_p1 = if (_o1 isEqualType objNull) then { (ASLtoATL getPosASL _o1) } else { _o1 };
	_p2 =  if (_o2 isEqualType objNull) then { (ASLtoATL getPosASL _o2) } else { _o2 };

	if ( !(_p1 isEqualType []) || !(_p2 isEqualType []) ) exitWith { 0 };

	_dx = (_p2 select 0) - (_p1 select 0); 
	_dy = (_p2 select 1) - (_p1 select 1);

	_h = _dx atan2 _dy; 

	if (_h < 0) exitWith { (_h + 360) }; 

	_h

};

limitToRange = {

	//
	//      Name: limitToRange
	//      Desc: Ensures a number is between the given values, optionally loops the values if they escape the range
	//      Return: Number (Corrected to be inside range)
	//

	private ['_v', '_nV', '_r1', '_r2', '_c'];

	_v = [_this, 0, 0, [0]] call filterParam;
	_r1 = [_this, 1, 0, [0]] call filterParam;
	_r2 = [_this, 2, 0, [0]] call filterParam;
	_c = [_this, 3, false, [false]] call filterParam;

	if (_v < _r1) exitWith { 
	_nV = if (_c) then {_r2} else {_r1};
	_nV
	};

	if (_v > _r2) exitWith { 
	_nV = if (_c) then {_r1} else {_r2};
	_nV
	};

	_v

};

filterParam = {

//
//      Name: filterParam
//      Desc: Indentical usage to bis_fnc_param, but faster
//      Return: Variable (filtered)
//

	private ['_arr'];

	_arr = +_this;
	_this = _arr deleteAt 0;

	(param _arr)

};

relPos = {
	_s = [_this, 0, false, [objNull, []]] call filterParam;
	_r = [_this, 1, 0, [0]] call filterParam;
	_dir = [_this, 2, 0, [0]] call filterParam;

	if (_s isEqualType true) exitWith { [0,0,0] };
	_s = if (_s isEqualType objNull) then { 
	if (GW_Client) exitWith { (ASLtoATL visiblePositionASL _s) };
	(ASLtoATL getPosASL _s) 
	} else { _s };

	_sx = _r * (sin _dir) * (cos 1);
	_sy = _r * (cos _dir) * (cos 1);

	[(_s select 0) + _sx, (_s select 1) + _sy, (_s select 2)]

};


// seekerTargets = [
// 	TEST0,
// 	TEST1,
// 	TEST2,
// 	TEST3
// ];

// selectTargetFromList = {
		
// 	private ['_count'];

// 	_count = if (isNIl "_this select 0") then { 0 } else { (_this select 0) };
// 	_maxRepeats = 5;
// 	if (_count > _maxRepeats) exitWith { objNull };	

// 	_targets = +seekerTargets;
// 	_targets deleteAt (_targets find (vehicle player));

	

// 	_rndLength = ceil (random (count _targets - 1));

// 	systemchat str _rndLength;
	
// 	_targets resize _rndLength;
// 	_selected = selectRandom _targets;

// 	_count = _count + 1;
// 	if (!alive _selected) exitWith {
// 		([_count] call selectTargetFromList)
// 	};

// 	_selected

// };

player allowdamage false;

// _target = ([] call selectTargetFromList);

// if (isNull _target) exitWith { systemchat 'No targets available.'; };
// _target = TEST2;

_target = (vehicle player);

_launchPos = [(ASLtoATL visiblePositionASL _target), (random 2000) + 1000, random 360] call relPos;
_launchPos set [2, 50];
// _launchPos = (vehicle player) modelToWorldVisual [0,0,5];
_targetPos = (ASLtoATL visiblePositionASL _target);
_round = "M_Titan_AT";
_missile = createVehicle [_round, _launchPos, [], 0, "FLY"];	

// _heading = [ATLtoASL _launchPos,ATLtoASL _targetPos] call BIS_fnc_vectorFromXToY;

// _missile setVectorDir _heading; 
// _missile setVelocity _velocity; 

	// addCamShake [.5, 1,30];
	// playSound3D [_soundToPlay, _gun, false, visiblePositionASL _gun, 1, 1, 50];		

_timeout = time + 60;

// _camEnabled = if (_this) then { true } else { false };

// Set initial position
// _cam = "camera" camCreate _launchPos;
// showCinemaBorder false;
// _cam cameraEffect ["internal","back"];
// _cam camSetTarget _missile;
// _cam camSetRelPos [0,-1,0.05];
// _cam camCommit 0;

END_MISSILE = false;

_dirTo = [_missile, _target] call dirTo;
_cruiseAltitude = 80;
_prepPos = [_launchPos, _cruiseAltitude / 4, _dirTo] call relPos;

_prepPos set [2, (_prepPos select 2) + _cruiseAltitude];

_reachedCruise = false;
_xVariance = 0;
_yVariance = 0;

_speed = 35;

// [_cam, _missile, player, 2] call bis_fnc_liveFeed;

_beepFrequency = 1;
_lastBeep = time - _beepFrequency;
_initDistance = _launchPos distance _targetPos;

GW_WARNINGICON_ARRAY pushBack _missile;

// Tracking phase
for "_i" from 0 to 1 step 0 do {

	if (!alive _target) then {
		_target = [] call selectTargetFromList;
	};

	if (isNull _target) exitWith {};
	
	_missilePos = visiblePositionASL _missile;
	_targetPos = if (_reachedCruise) then { visiblePositionASL _target } else { _prepPos };
	_heightAboveTerrain = _missilePos select 2;
	_distanceToTarget = _missilePos distance _targetPos;	

	if (time - _lastBeep > _beepFrequency) then {

		_lastBeep = time;
		_beepFrequency = [(_distanceToTarget / _initDistance), 0.15, 1] call limitToRange;


		_missile say3D "beep_light";

		// Send target beep
		[		
			[
				_target,
				"beep_light",
				100
			],
			"playSoundAll",
			_target,
			false
		] call bis_fnc_mp;	 


	};

	if (_distanceToTarget < 5 && _reachedCruise) exitWith {
		_bomb = createVehicle ["Bo_GBU12_LGB", (ASLtoATL visiblePositionASL _target), [], 0, "FLY"];	
		//_target setDammage 1;
	};

	if (_heightAboveTerrain > _cruiseAltitude) then { _reachedCruise = true; };

	if (!alive _missile || time > _timeout || END_MISSILE) exitWith {};


	_speed = if (_reachedCruise) then { _speed = _speed + 0.02; ([_speed, 35, 200] call limitToRange) } else { 35 };


	_heading = [_missilePos,_targetPos] call BIS_fnc_vectorFromXToY;




	// _cam camSetTarget _missile;
	// _cam camSetRelPos [0,-3,1];
	// _cam camPrepareFOV 0.6;
	// _cam camCommit 0;

	// _heading set [2, 0];

	// if (_heightAboveTerrain < _cruiseAltitude) then {
	// 	_heading set[2, 0];
	// 	_velocity set [2, 0];
	// };

	_velocity = [_heading, _speed] call BIS_fnc_vectorMultiply; 	

	_intersects = lineIntersectsSurfaces [ATLtoASL (_missile modelToWorldVisual	[0,0,0]), _targetPos, _missile, _target, false, 1];

	// If we detected a collision, avoid it
	if (count _intersects > 0 ) then {



		systemchat format['intersect - evading! %1', time];

		_distanceToIntersect = ((_intersects select 0) select 0) distance _missilePos;

		if (_distanceToIntersect > 150) exitWith {};

		_increaseToApply = [150 - _distanceToIntersect, 20, 150] call limitToRange;

		// systemchat str _increaseToApply;

		// _heading set [2, 0];
		_velocity set [2, (_velocity select 2) + _increaseToApply];

	} else {

		systemchat format['no intersects', time];

		if (_heightAboveTerrain > _cruiseAltitude) then {
			_velocity set [2, -10];
		};

	};

	_velocity set [0, (_velocity select 0) + (sin random 50) * 100];
	_velocity set [1, (_velocity select 1) + (sin random 50) * 100];
	_velocity set [2, (_velocity select 2) + (sin random 10) * 100];

	// _yVariance = _yVariance + (random 0.01);
	// _velocity set [1, (_velocity select 1) + _yVariance];

	//  else {

	// 	if (_heightAboveTerrain > _cruiseAltitude) exitWith {
	// 		_velocity set [2, (_velocity select 2) - 1];
	// 	};		

	// };

	// if (_heightAboveTerrain < _cruiseAltitude) then {
		
	// 	_velocity set [2, (_velocity select 2) + 1];
	// };
	
	// _missile setVectorDirAndUp[_heading, _heading];
	//_missile setDir _dirTo;
	_missile setVectorDir (_heading vectorAdd [0,0,1]);
	_missile setVelocity _velocity; 



};

GW_WARNINGICON_ARRAY = GW_WARNINGICON_ARRAY - [_missile];

deleteVehicle _missile;

Sleep 2;

// [] call bis_fnc_liveFeedTerminate;
// camdestroy _cam;
player cameraeffect["terminate","back"];