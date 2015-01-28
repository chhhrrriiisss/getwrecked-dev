private ['_string', '_value'];

if (!isNil "GW_DEBUG_MONITOR_EH") then {
	[GW_DEBUG_MONITOR_EH, "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
};

if (isNil "GW_DEBUG_ARRAY") then {
	GW_DEBUG_ARRAY = [];
};

logDebug = {

	// Don't log if debug isn't enabled
	if (!GW_DEBUG) exitWith {];

	_exists =
	{
		if ((_x select 0) == ( _this select 0)) exitWith {
			GW_DEBUG_ARRAY set [_forEachIndex, [(_x select 0), (_this select 1)]];
			true
		};		
		false
	} count GW_DEBUG_ARRAY > 0;

	if (!_exists) then {
		GW_DEBUG_ARRAY pushBack [(_this select 0), (_this select 1)];
	};

	true
};

GW_DEBUG_MONITOR_EH = ["GW_DEBUG_MONITOR", "onEachFrame", {
	
	 if (isNil "GW_DEBUG_MONITOR_LAST_UPDATE") then {
    	GW_DEBUG_MONITOR_LAST_UPDATE = time;
    };

	if (!GW_DEBUG || (time - GW_DEBUG_MONITOR_LAST_UPDATE < 0.3)) exitWith {};

	_totalString = "";

	{


		_string = _x select 0;
		_value = _x select 1;

		_totalString = format['%1 \n%2 : %3', _string, _value];

	} count GW_DEBUG_ARRAY > 0;

	hintSilent _totalString;

}];


