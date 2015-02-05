/*

	Player Init

*/

waitUntil{!isNil { clientCompileComplete } };

_unit = _this select 0;
if (!local _unit) exitWith {};
if (!isNil { _unit getVariable 'localInit'} ) exitWith {};
_unit setVariable['localInit', true];

removeAllWeapons _unit;
removeVest _unit;
removeBackpack _unit;
removeGoggles _unit;

removeAllPrimaryWeaponItems _unit;
removeallassigneditems _unit;

_unit addItem "ItemMap";
_unit assignItem "ItemMap";

GW_PLAYERNAME = (name player);

// Default Zone
['workshopZone'] call setCurrentZone;

_unit setVariable ["firstSpawn", true];

_unit addeventhandler ["respawn", {
	_this spawn playerRespawn;
}];  

_unit addeventhandler ["killed",{	
	_this spawn playerKilled;
}];

_unit addeventhandler ["handleDamage",{ 

	_damage = _this select 2;

	if (GW_INVULNERABLE || GW_CURRENTZONE == 'workshopZone') then {
		_damage = false;
	} else {
		_damage = _damage;
	};

	_damage

}];

addMissionEventHandler ["HandleDisconnect",{

	systemchat 'RUNNING DISCONNECT HANDLER';
	
	// Remove ownership from any vehicles in workshop
	_n = (_this select 0) getVariable ['GW_Playername', ''];
	_o = nearestObjects [getmarkerpos "workshopZone_camera", [], 150];

	{

		_owner = _x getVariable ['owner', ''];
		if (_owner == _n) then {
			_x setVariable ['owner', '', true];
		};
		false
	} count _o > 0;

	// Kill the unit
	_n setDammage 1;

}];

// Player set up
[_unit] spawn playerSpawn;

// Useful for detecting mouse presses
[] call mouseHandler;

// Used for detecting key presses
[] call initBinds;

// Map markers, boundaries
[] spawn drawMap;

// UI loop for hud icons
[] call drawDisplay;

systemChat 'Player initialization complete.';

if (true) exitWith {};