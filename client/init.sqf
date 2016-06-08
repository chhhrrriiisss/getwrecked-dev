//
//
//
//		Client Initialization
//
//
//

if (isDedicated) exitWith {};

// Wait for the server to finish doing its thang
systemchat 'Waiting for server...';
waitUntil {Sleep 0.1; !isNil "serverSetupComplete"};
systemchat 'Server is ready to go!';

// Launch the black screen so it clears even with script errors below
[] spawn {
	_timeout = time + 30;
	waitUntil {Sleep 1; ((time > _timeout) || (!isNil "clientLoadComplete"))};	
	99999 cutText ["","PLAIN", 0.6];
};

// Initialize group system
missionNamespace setVariable ["bis_dynamicGroups_respawnKeyDown", nil];
["InitializePlayer", [player]] call bis_fnc_dynamicGroups; 

// Remove default keybinding for dynamic groups (why there isn't already an option for this I have no idea...)
[] spawn {
	
	waitUntil{ 
		_init = missionNamespace getVariable "bis_dynamicGroups_respawnKeyDown";
		(!isNull (findDisplay 46) && !isNil "_init")
	};
	
	_keys = uiNamespace getVariable ["BIS_dynamicGroups_key", [0,0]];
	_down = _keys select 0;
	_up = _keys select 1;


	(findDisplay 46) displayRemoveAllEventHandlers "KeyDown";
	(findDisplay 46) displayRemoveAllEventHandlers "KeyUp";

	(findDisplay 46) displayRemoveEventHandler["KeyDown", _down];
	(findDisplay 46) displayRemoveEventHandler["KeyUp", _up];

	keybindEventsRemoved = compileFinal "true";

};

// Check for an existing library
_newPlayer = false;
_lib = [] call getVehicleLibrary;

// Check if hints are enabled
_hintsEnabled = profileNamespace getVariable ['GW_HINTS', nil];
GW_HINTS_ENABLED = if (isNil "_hintsEnabled") then {
	profileNamespace setVariable ['GW_HINTS', true];
	true
} else { _hintsEnabled };

// Check for a last loaded vehicle
_last = profileNamespace getVariable ['GW_LASTLOAD', nil];
GW_LASTLOAD = if (isNil "_last") then {  profileNamespace setVariable ['GW_LASTLOAD', '']; saveProfileNamespace; '' } else { _last };

// Check for custom races
_races = profileNamespace getVariable ['GW_RACES', nil];
_raceVersion = profileNamespace getVariable ['GW_RACE_VERSION', 0];

if (_raceVersion < GW_VERSION || isNil "_races") then {
	profileNamespace setVariable ['GW_RACE_VERSION', GW_VERSION];	
	[] call createDefaultRaces;

};

// Prepare player, display and key binds
[player] call playerInit;

// Start simulation toggling
// [] call simulationManager;
