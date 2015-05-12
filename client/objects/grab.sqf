//
//      Name: grabObj
//      Desc: Pick up an item and carry it with the player
//      Return: Bool
//

private ['_obj', '_unit', '_type'];

_obj = [_this,0, objNull, [objNull]] call filterParam;
_unit = [_this,1, objNull, [objNull]] call filterParam;

if (isNull _obj || isNull _unit) exitWith {};

// If the object isn't local and isn't attached to anything, make it local so all this jazz runs better
_isSupply = _obj call isSupplyBox;
if ( !local _obj && isNull attachedTo _obj && !_isSupply) then {

	// Grab object position information
	_pos = getPos _obj;
	_obj setPos (_obj modelToWorldVisual [0,0,10]);

	// Hide current object	
	_obj hideObject true;

	_dir = getDir _obj;
	_type = typeOf _obj;
	_tag = _obj getVariable ["GW_Tag", ''];

	// Determine the class for the object	
	_isHolder = _obj call isHolder;

	// Remove the previous object as its no longer needed
	deleteVehicle _obj;

	// Create a new one, locally
	_newObj = nil;
	_newObj = [_pos, _dir, _type, nil, "CAN_COLLIDE", true] call createObject; 	
		
	// Request the server adds these properties
	[		
		[
			_newObj
		],
		"setObjectProperties",
		false,
		false 
	] call gw_fnc_mp;   

    _obj = _newObj;

};

// Disable simulation server side as a default
[		
	[
		_obj,
		false
	],
	"setObjectSimulation",
	false,
	false 
] call gw_fnc_mp;  
	
_unit setVariable ['GW_EditingObject', _obj];

// If a snapping state hasnt been set, default to false
if (isNil { _unit getVariable 'snapping' }) then {	_unit setVariable ['snapping', false]; };

GW_EDITING = true;

// Wait for simulation to be disabled on the item before moving it
_timeout = time + 5;
waitUntil{	
	if ( (time > _timeout) || !(simulationEnabled _obj) ) exitWith { true };
	false
};

Sleep 1;

// Used to dynamically change the loop period depending if snapping is active
_moveInterval = 0.005;
_snappingInterval = 0.1;

GW_HOLD_ROTATE_POS = [];
_startAngle = 360;

for "_i" from 0 to 1 step 0 do {

	if (!alive _unit || !alive _obj || !GW_EDITING || _unit != (vehicle player)) exitWith {};

	// Continually prevent damage and simulation (wierd stuff happens otherwise...)
	_obj setDammage 0;
	//_obj setVectorUp [0,0,1];

	// Use the camera height as a tool to manipulate the object height
	_cameraHeight = (positionCameraToWorld [0,0,4]) select 2;
	_height = [_cameraHeight, 0, 4] call limitToRange;	

	_pos = _unit modelToWorld [0, 2.5, _height];
	_pos = ATLtoASL _pos;

	_snapping = _unit getVariable ['snapping', false];	

	// Use the camera yaw to spin the vehicle when toggle key is down
	if (GW_HOLD_ROTATE) then {

		if (count GW_HOLD_ROTATE_POS > 0) then {

			['ROTATE USING CAMERA', 3, cameraRotateIcon, nil, "flash", ""] spawn createAlert;   

			_center = worldToScreen getPos _obj;
			_adjustedCenter = ((_center select 0)+1);
			if (isNil "_adjustedCenter") then { _adjustedCenter = 0; };

			_obj setDir ([(360 * _adjustedCenter) + (_startAngle)] call normalizeAngle);			

		} else { _startAngle = getDir _obj; };

		GW_HOLD_ROTATE_POS = (ASLtoATL getPosASL _obj);

	} else {

		// Reset player's direction post hold rotate
		if (count GW_HOLD_ROTATE_POS > 0) then {			

			_dirTo = [_unit, _obj] call dirTo;	
			_unit setDir _dirTo;
			_obj setPos GW_HOLD_ROTATE_POS;

			GW_HOLD_ROTATE_POS = [];

		} else {

	 		// If snapping is enabled, snap! Else, just set the new position.
			if (_snapping && GW_EDITING) then { [_pos, _obj] spawn snapObj; };
			if (!_snapping && GW_EDITING) then { _obj setPosASL _pos; };	

		};

	};

	// Render FOV if it's a weapon
	if (_obj call isWeapon) then { _obj call renderFOV; };

	// Dynamically adjust the sleep time to reduce errors during snapping
	_interval = if (_snapping) then { _snappingInterval } else { _moveInterval };	

	Sleep _interval;

};

if (!alive _obj) then {
	removeAllActions _unit;
	_unit spawn setPlayerActions;
};

GW_EDITING = false;
_unit setVariable ['GW_EditingObject', nil];

true