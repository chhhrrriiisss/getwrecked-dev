//
//      Name: cacheBoundary
//      Desc: Create position and dir information for zone boundaries
//      Return: None
//

{

	// Abort if no point data to work with
	_zoneName = _x select 0;
	_pointsArray = _x select 1;

	_c = 0;
	_bA = [];

	{
		_p1 = ATLtoASL( _x );
		_next = if (_c == (count _pointsArray - 1)) then { 0 } else { _c + 1 };
		_p2 = ATLtoASL( _pointsArray select _next );

		_dirTo = [_p1, _p2] call dirTo;
		_dirIn = [(_dirTo - 90)] call normalizeAngle;
		_dirOut = [(_dirTo + 90)] call normalizeAngle;

		_distance = _p1 distance _p2;

		for "_i" from 0 to _distance step 5 do {
			_b = [_p1, (-2.5 + _i), _dirTo, ([_dirIn,0,0] call dirToVector), ([_dirOut, 0,0] call dirToVector)] call {


				_source = +(_this select 0);
				_step = (_this select 1);

				_source set[2, 0];				
				_newDestination = [_source, _step, (_this select 2)] call relPos;

				_isWater = (surfaceIsWater _newDestination);

				_normal = if (_isWater) then {
					_newDestination = ATLtoASL (_newDestination);
					_newDestination set[2, 0];
					[0,0,1]
				} else {
				 	(surfaceNormal _newDestination)
				};
					
				_newVectorDirAndUp = [(_this select 3), _normal];
		
				[_newDestination, _newVectorDirAndUp]

			};

			_bA pushback _b;
			//_bA pushback (_b select 1);
		};	

		_c = _c + 1;

		false
	} count _pointsArray > 0;

	_x set [2, _bA];

	false

} foreach GW_ZONE_BOUNDARIES;

GW_ZONE_BOUNDARIES_CACHED = compileFinal "true";