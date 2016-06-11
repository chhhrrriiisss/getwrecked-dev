//
//      Name: playerKilled
//      Desc: Handles respawn and 'killed by' for dead player
//      Return: None
//

_victim = [_this,0, objNull, [objNull]] call filterParam;
if (isNull _victim) exitWith {};

// Disable hud + lock until spawned
GW_HUD_ACTIVE = false;
GW_HUD_LOCK = true;

["workshopZone"] call setCurrentZone;

if (GW_IGNORE_DEATH_CAMERA) then {} else {
	9999 cutText ["", "BLACK OUT", 0.3];  
};

_prevVehicle = _victim getVariable ["GW_prevVeh", nil];

// Log the death for the last vehicle we were in
if (!isNil "_prevVehicle") then {
    ['death', _prevVehicle, 1, true] call logStat;
};

if (!isNil "GW_CURRENTRACE") then {	

	if (([GW_CURRENTRACE] call checkRaceStatus) == -1) exitWith {};

	[
		[GW_CURRENTRACE, GW_CURRENTVEHICLE],
		'removeFromRace',
		false,
		false
	] call bis_fnc_mp;	

	GW_CURRENTRACE = nil;

};

if(true) exitWith{};