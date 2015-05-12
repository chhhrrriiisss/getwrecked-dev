_unit = _this;

// Lift vehicle
_unit addAction[liftVehicleFormat, {

	[([player, 8] call validNearby), (_this select 0)] spawn liftVehicle;

}, [], 0, false, false, "", "( (GW_CURRENTZONE == 'workshopZone') && !GW_EDITING && (vehicle player) == player && (!isNil { [_target, 8, true] call validNearby }) && !GW_LIFT_ACTIVE && !(GW_PAINT_ACTIVE) && !GW_TAG_ACTIVE )"];		


// Show changes to vehicle
_unit addAction[showVehicleFormat, {	
	([(_this select 0), 8, true] call validNearby) call toggleHidden;
}, [], 0, false, false, "", "( (GW_CURRENTZONE == 'workshopZone') && 

	{
		_nearby = [_target, 8, true] call validNearby; 
		if (isNil '_nearby') exitWith { false };
		_isHidden = _nearby getVariable ['GW_HIDDEN', false];
		if (!_isHidden) exitWith { false };
		true
	}

&& !GW_EDITING && (vehicle player) == player && (!isNil { [player, 8, true] call validNearby }) && !GW_LIFT_ACTIVE && !(GW_PAINT_ACTIVE) && !GW_TAG_ACTIVE )"];	

// Hide changes to vehicle
_unit addAction[hideVehicleFormat, {	
	([(_this select 0), 8, true] call validNearby) call toggleHidden;
}, [], 0, false, false, "", "( (GW_CURRENTZONE == 'workshopZone') && 

	{
		_nearby = [_target, 8, true] call validNearby; 
		if (isNil '_nearby') exitWith { false };
		_isHidden = _nearby getVariable ['GW_HIDDEN', false];
		if (_isHidden) exitWith { false };
		true		
	}

&& !GW_EDITING && (vehicle player) == player && (!isNil { [player, 8, true] call validNearby }) && !GW_LIFT_ACTIVE && !(GW_PAINT_ACTIVE) && !GW_TAG_ACTIVE )"];	



// Open the settings
_unit addAction[settingsVehicleFormat, {

	[([player, 8] call validNearby), (_this select 0)] spawn settingsMenu;

}, [], 0, false, false, "", "( !GW_EDITING && (vehicle player) == player && (!isNil { [_target, 8, true] call validNearby }) && !GW_LIFT_ACTIVE && !(GW_PAINT_ACTIVE) && !GW_TAG_ACTIVE )"];		
