//
//      Name: assignKill
//      Desc: Handles stat and money to client from successful logKill on server
//      Return: None
//

private ['_money', '_vehicle'];

_money = [_this,0, 0, [0]] call filterParam;
_vehicleName = [_this,1, "", [""]] call filterParam;

[_money] call receiveMoney;
['moneyEarned', _vehicleName, _money] call logStat;   

if (_vehicleName isEqualTo "") exitWith {};

_vehicle = [_vehicleName] call findVehicle;

['kill', _vehicleName, 1, true] call logStat;

// If the vehicle is still alive assign wanted cash
if (isNull _vehicle) exitWith {};
if (!alive _vehicle) exitWith {};

_wantedValue = _vehicle getVariable ["GW_WantedValue", 0];
_wantedValue = _wantedValue + (_money * 0.25);
_vehicle setVariable ["GW_WantedValue", _wantedValue];


