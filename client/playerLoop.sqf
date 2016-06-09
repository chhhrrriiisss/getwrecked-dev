if (isNil "GW_INT_MONITOR_LAST_UPDATE") then { GW_INT_MONITOR_LAST_UPDATE = time; };
['Interaction Update', (format['%1', ([time - GW_INT_MONITOR_LAST_UPDATE, 2] call roundTo)])] call logDebug;
GW_INT_MONITOR_LAST_UPDATE = time;

GW_CURRENTPOS = (ASLtoATL visiblePositionASL player);

// Restore the HUD if we're somewhere that needs it
if (GW_DEATH_CAMERA_ACTIVE || GW_PREVIEW_CAM_ACTIVE || GW_SPECTATOR_ACTIVE || GW_TIMER_ACTIVE || GW_TITLE_ACTIVE || GW_GUIDED_ACTIVE || GW_SETTINGS_ACTIVE || GW_LOADING_ACTIVE || GW_HUD_LOCK || GW_LOBBY_ACTIVE) then {} else {
	if (!GW_HUD_ACTIVE) then {	
		[] spawn drawHud;
	};
};

// Update vehicle damage
GW_CURRENTVEHICLE call updateVehicleDamage;

// Toggle simulation back if we lose it for any reason
if (!simulationEnabled GW_CURRENTVEHICLE) then { GW_CURRENTVEHICLE enableSimulation true; };

// Every 5 seconds, record position, ignoring while in parachute
_remainder = round (time) % 5;
_hasMoved = false;

if (_remainder == 0 && (typeOf GW_CURRENTVEHICLE != "Steerable_Parachute_F")) then {
	
	_prevPos = GW_CURRENTVEHICLE getVariable ['GW_prevPos', nil];
	_currentPos = ASLtoATL visiblePositionASL GW_CURRENTVEHICLE;

	// If there's position data stored and we're not at the workshop
	if (!isNil "_prevPos") then {

		_distanceTravelled = _prevPos distance _currentPos;   
		if (_distanceTravelled > 3) then {       
		    ['mileage', GW_CURRENTVEHICLE, _distanceTravelled] call logStat;  
		    _hasMoved = true; 
		};
	};

	// Log time alive
	if (isNil "GW_LASTPOSCHECK") then { GW_LASTPOSCHECK = time;	};  
	_timeAlive = (time - GW_LASTPOSCHECK);
	if (_timeAlive > 0) then {	['timeAlive', GW_CURRENTVEHICLE, _timeAlive] call logStat;  };
	GW_LASTPOSCHECK = time;   

	GW_CURRENTVEHICLE setVariable ['GW_prevPos', _currentPos];
	player setVariable ['GW_prevPos', _currentPos];

};

if (!isNil "GW_CURRENTZONE") then {
   
    // Add actions to nearby objects
	if (GW_CURRENTZONE == "workshopZone" && !GW_INVEHICLE && !GW_EDITING) then {		
		[GW_CURRENTPOS] spawn checkNearbyActions;
	};

	// Invulnerability toggle
	GW_INVULNERABLE = false;
	if (GW_CURRENTZONE == "workshopZone" || (GW_INVEHICLE && GW_CURRENTZONE != "workshopZone")) then { GW_INVULNERABLE = true; };

	// Set view distance depending on where we are
	if (GW_CURRENTZONE == "workshopZone" && (!GW_PREVIEW_CAM_ACTIVE && !GW_DEATH_CAMERA_ACTIVE)) then {
		if (viewDistance != GW_WORKSHOP_VISUAL_RANGE) then { setViewDistance GW_WORKSHOP_VISUAL_RANGE; };
	} else {
		if (viewDistance != GW_EFFECTS_RANGE) then { setViewDistance GW_EFFECTS_RANGE; };
	};

	// Ignore out of bounds checks for zoneImmune vehicles
	_zoneImmune = GW_CURRENTVEHICLE getVariable ['GW_ZoneImmune', false];
	if (count GW_CURRENTZONE_DATA > 0 && !_zoneImmune) then {

		_inZone = [GW_CURRENTPOS, GW_CURRENTZONE_DATA ] call checkInZone;

		if (_inZone) then {
			player setVariable ["outofbounds", false];	
		} else {
			_outOfBounds = player getVariable ["outofbounds", false];	
			if ( !_outOfBounds && !GW_DEATH_CAMERA_ACTIVE) then {
				// Activate the incentivizer
				[player] spawn returnToZone;
			};
		};

	} else {
		player setVariable ["outofbounds", false];	
	};	

	// Check if near edge-of-zone sections and render them

};

// Debugging
if (!GW_DEBUG) exitWith {};
if (isNil "GW_DEBUG_ARRAY") then {	GW_DEBUG_ARRAY = []; };
if (GW_DEBUG_ARRAY isEqualTo []) exitWith {};

GW_DEBUG_MONITOR_LAST_UPDATE = time;
_totalString = format["[   DEBUG MODE   ] \n\n Time: %1\n Zone: %2\n Player: %3\n FPS: %4\n FPSMIN: %5\n", time, GW_CURRENTZONE, name player, [diag_fps, 0] call roundTo, [diag_fpsMIN, 0] call roundTo];
{	_totalString = format['%1 \n %2: %3', _totalString, (_x select 0), (_x select 1)];	false	} count GW_DEBUG_ARRAY > 0;

hintSilent _totalString;


// Periodically check what part of the boundary is visible and update accordingly
// _points = [];

// {
// 	if ((_x select 0) == GW_CURRENTZONE) exitWith { _points = (_x select 2); false };
// 		false
// } count GW_ZONE_BOUNDARIES;

// _step  = floor ((count _points) / 72);

// for "_i" from 0 to ((count _points)-1) step _step do {

// 	//hint format['%1', ((_points select _i) select 0)];
// 	_obj = (((GW_ACTIVE_BOUNDARIES select 1) select 1) select _i);
// 	_lastUpdate = _obj getVariable ['lastUpdate', time - 5];
// 	if ((time - _lastUpdate) < 5) then {} else {
// 		_obj setVariable ['lastUpdate', time];

// 		_inRange = if ( (_currentPos distance ((_points select _i) select 0)) < 50) then { true } else { false };
// 		if (_inRange) then {

// 			// If the object is already hidden, don't bother
// 			if (!isObjectHidden _obj) exitWith {};

// 			_rangeL = [_i - (_step / 2), 0, (count _points) -1] call limitToRange;
// 			_rangeR = [_i + (_step / 2), 0, (count _points) -1] call limitToRange;			

// 			[_rangeL, _rangeR] spawn {

// 				for "_y" from (_this select 0) to (_this select 1) step 1 do {		
// 					(((GW_ACTIVE_BOUNDARIES select 1) select 1) select _y) hideObject false;
// 				};

// 				Sleep 4;

// 				for "_y" from (_this select 0) to (_this select 1) step 1 do {
// 					(((GW_ACTIVE_BOUNDARIES select 1) select 1) select _y) hideObject true;
// 				};



// 			};

// 		};
// 	};
// };