//
//      Name: handleContactVehicle
//      Return: None
//

private ['_vehicle', '_target'];

_vehicle = _this select 0; 

_inWorkshop = if (_vehicle distance getMarkerPos "workshopZone_camera" < 300) then { true } else { false };
if (_inWorkshop) exitWith {};

if (!local _vehicle) exitWith {};

[_vehicle] spawn checkTyres; 

// This is to ensure vehicles dont get stuck in the ground when landing at speed
// Most commonly it occurs on the go kart due to the wheels being especially small

if (isNil "GW_LAST_CONTACT") then { GW_LAST_CONTACT = time; };

if ( (typeOf _vehicle == "C_Kart_01_F" || !isNil {_vehicle getVariable "newSpawn"} ) && player == (driver _vehicle) && (time - GW_LAST_CONTACT > 0.3) ) then {
	GW_LAST_CONTACT = time;

	_prevPos = _vehicle getVariable ['prevPos', [0,0,0]];
	_prevAlt = _prevPos select 2;
	_currentAlt = (getPos _vehicle) select 2;

	if (_prevAlt > 2 || _currentAlt < 0) then {
		_vel = velocity _vehicle;
		_normal = surfaceNormal (ASLtoATL getPosASL _vehicle);
		_vehicle setVectorUp _normal;
		_vel set[2, (_vel select 2) + 1];
		_vehicle setVelocity _vel;
		[_vehicle, true, false] call flipVehicle;		
	};
	
};
