params ['_displayID', '_lock'];
private ['_displayID', '_lock'];

if (isNil "GW_LOCKED_DISPLAYS") then { GW_LOCKED_DISPLAYS = []; };

if (_lock) exitWith {
	_ID = (findDisplay _displayID) displayAddEventHandler ["KeyDown", {	true }];
	GW_LOCKED_DISPLAYS set [_ID, _displayID];
	true
};

if (!_lock) exitWith {
	_ID = GW_LOCKED_DISPLAYS find _displayID;
	(findDisplay _displayID) displayRemoveEventHandler ["KeyDown", _ID];
	GW_LOCKED_DISPLAYS deleteAt _ID;
	true
};

true