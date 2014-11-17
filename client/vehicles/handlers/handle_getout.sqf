/*

	Get Out Handler

*/

private ['_unit'];

_unit = _this select 2;
_vehicle = _this select 0;

if (alive _vehicle) then { _unit setDammage 0; };
GW_INVULNERABLE = false;

// If we've been kicked out due to lower health blow it up
if (getDammage _vehicle > 0.9) then {
	_vehicle setDammage 1;
};

// if ( count (attachedObjects _vehicle) > 0) then {

// 	{
// 		_defaultDir = _x getVariable ["defaultDirection", 0];

// 		// Flip it around to the correct side if laser or flamethrower
// 		_defaultDir = if (_type == "LSR" || _type == "FLM") then { ([_defaultDir + 180] call normalizeAngle) } else { _defaultDir };

// 		_x setDir _defaultDir;

// 		false

// 	} count (attachedObjects _vehicle) > 0;

// };

"dynamicBlur" ppEffectEnable false; 
"colorCorrections" ppEffectEnable false; 
