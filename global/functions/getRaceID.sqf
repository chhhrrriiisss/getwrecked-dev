
_targetRace = [];
_id = -1;

{
	if (_this == ((_x select 0) select 0) ) exitWith {
		_targetRace = _x;
		_id = _forEachIndex;
	};
} foreach GW_ACTIVE_RACES;

[_targetRace, _id]