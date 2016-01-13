//
//      Name: createBoundary
//      Desc: Create a boundary texture object at specified position
//      Return: Boundaries (inside and out)
//

private ['_source', '_step', '_newDestination', '_normal'];

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
	
_wallInside = "UserTexture10m_F" createVehicleLocal _newDestination; 
_wallOutside = "UserTexture10m_F" createVehicleLocal _newDestination; 

if (_isWater) then {
	_wallInside setPosASL _newDestination;
	_wallOutside setPosASL _newDestination;
};

_wallInside setVectorDirAndUp [(_this select 3), _normal];
_wallOutside setVectorDirAndUp [(_this select 4), _normal];

_wallInside setObjectTexture [0,"client\images\stripes_fade.paa"];
_wallOutside setObjectTexture [0,"client\images\stripes_fade.paa"];

_wallInside enableSimulation false;
_wallOutside enableSimulation false;

[_wallInside, _wallOutside]