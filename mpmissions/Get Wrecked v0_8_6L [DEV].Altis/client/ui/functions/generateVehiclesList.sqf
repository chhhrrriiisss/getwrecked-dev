//
//      Name: generateVehiclesList
//      Desc: Creates a list of available vehicles in the new/create menu
//      Return: None
//

private ['_list'];

disableSerialization;
_list = ((findDisplay 96000) displayCtrl 96001);

ctrlShow[96001, true];

lnbClear _list;

{


	_class = (_x select 0);
	_name = (_x select 1);
	_description = (_x select 2);
	_cost = (_x select 4);

	if (true) then {

		// Cost less than 0 means it's not spawnable by players
		if (_cost < 0) exitWith {};

		_list lnbAddRow["", "", _name, ""];
		_pic = [_class] call getVehiclePicture;

		_unlocked = if (_cost == 0) then { true } else {
			if (_cost > 0 && _class in GW_UNLOCKED_ITEMS) exitWith { true };
			false
		};

		// Check to see whether its available, or it needs to be bought first
		_state = if (!_unlocked) then {
			// Nope, gotta cough up the money
			_list lnbSetPicture[[((((lnbSize 96001) select 0)) -1), 0], lockIcon];
			"locked"
		} else {
			// It is normally a locked item, but its been unlocked! Woop!
			_list lnbSetPicture[[((((lnbSize 96001) select 0)) -1), 0], okIcon];
			"available"
		};

		/*systemchat format['added: %1', _cost];*/
		_list lnbSetData[[((((lnbSize 96001) select 0)) -1), 1], str _cost];

		_list lnbSetData[[((((lnbSize 96001) select 0)) -1), 0], _state];
		_list lnbSetPicture[[((((lnbSize 96001) select 0)) -1), 1], _pic];
		_list lnbSetData[[((((lnbSize 96001) select 0)) -1), 2], (_x select 0)];



	};

	false

} count GW_VEHICLE_LIST > 0;

_list lnbSetCurSelRow 0;
