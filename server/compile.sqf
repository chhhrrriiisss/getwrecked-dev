//
//
//
//		Server Function Compile & Configuration
//
//
//

logKill = compile preprocessFile "server\functions\logKill.sqf";

// Leaderboard
call compile preprocessFile "server\functions\leaderboard.sqf";

// Zone Functions
initEvents = compile preprocessFile "server\zones\events.sqf";
createSupplyDrop = compile preprocessFile "server\zones\createSupplyDrop.sqf";

// Object
setObjectData = compile preprocessFile "server\objects\object_data.sqf";
setObjectHandlers = compile preprocessFile "server\objects\object_handlers.sqf";
setObjectCleanup = compile preprocessFile "server\objects\object_cleanup.sqf";

// Vehicle
setVehicleRespawn = compile preprocessFile "server\vehicles\vehicle_respawn.sqf";
setVehicleHandlers = compile preprocessFile "server\vehicles\vehicle_handlers.sqf";
setupVehicle = compile preprocessFile "server\vehicles\setup_vehicle.sqf";
loadVehicle = compile preprocessFile "server\functions\loadVehicle.sqf";

// MP Functions
pubVar_fnc_spawnObject = compile preprocessFile "server\functions\pubVar_spawnObject.sqf";
"pubVar_spawnObject" addPublicVariableEventHandler { (_this select 1) call pubVar_fnc_spawnObject };

// Utility
setVisibleAttached = compile preprocessFile "server\functions\setVisibleAttached.sqf";
setObjectSimulation = compile preprocessFile "server\functions\setObjectSimulation.sqf";
setObjectProperties = compile preprocessFile "server\functions\setObjectProperties.sqf";

// Bots
call compile preprocessFile "server\bots\compile.sqf";
triggerBots = compile preprocessFile "server\bots\trigger_bots.sqf";
controlBot = compile preprocessFile "server\bots\control_bot.sqf";
spawnBot = compile preprocessFile "server\bots\spawn_bot.sqf";

