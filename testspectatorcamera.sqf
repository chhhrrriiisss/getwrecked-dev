//
//      Name: spectatorCamera
//      Desc: ""
//      Return: None
//

private ["_c", "_timeout", "_pos"];

if (GW_SPECTATOR_ACTIVE) exitWith {};	
GW_HUD_ACTIVE = false;
GW_SPECTATOR_ACTIVE = true;

disableSerialization;
if(!(createDialog "GW_Spectator")) exitWith { GW_SPECTATOR_ACTIVE = false; }; 

// 9999 cutText ["", "BLACK IN", 1.5];  
GW_SPECTATOR_TARGET = [_this,0, GW_CURRENTVEHICLE, [objNull, []]] call filterParam;

_r = 20;
_phi = 1;
_theta = random 360;
_rx = _r * (sin _theta) * (cos _phi);
_ry = _r * (cos _theta) * (cos _phi);
_rz = 12 * (sin _phi);

_pos = if (typename GW_SPECTATOR_TARGET == "OBJECT") then { (ASLtoATL visiblePositionASL GW_SPECTATOR_TARGET) } else { GW_SPECTATOR_TARGET };
_c = "camera" camCreate _pos;
_c camSetTarget GW_SPECTATOR_TARGET;
_c camSetRelPos [_rx, _ry , _rz];
_c camCommit 5;

_timeout = time + 5;
waitUntil {
	((time > _timeout) || isNull (findDisplay 104000))
};

_timeout = time + 99999;
_currentTarget = GW_SPECTATOR_TARGET;

waitUntil {

	if (_currentTarget != GW_SPECTATOR_TARGET) then {
		_c camSetTarget GW_SPECTATOR_TARGET;
		_c camCommit 5;
		_currentTarget = GW_SPECTATOR_TARGET;
	};	

	_theta = _theta + 0.001;
	_theta = _theta mod 360;

	_r = _r + 0.00015;

	_rx = _r * (sin _theta) * (cos _phi);
	_ry = _r * (cos _theta) * (cos _phi);

	_c camSetRelPos [_rx, _ry, _rz];
	_c camCommit 0;

	((time > _timeout) || (!GW_SPECTATOR_ACTIVE) || isNull (findDisplay 104000))
};	

player cameraeffect["terminate","back"];
camdestroy _c;
GW_SPECTATOR_ACTIVE = false;
"colorCorrections" ppEffectEnable false;
"filmGrain" ppEffectEnable false;
closeDialog 0;

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
// _c camSetRelPos [_rx, _ry, _rz];

// while {time < _timeout && GW_FLYBY_ACTIVE} do {

// 	_theta = _theta + 0.001;
// 	_theta = _theta mod 360;

// 	_r = _r + 0.00015;

// 	_rx = _r * (sin _theta) * (cos _phi);
// 	_ry = _r * (cos _theta) * (cos _phi);

// 	_c camSetRelPos [_rx, _ry, _rz];
// 	_c camCommit 0;

// };	

// 	};

// 	case "overview":
// 	{
// 		_c camSetTarget _targetPosition;
// 		_c cameraeffect["internal","back"];
// 		_c camCommit 0;

// 		// Determine orbit position
// 		_theta = random 360;
// 		_r = 30;
// 		_phi = 1;
// 		_rx = _r * (sin _theta) * (cos _phi);
// 		_ry = _r * (cos _theta) * (cos _phi);
// 		_rz = 15;

// 		// Apply to camera
// 		_c camSetRelPos [_rx, _ry, 25];

// 		while {time < _timeout && GW_DEATH_cERA_ACTIVE} do {

// 			_theta = _theta + 0.0001;
// 			_theta = _theta mod 360;

// 			_rx = _r * (sin _theta) * (cos _phi);
// 			_ry = _r * (cos _theta) * (cos _phi);
// 			_rz = _rz + 0.0001;

// 			_c camSetRelPos [_rx, _ry, _rz];
// 			_c camSetFocus [_r, 0.1];
// 			_c camCommit 0;

// 		};	
// 	};

// 	default
// 	{	
// 		_c camSetTarget _target;
// 		_c cameraeffect["internal","back"];
// 		_c camCommit 0;		

// 		// Determine orbit position
// 		_theta = random 360;
// 		_r = 150;
// 		_phi = 1;
// 		_rx = _r * (sin _theta) * (cos _phi);
// 		_ry = _r * (cos _theta) * (cos _phi);
// 		_rz = 30;

// 		// Apply to camera
// 		_c camSetRelPos [_rx, _ry, _rz];

// 		while {time < _timeout && GW_DEATH_cERA_ACTIVE} do {

// 			_theta = _theta + 0.00005;
// 			_theta = _theta mod 360;

// 			_rx = _r * (sin _theta) * (cos _phi);
// 			_ry = _r * (cos _theta) * (cos _phi);

// 			_c camSetRelPos [_rx, _ry, _rz];
// 			_c camCommit 0;

// 		};	

// 	};

// };

