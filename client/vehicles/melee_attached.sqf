//
//      Name: meleeAttached
//      Desc: Collision detection for melee weapons
//      Return: None
//

_meleeEnabled = _this getVariable ['GW_MELEE', false];;
if (!isNil "_meleeEnabled") then { _meleeEnabled = false;};

if (_meleeEnabled) exitWith {};
_this setVariable ['GW_MELEE', true];

_collide = {

	_v1 = _this select 0;
	_vectIn = _this select 1;
	_v2 = _this select 2;
	_vectOut = _this select 3;

	if (isNil "GW_LAST_VELOCITY_UPDATE") then { GW_LAST_VELOCITY_UPDATE = time - 1; };
	if (time - GW_LAST_VELOCITY_UPDATE < 0.025) exitWith {};
	GW_LAST_VELOCITY_UPDATE = time;


	if (isNil "GW_LAST_AUDIO_UPDATE") then { GW_LAST_AUDIO_UPDATE = time - 0.2; };
	if (time - GW_LAST_AUDIO_UPDATE > 0.1) then {
		GW_LAST_AUDIO_UPDATE = time;
		playSound3D ["a3\sounds_f\sfx\vehicle_drag_end.wss", _v1, false, (ASLtoATL visiblePositionASL _v1), 10, 1, 50];
	};

	_speed = ((velocity _v1) distance [0,0,0]) * 0.12;
	_vectIn = [(_vectIn select 0) * _speed, (_vectIn select 1) * _speed, (_vectIn select 2) * _speed];

	_dist = _v1 distance _v2;
	[_v1, _v2, _dist, (_this select 1)] spawn {

		_timeout = time + 3;
		_v = (_this select 3);
		waitUntil {			
			_d = (_this select 0) distance (_this select 1);
			_speed = [2 * _d, 0.05, 2] call limitToRange;
			_dir = [(_this select 1), (_this select 0)] call dirTo;
			(_this select 0) setVelocity [(_v select 0)+(sin _dir*_speed),(_v select 1)+(cos _dir*_speed),(_v select 2) + 0.1];	



			(time > _timeout) || (_d >= (_this select 2))
		};		

	};
	
	// Don't apply velocity to vehicles attached to other vehicles
	if (!isNull (attachedTo _v2)) exitWith {};

	_vectOut = [(_vectIn select 0) * -5, (_vectIn select 1) * -5, (_vectIn select 2) * -5];	
	if (local _v2) then {
			_v2 setVelocity _vectOut;
	} else {
		[       
			[
				_v2,
				_vectOut
			],
			"setVelocityLocal",
			_v2,
			false 
		] call gw_fnc_mp;
	};

};


runCollisionCheck = {

	{
		_source = _x;
		_box = [_source] call getBoundingBox;
		_w = _box select 0;
		_l = _box select 1;
		_h = _box select 2;
		_t = 1.01;

		_tag = _source getVariable ['GW_Tag', ''];

		_pointTemplate = _tag call {

			if (_this == "FRK") exitWith {				
				[
					[ [-(_w/2), (_l/2), -(_h/2)], [(_w/2), (_l/2), -(_h/2)] ],
					[ [-(_w/2), -(_l/2), -(_h/2)], [(_w/2), -(_l/2), -(_h/2)] ]
				]
			};

			if (_this == "HOK") exitWith {
				[
					[ [0, (_l/2), (_h/2)], [0, (-_l/2), (_h/2)] ],
					[ [-(_w/2), (_l/2), -(_h/2)], [-(_w/2), (-_l/2), -(_h/2)] ],
					[ [(_w/2), (_l/2), -(_h/2)], [(_w/2), (-_l/2), -(_h/2)] ]
				]
			};

			if (_this == "CRR") exitWith {
				[
					[ [0, (_l/2), 0], [0, (-_l/2), 0] ]
				]
			};

			[
				[ [0, (_l/2), 0], [0, (_l/2), 0] ]
			]
		};

		_points = [];

		{
			_arr1 = [((_x select 0) select 0) * _t, ((_x select 0) select 1) * _t, ((_x select 0) select 2) * _t];
			_arr2 = [((_x select 1) select 0) * _t, ((_x select 1) select 1) * _t, ((_x select 1) select 2) * _t];
			_points pushBack [(_source modelToWorldVisual _arr1), (_source modelToWorldVisual _arr2)];
			false
		} count _pointTemplate;

		{ 

			_p1 = (_x select 0);
			_p2 = (_x select 1);

			[_p1, _p2, 0.001] spawn renderLine;

			_objs = lineIntersectsWith [ATLtoASL _p1, ATLtoASL _p2, _this, _source];

			if (count _objs == 0) then {} else {

				_obj = nil;
				{		
					if (isNull (attachedTo _x)) exitWith { _obj = _x; };
					if ((attachedTo _x) != _this) exitWith { _obj = _x; };
				} foreach _objs;

				if (!isNil "_obj" && !((typeOf _obj) isEqualTo "")) then { 

					_vectInc = [(ASLtoATL visiblePositionASL _obj), (ASLtoATL visiblePositionASL _source)] call bis_fnc_vectorFromXToY;
					_vectOut = [(ASLtoATL visiblePositionASL _source), (ASLtoATL visiblePositionASL _obj)] call bis_fnc_vectorFromXToY;	
					_targetVehicle = if (!isNull attachedTo _obj) then { (attachedTo _obj)	} else { _obj };									

					_speed = ((velocity _targetVehicle) distance [0,0,0]) * 0.1;

					_status = _targetVehicle getVariable ['status', []];
					_collision = if (_tag == "FRK" && 'forked' in _status) then { false } else { if ((random 100) > 30) exitWith { false }; true  };					
					_command = switch (_tag) do {						
						case "FRK": {  meleeFork };
						case "CRR": {  meleeRam };
						case "HOK": {  meleeHook };
						default
						{ {} };
					};

					if (_collision) then { [_this, _vectInc, _targetVehicle, _vectOut] call _collide; };

					if (isNil "GW_LAST_COLLISION") then { GW_LAST_COLLISION = time - 1; };
					if (time - GW_LAST_COLLISION < 1) exitWith {};
					GW_LAST_COLLISION = TIME;
					[_source, _obj, _speed] call _command;					
					

					false

				};

			};

		} count _points;

	

		false

	} count (attachedObjects _this);	

};

// Loop through every frame and check, disable when vehicle dies
waitUntil {
	
	_this call runCollisionCheck;
	_meleeEnabled = _this getVariable ['GW_MELEE', false];
	(!alive _this || !_meleeEnabled)
};

_this setVariable ['GW_MELEE', false];