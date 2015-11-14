params ['_raceName', '_vehicle'];
private ['_raceName', '_id', '_vehicle'];

_raceStatus = [_raceName] call checkRaceStatus;

if (_raceStatus == -1) exitWith {};

_raceData = _raceName call getRaceID;
_raceID = (_raceData select 1);

((GW_ACTIVE_RACES select _raceID) select 5) deleteAt (((GW_ACTIVE_RACES select _raceID) select 5) find _vehicle);

if (count ((GW_ACTIVE_RACES select _raceID) select 5) == 0) then {
	[_raceName, 3] call checkRaceStatus;
	GW_ACTIVE_RACES deleteAt _raceID;

	pubVar_systemChat = format['%1 race ended — all participants were killed.', _raceName];
	systemchat pubVar_systemChat;
	publicVariable "pubVar_systemChat";
};

publicVariable "GW_ACTIVE_RACES";

true