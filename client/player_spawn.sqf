//
//      Name: playerSpawn
//      Desc: Handles texture, weapon assignments and death camera for a newly spawned player
//      Return: None
//

_unit = [_this,0, objNull, [objNull]] call filterParam;
if (isNull _unit) exitWith {};
if (!local _unit) exitWith {};

waitUntil { !isNull _unit && (alive _unit) }; 

45000 cutText ["", "BLACK IN", 1.5]; 

removeAllActions _unit;
removeAllWeapons _unit;
removeVest _unit;
removeBackpack _unit;
removeGoggles _unit;
removeAllPrimaryWeaponItems _unit;
removeallassigneditems _unit;

_unit addItem "ItemMap";
_unit assignItem "ItemMap";

// Reset just in case
GW_WAITFIRE = false;
GW_WAITUSE = false;
GW_WAITLIST = [];
GW_WAITEDIT = false;   
GW_WAITALERT = false;
GW_WAITSAVE = false;
GW_WAITLOAD = false;
GW_WAITCOMPILE = false;
GW_EDITING = false;
GW_LIFT_ACTIVE = false;
GW_SPAWN_ACTIVE = false;
GW_DIALOG_ACTIVE = false;

// Force hud refresh
GW_HUD_ACTIVE = false;

_tx = _unit getVariable ["texture", ""];

if (_tx == "") then {
	_tx = "slytech";
};

// Auto remove racing helmets for people without the DLC
_hasDLC = if ( (288520 in (getDLCs 1)) || (304400 in (getDLCs 1)) ) then { true } else { false };

// For people with the dlc, add helmets
if (_hasDLC) then {

	switch (_tx) do {
		
		case "slytech": { _unit addheadgear "H_RacingHelmet_1_white_F"; };
		case "crisp": { _unit addheadgear "H_RacingHelmet_1_red_F"; };
		case "gastrol": { _unit addheadgear "H_RacingHelmet_1_black_F"; };
		case "haywire": { _unit addheadgear "H_RacingHelmet_1_black_F"; };
		case "cognition": { _unit addheadgear "H_RacingHelmet_1_white_F"; };
		case "terminal": { _unit addheadgear "H_RacingHelmet_1_red_F"; };
		case "tank": { _unit addheadgear "H_RacingHelmet_1_black_F"; };
		case "veneer": { _unit addheadgear "H_RacingHelmet_1_white_F"; };
		default { _unit addheadgear "H_RacingHelmet_1_black_F"; };
	};

} else {
	_unit addHeadgear "H_PilotHelmetHeli_B";
};
	
if(!isNil "_tx") then {
	_unit setVariable ["GW_Sponsor", _tx];
	[[_unit,_tx],"setPlayerTexture",true,false] call gw_fnc_mp;
};

playerPos = (ASLtoATL getPosASL _unit);

// Reset pp
"dynamicBlur" ppEffectEnable false; 
"colorCorrections" ppEffectEnable false; 

_firstSpawn = _unit getVariable ["firstSpawn", false];

// Not our first time here, use the death camera to watch our last target for a bit
if (!_firstSpawn) then {

	_killedBy = profileNamespace getVariable ['killedBy', nil];

	if (!isNil "_killedBy") then {

		// If killed by exists, trigger camera on killer		
		[_unit, _killedBy] spawn deathCamera;

	} else {
		// Not sure if killed by, trigger camera on default location		
		[_unit, _unit] spawn deathCamera;
	};

	_failSpawn = false;
	_location = [spawnAreas, ["Car", "Man"]] call findEmpty;

	// If we've failed to find an empty one, just use the first in the list
	_pos = if (typename _location == "ARRAY") then { _failSpawn = true; (ASLtoATL getPosASL (spawnAreas select 0)) } else { _unit setDir (getDir _location); (ASLtoATL getPosASL _location) };
	_unit setPosATL _pos;	
	

	if (!isNil "GW_LASTLOAD" && !_failSpawn) then {
		_closest = [saveAreas, _pos] call findClosest; 
		[(ASLtoATL getPosASL _closest), GW_LASTLOAD] spawn requestVehicle;
	};

} else {	

	// Show the screen
	_unit setVariable ["firstSpawn", false];	
	titlecut["","BLACK IN",2];	
	
};

// Wait for the death camera to be active before setting the current zone
_timeout = time + 3;
waitUntil { (time > _timeout) || GW_DEATH_CAMERA_ACTIVE };
['workshopZone'] call setCurrentZone;

// Clear/Unsimulate unnecessary items near workshop
{
	_i = _x getVariable ['GW_IGNORE_SIM', false];
	if ( (isPlayer _x || _x isKindOf "car") && !_i) then { _x enableSimulation true; } else { _x enableSimulation false; };
	false
} count (nearestObjects [ (getMarkerPos "workshopZone_camera"), [], 200]) > 0;

// Force save the profileNameSpace
['kill', '', true] call logStat;

// Reset killed by as we need to start fresh
profileNamespace setVariable ['killedBy', nil];
saveProfileNamespace;

waitUntil {Sleep 0.1; !isNil "serverSetupComplete"};

_unit spawn setPlayerActions;

_unit setVariable ['GW_Playername', GW_PLAYERNAME, true];

waitUntil {
	
	_currentPos = (ASLtoATL (getPosASL player));
	_vehicle = (vehicle player);
	_inVehicle = !(player == _vehicle);
	_isDriver = (player == (driver _vehicle));

	if (visibleMap) then {
		GW_HUD_ACTIVE = false;
	};

	// Restore the HUD if we're somewhere that needs it
	if (GW_DEATH_CAMERA_ACTIVE || GW_PREVIEW_CAM_ACTIVE || GW_TIMER_ACTIVE || GW_GUIDED_ACTIVE || GW_SETTINGS_ACTIVE || GW_LOADING_ACTIVE || visibleMap) then {} else {
		if (!GW_HUD_ACTIVE) then {	
			[] spawn drawHud;
		};
	};
	
	// Adds actions to nearby objects & vehicles
	if (!isNil "GW_CURRENTZONE") then {

		if (GW_CURRENTZONE == "workshopZone" && !_inVehicle && !GW_EDITING) then {		
			[_currentPos] spawn checkNearbyActions;
		};

		// Set view distance depending on where we are
		if (GW_CURRENTZONE == "workshopZone" && (!GW_PREVIEW_CAM_ACTIVE && !GW_DEATH_CAMERA_ACTIVE)) then {
			if (viewDistance != 400) then { setViewDistance 400; };
		} else {
			if (viewDistance != GW_EFFECTS_RANGE) then { setViewDistance GW_EFFECTS_RANGE; };
		};

		if ( count GW_CURRENTZONE_DATA > 0) then {

			_inZone = [_currentPos, GW_CURRENTZONE_DATA ] call checkInZone;

			if (_inZone) then {
				_unit setVariable ["outofbounds", false];	
			} else {
				_outOfBounds = _unit getVariable ["outofbounds", false];	
				if ( !_outOfBounds && !GW_DEATH_CAMERA_ACTIVE) then {
					// Activate the incentivizer
					[_unit] spawn returnToZone;
				};
			};

		} else {
			_unit setVariable ["outofbounds", false];	
		};	

	};

	Sleep 0.5;

	(!alive _unit)

};

if (true) exitWith {};