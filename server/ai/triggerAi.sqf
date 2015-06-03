private ['_vehicle'];

_ai = [_this, 0, objNull, [objNull]]] call filterParam;
_type = [_this, 1, "", [""]]] call filterParam;
_target = [_this, 2, objNull, [objNull]]] call filterParam;

if (isNull _ai || isNull _target) exitWith {};

_isAI = _ai getVariable ['isAI', false];
if (!_isAI) exitWith {};

if (!alive _target) exitWith {};

if (count toArray _type == 0) exitWith {};

// _attributes = _ai getVariable ['GW_aiAttributes', []];
// if (count _attributes == 0) exitWith {};
	
switch (_type) do {
	
	case "shoot":
	{




	};

	case "flee":
	{




	};

	case "follow":
	{




	};
	

};


