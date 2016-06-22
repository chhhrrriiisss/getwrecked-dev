//
//
//
//		Server Initialization
//
//
//

_startTime = time;

[] call GWS_fnc_initObjects;
[] call GWS_fnc_initSupplyAndPaint;
[] call GWS_fnc_initNitroAndFlame;
[] spawn initEvents;

// Wait for zone boundary compilation
waitUntil {
	Sleep 0.25;
	!isNIl "GW_ZONE_BOUNDARIES_COMPILED"
};

[] execVM 'server\zones\buildZoneBoundaryServer.sqf';

// Prevent cleanup on mission.sqm placed items
{
	_x setVariable ['GW_CU_IGNORE', true];
	false
} count (nearestObjects [(getmarkerpos "workshopZone_camera"), [], 200]) > 0;

// Make AI attack civlian players
west setFriend [civilian, 0];
east setFriend [civilian, 0];

// Wait for boundaries to complete for confirming server ready
waitUntil {	
	Sleep 0.25;
	!isNIl "GW_BOUNDARY_BUILD"
};

serverSetupComplete = compileFinal "true";
publicVariable "serverSetupComplete";

_endTime = time;
_str =  format['Server setup completed in %1s.', (_endTime - _startTime)];
diag_log _str;
systemchat _str;

