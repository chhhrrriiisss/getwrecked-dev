//
//      Name: simulationManager
//      Desc: Disables simulation on far away objects to increase fps
//      Return: Bool
//

waitUntil{ !(isNil "GW_CURRENTZONE") };

#define CHECK_RATE 1
#define CHECK_DISTANCE 5
#define CHECK_DIRECTION 20
#define SIMULATION_RANGE 1700
#define MIN_SIMULATION_RANGE 50

GW_SIMULATION_MANAGER_ACTIVE = true;
_lastPos = [0,0,0];
_lastDir = 0;

for "_i" from 0 to 1 step 0 do {

	if (!GW_SIMULATION_MANAGER_ACTIVE) exitWith {};

	_currentPos = positionCameraToWorld [0,0,0];
	_currentDir = [(positionCameraToWorld [0,0,0]), (positionCameraToWorld [0,0,4])] call dirTo;

	if ( ( (_currentPos distance _lastPos > CHECK_DISTANCE) || ( [0,0,_currentDir] distance [0,0,_lastDir] > CHECK_DIRECTION ) ) && !GW_PREVIEW_CAM_ACTIVE && !GW_LIFT_ACTIVE) then {
		
		_lastPos = _currentPos;
		_lastDir = _currentDir;
		['Sim Update', format['%1', time]] call logDebug;

		{

			_i = _x getVariable ['GW_Ignore_Sim', false];

			if (_x == (vehicle player) || _i) then {} else {

				_s = [ ([(positionCameraToWorld [0,0,0]), (positionCameraToWorld [0,0,4])] call dirTo), _x, 90] call checkScope;
				_d = _currentPos distance _x;

				if (_d < SIMULATION_RANGE) then {

					if (!_s && simulationEnabled _x && _d > MIN_SIMULATION_RANGE) then {
						_x enableSimulation false;
					};

					if (_s && !simulationEnabled _x) then {
						_x enableSimulation true;
					};
				};

				if (_d > SIMULATION_RANGE && simulationEnabled _x) then {
					_x enableSimulation false;
				};
				
			};
			
			false

		} count (allMissionObjects "Car" ) > 0;

		Sleep 0.01;		

	};

	Sleep CHECK_RATE;

};