//
//      Name: initSupply, setupSupplyBox, createSupplyBox
//      Desc: Provides initialization of supply boxes
//      Return: None
//

setupSupplyBox = {
	
	private ['_box'];

	_box = _this;

	_box setVariable ["owner", "", true];
	_box setVariable ["mass", 40, true];
	_box setVariable ["isSupply", true, true];
	_box setVariable ["name", "Empty Supply Box", true];

	true

};

// Create a box at the requested location
createSupplyBox = {
		
	private ['_box', '_pos'];

	_pos = [_this,0, [], [[]]] call BIS_fnc_param;

	if (count _pos == 0) exitWith { diag_log "Failed to create supply box - invalid position."; };

	_box = createVehicle ["Land_PaperBox_closed_F", _pos, [], 0, 'CAN_COLLIDE']; 
	_box setDir (random 360);
	_box call setupSupplyBox;

	_box

};

// Initialize all existing supply boxes in the workshop
initSupply = {

	private ['_pos', '_objs'];

	_pos = getMarkerPos "workshopZone_camera";

	_objs = nearestObjects [_pos, [], 125];

	if (count _objs <= 0) exitWith { true };

	{	
		if ((typeOf _x) == "Land_PaperBox_closed_F") then {
			_x call setupSupplyBox;
		};
		false
	} count _objs > 0;

	true

};