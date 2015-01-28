//
//      Name: simulationManager
//      Desc: Disables simulation on far away objects to increase fps
//      Return: Bool
//

#define CHECK_RATE 3
#define CHECK_DISTANCE 30
#define SIMULATION_RANGE 2200

GW_SIMULATION_MANAGER_ACTIVE = true;
_lastPos = positionCameraToWorld [0,0,0];

while {GW_SIMULATION_MANAGER_ACTIVE} do {

	_currentPos = positionCameraToWorld [0,0,0];

	// If the player has actually moved from the last spot and we're not on a preview camera
	if (_currentPos distance _lastPos > CHECK_DISTANCE && !GW_PREVIEW_CAM_ACTIVE) then {
		_lastPos = _currentPos;

		{

			_d = _currentPos distance _x;
			if (_d < SIMULATION_RANGE && { (!simulationEnabled _x) }) then {
				_x enableSimulation true;
			};

			if (_d > SIMULATION_RANGE && { (simulationEnabled _x) } ) then {
				_x enableSimulation false;
			};
			
			false

		} count (allMissionObjects "Car") > 0;

		Sleep 0.01;		

	};

	Sleep CHECK_RATE;

};