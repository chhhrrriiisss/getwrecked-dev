//
//      Name: drawDisplay
//      Desc: Main loop for rendering icons and hud indicators to the screen
//      Return: None
//



if(!hasInterface) exitWith {};
	
// Main HUD
if (!isNil "GW_DISPLAY_EH") then {
	removeMissionEventHandler ["Draw3D", GW_DISPLAY_EH];
	GW_DISPLAY_EH = nil;
};

GW_DISPLAY_EH = addMissionEventHandler ["Draw3D", {
	
	
	// Auto close inventories
	disableSerialization;
    if (!isNull (findDisplay 602)) then  { closeDialog 602; };

	// Get all the conditions we need
	GW_CURRENTVEHICLE = (vehicle player);		
	GW_VEHICLE_STATUS = GW_CURRENTVEHICLE getVariable ["status", []];
	GW_VEHICLE_SPECIAL = GW_CURRENTVEHICLE getVariable ["special", []];

	GW_HASLOCKONS = GW_CURRENTVEHICLE getVariable ["lockOns", false];
	GW_HASMELEE = GW_CURRENTVEHICLE call hasMelee;
	GW_NEWSPAWN = GW_CURRENTVEHICLE getVariable ["newSpawn", false];

	_currentDir = direction player;
	GW_CURRENTPOS = (ASLtoATL visiblePositionASL GW_CURRENTVEHICLE);

 	// If any of these menus are active, forget about drawing anything else
	if (GW_DEPLOY_ACTIVE || GW_SPAWN_ACTIVE || GW_SETTINGS_ACTIVE || GW_TIMER_ACTIVE || GW_TITLE_ACTIVE) exitWith {};

	call drawIcons;	  

	if (isNil "GW_CURRENTZONE") exitWith {};

	// Player target cursor
	if (GW_INVEHICLE && GW_ISDRIVER && !GW_TIMER_ACTIVE && GW_CURRENTZONE != "workshopZone") then { 
		call targetCursor; 
	};		

	// If there's no nearby targets, no point going any further
	_targets = if (GW_DEBUG) then { ((ASLtoATL visiblePositionASL GW_CURRENTVEHICLE) nearEntities [["Car", "Man", "Tank"], 1000]) } else { ([GW_CURRENTZONE, {true}, true] call findAllInZone) };
	if (count _targets == 0) exitWith {};	

	[_targets] call drawTags;

	if (GW_CURRENTZONE == "workshopZone") exitWith {};	
	
	// Try to lock on to those targets if we have lock ons
	if (GW_INVEHICLE && GW_ISDRIVER && GW_HASLOCKONS && !GW_NEWSPAWN) then {
		_targets call targetLockOn;
	};

	
	
		
}];
