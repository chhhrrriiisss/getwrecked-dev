if (isNil "GW_DEBUG_ARRAY") then {
	GW_DEBUG_ARRAY = [];
};

logDebug = {
	
	_s = _this select 0;
	_v = _this select 1;
	
	_exists = false;
	{
		if ((_x select 0) == _s) exitWith {
			GW_DEBUG_ARRAY set [_forEachIndex, [_s, _v]];
			_exists = true;
		};		
	} forEach GW_DEBUG_ARRAY;

	if (!_exists) then {
		GW_DEBUG_ARRAY pushBack [_s, _v];
	};

	true
};

