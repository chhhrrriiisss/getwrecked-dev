GW_RESTRICTED_KEYS = [
	1, // esc
	69 // Num Lock Spam
];


resetBinds = {
	
	_key = _this select 1; // The key that was pressed

	if (showBinds) then {
		showBinds = false;
	};

	if (fireKeyDown != "") then {
		fireKeyDown = "";
	};

	if (keyDown) then {
		keyDown = false;
	};

	if ((_this select 1) in (actionKeys "showMap")) then {
		GW_HUD_ACTIVE = false;	
		GW_HUD_LOCK = true;
	};	

	if (!visibleMap && GW_HUD_LOCK) then {
		GW_HUD_ACTIVE = false;	
		GW_HUD_LOCK = false;
	};	

	GW_HOLD_ROTATE = false;
	GW_KEYDOWN = nil;

	// _groupsKey = ["GROUPS"] call getGlobalBind;
	_infoKey = ["INFO"] call getGlobalBind;

	if (_key == _infoKey) then {
		[] execVM "client\ui\dialogs\createHint.sqf";
	};

	// if (_key == _groupsKey) then {
	// 	["OnKeyUp", _this] call dynamicGroups;
	// };
};

checkBinds = {
	
	[_this, "key"] call triggerLazyUpdate;

	_key = _this select 1; // The key that was pressed
	_shift = _this select 2; 
	_ctrl = _this select 3; 
	_alt = _this select 4; 

	_grabKey = ["GRAB"] call getGlobalBind;
	_attachKey = ["ATTACH"] call getGlobalBind;
	_rotateCWKey = ["ROTATECW"] call getGlobalBind;
	_rotateCCWKey = ["ROTATECCW"] call getGlobalBind;
	_holdRotateKey = ["HOLD"] call getGlobalBind;
	_settingsKey = ["SETTINGS"] call getGlobalBind;	

	// Tilde key for cancelling hints
	if (_key == 41) exitWith { hint ''; };

	if (GW_SHOOTER_ACTIVE) exitWIth { false };	

	// Conditionals
	_vehicle = GW_CURRENTVEHICLE;
	_inVehicle = GW_INVEHICLE;
	_isDriver = GW_ISDRIVER;	

	if (_ctrl && _shift && _key == 46) then {
		if (_vehicle call hasMelee) then {	
			_vehicle call meleeAttached;
		};
	};

	// Toggle Debug
	if (_ctrl && _alt && _shift && _key == 32) exitWith {
		GW_DEBUG = if (GW_DEBUG) then { false } else { true };
	};

	if (GW_TIMER_ACTIVE || GW_TITLE_ACTIVE) exitWith {};

	if (GW_BUY_ACTIVE) then {
		if (_key in [2,3,4,5,6,7,8,9,10,11]) exitWith {		
			[_key] call setQuantityUsingKey;
		};
	};

	if (_key == 28 && GW_DIALOG_ACTIVE) exitWith {
		[] call confirmCurrentDialog;
	};	

	if (_key == _settingsKey && !_inVehicle) then {

		if (GW_SETTINGS_ACTIVE) exitWith {	systemChat "Use ESC to close the settings menu."; };

		_nearby = ([player, 15, 180] call validNearby);
		if (isNil "_nearby") exitWith {};

		[_nearby, player] spawn settingsMenu;

	};
	
	if (_key == _settingsKey && (_inVehicle && _isDriver) ) then {

		if (GW_SETTINGS_ACTIVE) exitWith { systemChat "Use ESC to close the settings menu."; };	
		[_vehicle, player] spawn settingsMenu;		
	};

	if ( (_key in GW_RESTRICTED_KEYS) && GW_KEYBIND_ACTIVE) exitWith { systemChat "That key is restricted."; };

	GW_KEYDOWN = _key;

	if (GW_SETTINGS_ACTIVE || GW_DEPLOY_ACTIVE || GW_SPAWN_ACTIVE || GW_DIALOG_ACTIVE || GW_LOBBY_ACTIVE) exitWith {};	

	if (!_inVehicle && GW_CURRENTZONE == "workshopZone") then {

		// Save
		if (_ctrl && _key == 31) exitWith {
			[""] spawn saveVehicle;
		};

		// Preview
		if (_ctrl && _key == 24) exitWith {
			[] spawn previewMenu;
		};
	
		if (_key == _holdRotateKey) then { GW_HOLD_ROTATE = true; };		

		if (!GW_EDITING) exitWith {};

		_object = player getVariable ["GW_EditingObject", nil];
		if (isNil "_object") exitWith {};
		
		if (_key == _grabKey) then { [player, _object] spawn dropObj; }; 
		if (_key == _attachKey) then { [player, _object] spawn attachObj; }; 
		if (_key == _rotateCWKey) then { [_object, 4.5] spawn rotateObj; };
		if (_key == _rotateCCWKey) then { [_object, -4.5] spawn rotateObj; };	
		// if (_key in User6) then { [_object, [-5, 0]] spawn tiltObj; }; 
		// if (_key in User7) then { [_object, [5, 0]] spawn tiltObj; }; 
	};

	if (GW_CURRENTZONE == "workshopZone") exitWith {};

	if (_inVehicle && _isDriver) then {

		if (GW_CHUTE_ACTIVE) then {

			_angleOffset = _key call {
				if (_this == 17) exitWith { 0 };
				if (_this == 31) exitWith { 180 };
				if (_this == 30) exitWith { 90 };
				if (_this == 32) exitWith { -90 };
				0
			};

			_yawFactor = _key call {
				if (_this == 17 || _this == 31) exitWith { 1 };
				if (_this == 30 || _this == 32) exitWith { 0.5 };
				0
			};

			_dirTo = [GW_CHUTE_TARGET, GW_CHUTE] call dirTo;
			_dirTo = [_dirTo + _angleOffset] call normalizeAngle;
			_newTarget = [GW_CHUTE_TARGET, _yawFactor, _dirTo] call relPos;
			_currentPos = (ASLtoATL visiblePositionASL GW_CHUTE);
			_currentPos set [2, 0];
			_dist = (_newTarget distance _currentPos);
			if (_dist < 30 || _dist > 1000) exitWith {};
			GW_CHUTE_TARGET = _newTarget;
		};

		_status = GW_VEHICLE_STATUS;
		_canShoot = if (!("cloak" in _status) && !("noshoot" in _status)) then { true } else { false };
		_canUse = if (!GW_WAITUSE && !("cloak" in _status) && !("nouse" in _status)) then { true } else { false };

		["Can Use", true] call logDebug;

		{	

			if (count _x == 0) then {} else {

				{
				
					_tag = _x select 0;

					_isWeaponBind = if (_tag in GW_WEAPONSARRAY) then { true } else { false };
					_isModuleBind = if (_tag in GW_TACTICALARRAY) then { true } else { false };
					_isVehicleBind = if (!_isWeaponBind && !_isModuleBind) then { true } else { false };

					_obj = objNull;
					_bind = if (_isVehicleBind) then { (_x select 1) } else { _obj = (_x select 1); (_obj getVariable ["GW_KeyBind", ["-1", "1"]]) };			
					

					// Make sure were working with a properly formatted array bind
					if (_bind isEqualType []) then {} else {						
						_k = if ( !(_bind isEqualType "") ) then { (str _bind) } else { _bind };
						_bind = [_k, "1"];
						if (!_isVehicleBind) then { _obj setVariable ["GW_KeyBind", _bind, true]; };	
					};

					// Get the keycode we are working with
					_keyCode = if ( !((_bind select 0) isEqualType 0) ) then { (parseNumber (_bind select 0)) } else { (_bind select 0) };
						
					_exitEarly = false;	

					if (_keyCode >= 0 && _keyCode == _key) then {	
						// Vehicle binds
						if (_isVehicleBind) exitWith {							

							if (_tag == "HORN") exitWith { [_vehicle, ["horn"], 1] call addVehicleStatus; [_vehicle] spawn tauntVehicle; };
							if (_tag == "UNFL") exitWith { [_vehicle, false, false] spawn flipVehicle; };				
							if (_tag == "EPLD") exitWith { [_vehicle] call detonateTargets; playSound "beep"; };
							if (_tag == "TELP") exitWith { [_vehicle] call activateTeleport;  playSound "beep"; };
							if (_tag == "LOCK" && {	_exists = false; {	if (([_x, _vehicle] call hasType) > 0) exitWith { _exists = true; };false } count GW_LOCKONWEAPONS > 0;	_exists	}) exitWith { [_vehicle] call toggleLockOn; playSound "beep"; };
							if (_tag == "OILS" && ((["OIL", _vehicle] call hasType) > 0) ) exitWith { GW_OIL_ACTIVE = nil; playSound "beep"; };
							if (_tag == "DCLK" && ((["CLK", _vehicle] call hasType) > 0) ) exitWith { [_vehicle, ["cloak"]] call removeVehicleStatus; playSound "beep"; };
							if (_tag == "PARC" && ((["PAR", _vehicle] call hasType) > 0) ) exitWith { if (GW_CHUTE_ACTIVE) then { GW_CHUTE_ACTIVE = false; playSound "beep"; };  };
							

						};

						// Weapon binds
						if (_canShoot && _isWeaponBind) exitWith {					

							_indirect = true;
							{	if ((_x select 0) == _obj) exitWith { _indirect = false; }; false } count GW_AVAIL_WEAPONS > 0;
							[_tag, _vehicle, _obj, _indirect] spawn fireAttached;			
						};

						// Module Binds
						if (_canUse && _isModuleBind) exitWith {

							// If its a bag of explosives, just drop one bag
							if (_tag == "EPL" || _tag == "TPD") then { _exitEarly = true; false };							
							[_tag, _vehicle, _obj] call useAttached;
						};	

					};

					if (_exitEarly) exitWith { false };

					false

				} count _x;

			};
		
			false

		} count [

			(_vehicle getVariable ["weapons", []]),
			(_vehicle getVariable ["tactical", []]),
			(_vehicle getVariable ["GW_Binds", []])

		] > 0;		

	};	

	true

};

fireKeyDown = '';

GW_KEYDOWN = nil;

waituntil {
	!isNull (findDisplay 46) 
};

if (!isNil "GW_KD_EH") then { (findDisplay 46) displayRemoveEventHandler ["KeyDown", GW_KD_EH]; };
GW_KD_EH = (findDisplay 46) displayAddEventHandler ["KeyDown", "_this call checkBinds; false"];

if (!isNil "GW_KU_EH") then { (findDisplay 46) displayRemoveEventHandler ["KeyUp", GW_KU_EH];	GW_KU_EH = nil;	};
GW_KU_EH = (findDisplay 46) displayAddEventHandler ["KeyUp", "_this call resetBinds; false"];

if (!isNil "GW_MD_EH") then { (findDisplay 46) displayRemoveEventHandler ["MouseButtonDown", GW_MD_EH];	GW_MD_EH = nil;	};
GW_MD_EH = (findDisplay 46) displayAddEventHandler ["MouseButtonDown", "_this call setMouseDown; false;"];

if (!isNil "GW_MU_EH") then { (findDisplay 46) displayRemoveEventHandler ["MouseButtonUp", GW_MU_EH];	GW_MU_EH = nil;	};
GW_MU_EH = (findDisplay 46) displayAddEventHandler ["MouseButtonUp", "_this call setMouseUp; false;"];

setMouseDown = {			
	if ((_this select 1) == 0) then { GW_LMBDOWN = true; };		
};

setMouseUp = {		
	if ((_this select 1) == 0) then {  GW_LMBDOWN = false; };		
};

