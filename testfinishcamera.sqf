//
//      Name: flyByCamera
//      Desc: Overview camera once a player passes the finish checkpoint
//      Return: None
//

private ["_cam", "_victim", "_killer", "_centerCamera"];

// _target = [_this,0, getMarkerPos "workshopZone_camera", [objNull, []]] call filterParam;
// _type = [_this,1, "default", [""]] call filterParam;

// Reset kill stats
GW_FLYBY_ACTIVE = true;

// 9999 cutText ["", "BLACK IN", 1.5];  
_startPosition = positionCameraToWorld [0,0,0];
_targetPosition = positionCameraToWorld [0,0,50];

_dirTo = [_startPosition, _targetPosition] call dirTo;

_cam = "camera" camCreate _startPosition;
_cam camSetTarget _targetPosition;
_cam cameraeffect["internal","back"];
_cam camCommit 0;

_cam camSetTarget GW_CURRENTVEHICLE;
_cam camSetRelPos [15,15,10];
_cam camCommit 5;

_timeout = time + 5;
waitUntil {
	(time > _timeout)
};

9999 cutText ["", "BLACK OUT", 0.5];

_camPos = getPos _cam;
_r = [(_camPos distance GW_CURRENTVEHICLE),10,30] call limitToRange;
_phi = 1;
_theta = [GW_CURRENTVEHICLE, _camPos] call dirTo;
_rx = _r * (sin _theta) * (cos _phi);
_ry = _r * (cos _theta) * (cos _phi);
_rz = [(_camPos select 2) * (sin _phi),7,20] call limitToRange;
_cam camSetRelPos [_rx, _ry, _rz];
_cam camCommit 1;


_timeout = time + 1;
waitUntil {
	(time > _timeout)
};

9999 cutText ["", "BLACK IN", 1];

_timeout = time + 9999;
waitUntil {

	_rx = _r * (sin _theta) * (cos _phi);
	_ry = _r * (cos _theta) * (cos _phi);

	_cam camSetRelPos [_rx, _ry, _rz];
	_cam camCommit 0;

	_theta = _theta - 0.2;
	_theta = _theta mod 360;

	_r = _r + 0.0001;
	_rz = _rz + 0.0001;

	((time > _timeout) || !GW_FLYBY_ACTIVE || !GW_TITLE_ACTIVE || !alive GW_CURRENTVEHICLE)

};

player cameraeffect["terminate","back"];
camdestroy _cam;
GW_FLYBY_ACTIVE = false;
"colorCorrections" ppEffectEnable false;
"filmGrain" ppEffectEnable false;


// At least 2 metres away
// _rndX = ((random 50) - 25) + 2;
// _rndY = ((random 50) - 25) + 2; 
// _rndZ = (random 20) + 20;

// // Determine orbit position
// _theta = random 360;
// _r = 7;
// _phi = 1;
// _rx = _r * (sin _theta) * (cos _phi);
// _ry = _r * (cos _theta) * (cos _phi);
// _rz = _r * (sin _phi);

// // Apply to camera
// _cam camSetRelPos [_rx, _ry, _rz];

// while {time < _timeout && GW_FLYBY_ACTIVE} do {

// 	_theta = _theta + 0.001;
// 	_theta = _theta mod 360;

// 	_r = _r + 0.00015;

// 	_rx = _r * (sin _theta) * (cos _phi);
// 	_ry = _r * (cos _theta) * (cos _phi);

// 	_cam camSetRelPos [_rx, _ry, _rz];
// 	_cam camCommit 0;

// };	

// 	};

// 	case "overview":
// 	{
// 		_cam camSetTarget _targetPosition;
// 		_cam cameraeffect["internal","back"];
// 		_cam camCommit 0;

// 		// Determine orbit position
// 		_theta = random 360;
// 		_r = 30;
// 		_phi = 1;
// 		_rx = _r * (sin _theta) * (cos _phi);
// 		_ry = _r * (cos _theta) * (cos _phi);
// 		_rz = 15;

// 		// Apply to camera
// 		_cam camSetRelPos [_rx, _ry, 25];

// 		while {time < _timeout && GW_DEATH_CAMERA_ACTIVE} do {

// 			_theta = _theta + 0.0001;
// 			_theta = _theta mod 360;

// 			_rx = _r * (sin _theta) * (cos _phi);
// 			_ry = _r * (cos _theta) * (cos _phi);
// 			_rz = _rz + 0.0001;

// 			_cam camSetRelPos [_rx, _ry, _rz];
// 			_cam camSetFocus [_r, 0.1];
// 			_cam camCommit 0;

// 		};	
// 	};

// 	default
// 	{	
// 		_cam camSetTarget _target;
// 		_cam cameraeffect["internal","back"];
// 		_cam camCommit 0;		

// 		// Determine orbit position
// 		_theta = random 360;
// 		_r = 150;
// 		_phi = 1;
// 		_rx = _r * (sin _theta) * (cos _phi);
// 		_ry = _r * (cos _theta) * (cos _phi);
// 		_rz = 30;

// 		// Apply to camera
// 		_cam camSetRelPos [_rx, _ry, _rz];

// 		while {time < _timeout && GW_DEATH_CAMERA_ACTIVE} do {

// 			_theta = _theta + 0.00005;
// 			_theta = _theta mod 360;

// 			_rx = _r * (sin _theta) * (cos _phi);
// 			_ry = _r * (cos _theta) * (cos _phi);

// 			_cam camSetRelPos [_rx, _ry, _rz];
// 			_cam camCommit 0;

// 		};	

// 	};

// };

