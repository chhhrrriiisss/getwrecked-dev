//
//      Name: handleContactStartVehicle
//		Desc: Differs from HandleContact because melee must occur without delay
//      Return: None
//

_inWorkshop = if ((_this select 0) distance getMarkerPos "workshopZone_camera" < 200) then { true } else { false };

_vehicle = _this select 0;

// Prevent vehicle moving when collision inside workshop
if (_inWorkshop) exitWith {

	_vehicle enableSimulationGlobal false;
	
	[		
		[
			(_this select 1),
			false
		],
		"setObjectSimulation",
		(_this select 1),
		false 
	] call gw_fnc_mp;
};

if (isNil "GW_LAST_MELEE") then { GW_LAST_MELEE = time; };
if ( (time - GW_LAST_MELEE <= 0.1) ) exitWith {};
GW_LAST_MELEE = time;

_special = _vehicle getVariable ["special", []];
if (!(_vehicle call hasMelee)) exitWith {};

_target = _this select 1;
if (!(_target isKindOf "Car")) exitWith {};

// Vehicle forking trigger
// Attaches vehicles in range of a spike to the source vehicle

{
	if ("Land_PalletTrolley_01_khaki_F" isEqualTo (typeOf _x)) then {

		_forkObject = _x;
		_sourcePoint = ATLtoASL (_x modelToWorldVisual [0,0,-0.5]);
		_endPoint = ATLtoASL (_x modelToWorldVisual [3,0,-0.5]);
		_objs = lineIntersectsWith [_sourcePoint,_endPoint, GW_CURRENTVEHICLE, _forkObject];
		if (GW_DEBUG) then { [_x modelToWorldVisual [0,0,-0.5],_x modelToWorldVisual [3,0,-0.5], 0.1] spawn debugLine; };
			
		if (count _objs == 0) exitWith {};

		{
			if (_x == _target) exitWith {

				_status = _x getVariable ['status', []];
				if ('invulnerable' in _status || 'cloak' in _status || 'forked' in _status || 'nofork' in _status) exitWith {};

				_vP = _vehicle worldToModelVisual (_target modelToWorldVisual [0,0,0]);				
				_damage = [( ((random 0.1) + 0.1) / (['FRK', _vehicle] call hasType) ), 2] call roundTo;

				[       
				    [
				        _target,
				        _vehicle,
				        _damage,
				        _vP
				    ],
				    "forkEffect",
				    _target,
				    false 
				] call gw_fnc_mp; 

				[_target, 'FRK'] call checkMark;

			};
			false
		} count _objs;	
	};	
	false
} count (attachedObjects _vehicle) > 0;



