//
//      Name: logStat
//      Desc: Handles updating and saving vehicle stats to profile name space
//      Return: None
//

private ['_statToLog', '_vehicle', '_value'];

_statToLog = [_this,0, "", [""]] call filterParam;
_vehicle = [_this,1, objNull, [objNull, ""]] call filterParam;
_value = [_this,2, 0, [0]] call filterParam;
_forceSave = [_this,3, false, [false]] call filterParam;

if (_statToLog == "") exitWith {};
if ((GW_STATS_ORDER find _statToLog) == -1) exitWith { false };

_vehicleIsAlive = if (typename _vehicle == "OBJECT") then { if (alive _vehicle) exitWith { true }; false } else { false };
_vehicleName = if (typename _vehicle == "STRING") then { _vehicle } else { if (_vehicleIsAlive) exitWith { _vehicle getVariable ['name', ''] };	nil };

if (isNil "_vehicleName") exitWith { false };

_currentValue = [_statToLog, _vehicleName] call getStat;
_newValue = _currentValue + _value;
[_statToLog, _vehicleName, _newValue] call getStat;

if (isNil "GW_LAST_SAVE") then { GW_LAST_SAVE = time - 240; };
if ((time - GW_LAST_SAVE < 240) && !_forceSave) exitWith { true };
GW_LAST_SAVE = time;
['Last Profile Save', format['%1', time]] call logDebug;
[] spawn { saveProfileNamespace; };

true
