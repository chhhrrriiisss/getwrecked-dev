//
//      Name: saveBinds
//      Desc: Save all binds in the settings list to their respective objects
//      Return: None
//

private ['_list', '_listLength', '_binds'];

disableSerialization;
_list = ((findDisplay 92000) displayCtrl 92001);
_listLength = if (isNil { ((lnbSize 92001) select 0) }) then { 0 } else { ((lnbSize 92001) select 0) };
_binds = [];

_index = if (isNIl {_this select 0}) then { 0 } else { (_this select 0) };

// Retrieve vehicle data
_vehicleName = GW_SETTINGS_VEHICLE getVariable ['name', ''];
_raw = [_vehicleName] call getVehicleData;
_objectArray = (_raw select 0) select 5;

_applyBindToObject = {
	
	_objPos = GW_SETTINGS_VEHICLE worldToModel (ASLtoAGL (getPosWorld (_this select 1)));
	_tolerance = 0.5;

	{	
		_class = (_x select 0);
		_pos = if ((_x select 1) isEqualType "") then { call compile (_x select 1) } else { (_x select 1) };
		if ((_class == typeOf (_this select 1)) && (_objPos distance _pos) < _tolerance) exitWith {
			_x set [3, (_this select 2)];
		};
	} foreach (_this select 0);

};


for "_i" from 0 to _listLength step 1 do {

	if (_i in reservedIndexes) then {} else {

		_obj = missionNamespace getVariable [format['%1', [_i,0]], nil];
		if (isNil "_obj") exitWith {};

		_isGlobal = if (_obj == player) then { true } else { false };

		_tag = _list lnbData [_i, 1];
		_key = _list lnbData [_i, 2];
		_mouse = _list lnbData [_i, 3];

		// If global bind, save to global keybinds
		if (_isGlobal) exitWith {
			[_tag, _key] call setGlobalBind;
		};


		if (!isNil "_obj") then {

			_objTag = _obj getVariable ['GW_Tag', ''];
       			
			// If its a bag of explosives, apply the bind to every bag
			if (_objTag == 'EPL' || _objTag == "TPD") then {

				{
					if ((_x select 0) == _objTag) then {
						(_x select 1) setVariable ["GW_KeyBind", [_key, "0"], true];

						[_objectArray, (_x select 1), [_key, "0"]] call _applyBindToObject;

					};
					false
				} count (GW_SETTINGS_VEHICLE getVariable ["tactical", []]) > 0;

			} else {

				// If it's a vehicle bind
				if (_obj == GW_SETTINGS_VEHICLE) then {

					_bindsList = GW_SETTINGS_VEHICLE getVariable ["GW_Binds", []];

					{
						if ((_x select 0) == _tag) then {
							_x set [1, _key];
						};

					} Foreach _bindsList;

					GW_SETTINGS_VEHICLE setVariable ["GW_Binds", _bindsList];

				} else {
				
					_mouse = if (isNil "_mouse") then { "1" } else { _mouse };
					_key = if (isNil "_key") then { "-1" } else { _key };
					_obj setVariable ["GW_KeyBind", [_key, _mouse], true];

					[_objectArray, _obj, [_key, _mouse]] call _applyBindToObject;

				};

			};



		};

	};

};

// Store vehicle binds to profileNamespace
_vehicleName = GW_SETTINGS_VEHICLE getVariable ['name', ''];
if (count toArray _vehicleName == 0) then {} else {

	_bindsList = GW_SETTINGS_VEHICLE getVariable ['GW_Binds', []];

	// Update meta
	((_raw select 0) select 6) set [5, _bindsList];

	// Store updated data
	[_vehicleName, _raw] call setVehicleData;

};

// Select the previous row after list refresh
[_list, _index] spawn {

	Sleep 0.05;
	disableSerialization;
	(_this select 0) lnbSetCurSelRow (_this select 1);

};