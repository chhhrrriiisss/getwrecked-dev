		_random = random 100;
		addCamShake [0.5, 0.25,30];

		if (_random > 70) then {

			_vel = velocity GW_CURRENTVEHICLE;
			_rnd = (random 4);

			_random = random 100;		

			GW_CURRENTVEHICLE setVelocity [_vel select 0, _vel select 1, (_vel select 2) + _rnd];      
			addCamShake [3, 0.25,10];
			[
				[
					GW_CURRENTVEHICLE,
					0.1,
					[0,0,0,0.2],
					2,
					-1
				],
				"smokeEffect"
			] call gw_fnc_mp;    

		};