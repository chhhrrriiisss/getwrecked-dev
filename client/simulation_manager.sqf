//
//      Name: simulationManager
//      Desc: Disables simulation on far away objects to increase fps
//      Return: Bool
//

waitUntil{ !(isNil "GW_CURRENTZONE") };

#define CHECK_RATE 3
#define CHECK_DISTANCE 30
#define SIMULATION_RANGE 1600

GW_SIMULATION_MANAGER_ACTIVE = true;
_lastPos = positionCameraToWorld [0,0,0];

for "_i" from 0 to 1 step 0 do {

	if (!GW_SIMULATION_MANAGER_ACTIVE) exitWith {};

	_currentPos = positionCameraToWorld [0,0,0];

	if (_currentPos distance _lastPos > CHECK_DISTANCE && !GW_PREVIEW_CAM_ACTIVE) then {

		_lastPos = _currentPos;
		['Sim Update', format['%1', time]] call logDebug;

		{

			_d = _currentPos distance _x;
			if (_d < SIMULATION_RANGE && { (!simulationEnabled _x) }) then {
				_x enableSimulation true;
			};

			if (_d > SIMULATION_RANGE && { (simulationEnabled _x) } ) then {
				_x enableSimulation false;
			};
			
			false

		} count (allMissionObjects "Car" ) > 0;

		Sleep 0.01;		

	};

	Sleep CHECK_RATE;

};