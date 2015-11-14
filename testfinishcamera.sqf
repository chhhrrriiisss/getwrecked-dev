//
//      Name: testfinishcamera
//      Desc: 
//      Return: 
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

_camPos = getPos _cam;
_r = [(_camPos distance GW_CURRENTVEHICLE),10,30] call limitToRange;
_phi = 1;
_theta = [GW_CURRENTVEHICLE, _camPos] call dirTo;
_rx = _r * (sin _theta) * (cos _phi);
_ry = _r * (cos _theta) * (cos _phi);
_rz = [(_camPos select 2) * (sin _phi),7,20] call limitToRange;
_cam camSetRelPos [_rx, _ry, _rz];
_cam camCommit 5;

_timeout = time + 5;
waitUntil {
	(time > _timeout)
};

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

	((time > _timeout) || !GW_FLYBY_ACTIVE || GW_SPECTATOR_ACTIVE || !alive GW_CURRENTVEHICLE)

};

if (!GW_SPECTATOR_ACTIVE) then { player cameraeffect["terminate","back"]; };
camdestroy _cam;
GW_FLYBY_ACTIVE = false;
"colorCorrections" ppEffectEnable false;
"filmGrain" ppEffectEnable false;

