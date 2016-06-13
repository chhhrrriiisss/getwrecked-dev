//
//      Name: removeFromRace
//      Desc: Handles deaths during race, ending race when all players are killed
//      Return: None
//

params ['_raceName', '_vehicle'];
private ['_raceName', '_id', '_vehicle'];

_raceStatus = [_raceName] call checkRaceStatus;

if (_raceStatus == -1) exitWith {};

_raceData = _raceName call getRaceID;
_raceID = (_raceData select 1);

_activeArray = [(GW_ACTIVE_RACES select _raceID), 5, [], [[]]] call filterParam;
_finishedArray = [(GW_ACTIVE_RACES select _raceID), 6, [], [[]]] call filterParam;

_activeArray deleteAt (_activeArray find _vehicle);

// If active array empty and finished array empty
if (count _activeArray == 0 && count _finishedArray == 0) then {
	[_raceName, 3] call checkRaceStatus;
	GW_ACTIVE_RACES deleteAt _raceID;

	pubVar_systemChat = format['%1 race ended — all participants were killed.', _raceName];
	systemchat pubVar_systemChat;
	publicVariable "pubVar_systemChat";
};

publicVariable "GW_ACTIVE_RACES";

true