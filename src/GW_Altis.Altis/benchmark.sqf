_benchmarkArray = [];

{

	_speed = [format['call %1', (_x select 0)], [], 500] call performanceTest;
	_speed = if (_speed isEqualType 0) then { _speed } else { 0 };
	_benchmarkArray pushback [(_x select 0), _speed];
	
} foreach globalFunctions;

_benchmarkArray sort false;
copyToClipboard str _benchmarkArray;

