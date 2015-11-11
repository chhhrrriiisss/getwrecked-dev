private ['_targetRace', '_racePoints'];

_targetRace = [_this, 0, [],[[]]] call filterParam;

if (count _targetRace == 0) exitWith {};

// Determine the start checkpoint
_racePoints = _targetRace select 1;
_raceName = (_targetRace select 0) select 0;
_raceHost = _targetRace select 2;
_startPosition = _racePoints select 0;
_firstPosition = _racePoints select 1;
_raceStatus = [_targetRace, 3, -1, [0]] call filterParam;

// Race waiting on players
if (_raceStatus == 0) then {

	_maxTime = 5;
	
	_scriptDone = [{ (format["<br /><t size='3' color='ffffff' align='center' valign='center'>WAITING FOR PLAYERS (%1s)</t>", ceil ((_this select 1) - (_this select 0)) ])  }, "", false, { true }, _maxTime] spawn createTitle;

	_timeout = time + _maxTime;
	waitUntil {
		Sleep 0.1;
		((time > _timeout) || (scriptDone _scriptDone))
	};

	_raceStatus = [_raceName, 1] call checkRaceStatus;

	GW_TITLE_ACTIVE = false;


	if (_raceStatus == 0 || _raceStatus == -1) exitWith {

		_scriptDone = ["<br /><t size='3' color='ffffff' align='center' valign='center'>NOT ENOUGH PLAYERS</t>", "", false, { true }, 5] spawn createTitle;

		_timeout = time + 5;
		waitUntil {
			Sleep 0.1;
			((time > _timeout) || (scriptDone _scriptDone))
		};

		GW_TITLE_ACTIVE = false;
		GW_CURRENTVEHICLE call destroyInstantly;

	};


	// Race started, send into timer mode
	if (_raceStatus == 1) then {
		GW_HUD_ACTIVE = true;
		GW_HUD_LOCK = false;
		[_racePoints, 9999] execVM 'testcheckpoints.sqf';
	};

};



