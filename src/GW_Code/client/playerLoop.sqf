if (isNil "GW_INT_MONITOR_LAST_UPDATE") then { GW_INT_MONITOR_LAST_UPDATE = time; };
['Interaction Update', (format['%1', ([time - GW_INT_MONITOR_LAST_UPDATE, 2] call roundTo)])] call logDebug;
GW_INT_MONITOR_LAST_UPDATE = time;

GW_CURRENTPOS = (ASLtoATL visiblePositionASL player);

// Restore the HUD if we're somewhere that needs it
if (GW_DEATH_CAMERA_ACTIVE || GW_PREVIEW_CAM_ACTIVE || GW_SPECTATOR_ACTIVE || GW_TIMER_ACTIVE || GW_TITLE_ACTIVE || GW_GUIDED_ACTIVE || GW_SETTINGS_ACTIVE || GW_LOADING_ACTIVE || GW_LOBBY_ACTIVE) then {
	if (GW_HUD_ACTIVE) then { GW_HUD_ACTIVE = false; };
} else {
	if (!GW_HUD_ACTIVE && !GW_HUD_LOCK) then {	
		[] spawn drawHud;
	};
};

// Update vehicle damage
GW_CURRENTVEHICLE call updateVehicleDamage;

// Toggle simulation back if we lose it for any reason
if (!simulationEnabled GW_CURRENTVEHICLE) then { GW_CURRENTVEHICLE enableSimulation true; };

// Every 5 seconds, track mileage + alive state
_remainder = round (time) % 5;
if (_remainder == 0) then {
	
	// Log time alive
	if (alive GW_CURRENTVEHICLE) then {
		['timeAlive', GW_CURRENTVEHICLE, 5] call logStat;
	};
	
	// Track mileage
	_currentPos = GW_CURRENTPOS;
	_prevPos = GW_CURRENTVEHICLE getVariable ['GW_prevPos', _currentPos];	

	_distanceTravelled = _prevPos distance _currentPos;   
	if (_distanceTravelled > 3) then {       
	    ['mileage', GW_CURRENTVEHICLE, _distanceTravelled] call logStat;  
	};

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

};

// Debugging
if (!GW_DEBUG) exitWith {};
if (isNil "GW_DEBUG_ARRAY") then {	GW_DEBUG_ARRAY = []; };
if (GW_DEBUG_ARRAY isEqualTo []) exitWith {};

GW_DEBUG_MONITOR_LAST_UPDATE = time;
_totalString = format["[   DEBUG MODE   ] \n\n Time: %1\n Zone: %2\n Player: %3\n FPS: %4\n FPSMIN: %5\n", time, GW_CURRENTZONE, name player, [diag_fps, 0] call roundTo, [diag_fpsMIN, 0] call roundTo];
{	_totalString = format['%1 \n %2: %3', _totalString, (_x select 0), (_x select 1)];	false	} count GW_DEBUG_ARRAY > 0;

hintSilent _totalString;
