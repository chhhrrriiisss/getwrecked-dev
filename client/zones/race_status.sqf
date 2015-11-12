private ['_targetRace', '_racePoints', '_raceName'];

_targetRace = [_this, 0, [], [[]]] call filterParam;
if (count _targetRace == 0) exitWith { systemchat 'Bad race data, could not init status checks.'; };

// Determine the start checkpoint
_raceName = (_targetRace select 0) select 0;
GW_CURRENTRACE = _raceName;
_raceStatus = [_raceName] call checkRaceStatus;
_raceHost = _targetRace select 2;

_success = 
["<br /><br /><t size='3' color='#ffffff' align='center'>WAITING FOR PLAYERS</t>", 
	"START", 
	[false, { (([GW_CURRENTRACE] call checkRaceStatus) == 1) }], // When TRUE show button
	{  
		_rS = [GW_CURRENTRACE] call checkRaceStatus; ((_rS != 2) && (_rS != -1))  // While TRUE keep title up
	}, 
	60,
	true, 
	{ 	
		[GW_CURRENTRACE, 2] call checkRaceStatus; systemchat 'Button function!'; // Button function
		true 
	}
] call createTitle;

_raceStatus = [_raceName] call checkRaceStatus;
if ((!_success && _raceStatus == 0) || _raceStatus == 1) exitWith {	
	GW_CURRENTVEHICLE call destroyInstantly;
};

if (_raceStatus != 2) exitWith {

	waitUntil { Sleep 0.1; (isNull (findDisplay 95000)) };
	["<br /><br /><t size='3' color='#ffffff' align='center'>RACE ABORTED</t>", "START", [false, { false }] , { true }, 5, true] call createTitle;
	GW_CURRENTVEHICLE call destroyInstantly;

};

if (_raceStatus >= 2) exitWith {

	waitUntil { Sleep 0.1; (isNull (findDisplay 95000)) };

	_maxTime = 15;

	[_targetRace, 9999] execVM 'testcheckpoints.sqf';
	['TEST', 15, false] call createTimer;

	GW_CURRENTVEHICLE say "electronTrigger";

	GW_HUD_ACTIVE = true;
	GW_HUD_LOCK = false;

};

GW_CURRENTVEHICLE call destroyInstantly;
GW_CURRENTVEHICLE spawn { 
	Sleep 1;
	{ deleteVehicle _x; } foreach attachedObjects _this;
	deleteVehicle _this;
};	


// if (_success) then {

// };

// waitUntil {	
	
// 	Sleep 0.1;

// 	_raceStatus = [_raceName] call checkRaceStatus;
// 	if ((_raceStatus == 1) && _raceHost == (name player)) then { GW_TITLE_BUTTON_VISIBLE = true; };		
// 	( (_raceStatus != 0 && _raceStatus != 1) || scriptDone _titleDone )
// };

// GW_TITLE_ACTIVE = false;

// if (_raceStatus != 2) exitWith {

// 	waitUntil { Sleep 1; (isNull (findDisplay 95000)) };
// 	["<br /><t size='3' color='#ffffff' align='center' valign='center'>RACE ABORTED</t>", "", [false, false] , { true }, 5, false] spawn createTitle;
// 	GW_CURRENTVEHICLE call destroyInstantly;

// };

// // Race started, send into timer mode
// if (_raceStatus == 2) then {
	
// 	systemchat 'Enough players, race starting...';
// 	GW_HUD_ACTIVE = true;
// 	GW_HUD_LOCK = false;

// 	waitUntil { Sleep 1; (isNull (findDisplay 95000)) };
// 	["<br /><t size='3' color='ffffff' align='center' valign='center'>GET READY</t>", "", [false, false] , { true }, 3, false] spawn createTitle;

// 	waitUntil { Sleep 1; (isNull (findDisplay 95000)) };
// 	[_targetRace, 9999] execVM 'testcheckpoints.sqf';

// };


// Race waiting on players
// // Race waiting on players
// if (_raceStatus == 0) then {

// 	systemchat 'Waiting for players...';
// 	_maxTime = 10;	
// 	waitUntil { (isNull (findDisplay 95000)) };
// 	[{ (format["<br /><t size='3' color='ffffff' align='center' valign='center'>WAITING FOR PLAYERS (%1s)</t>", ceil ((_this select 1) - (_this select 0)) ])  }, "", false, { true }, _maxTime] call createTitle;
// 	_raceStatus = [_raceName, 1] call checkRaceStatus;

// 	//GW_TITLE_ACTIVE = false;
// 	if (_raceStatus == 0 || _raceStatus == -1) exitWith {

// 		systemchat 'Not enough players, aborting...';
		
// 		waitUntil { (isNull (findDisplay 95000)) };
// 		[{ "<t size='3' color='#ff0000' align='center' valign='center'>RACE ABORTED</t><br /><t size='3' color='#ffffff' align='center' valign='center'>NOT ENOUGH PLAYERS</t>" }, "", false, { true }, 5] call createTitle;
		
// 		GW_CURRENTVEHICLE call destroyInstantly;

// 	};

// 	// Race started, send into timer mode
// 	if (_raceStatus == 1) then {
		
// 		systemchat 'Enough players, race starting...';
// 		GW_HUD_ACTIVE = true;
// 		GW_HUD_LOCK = false;

// 		waitUntil { (isNull (findDisplay 95000)) };
// 		[{ "<br /><t size='3' color='ffffff' align='center' valign='center'>GET READY</t>" }, "", false, { true }, 3] call createTitle;

// 		waitUntil { (isNull (findDisplay 95000)) };
// 		[_targetRace, 9999] execVM 'testcheckpoints.sqf';

// 	};

// };



