//
//      Name: tauntVehicle
//      Desc: Emits a custom sound from the vehicle
//      Return: None
//

private ['_vehicle', '_dir', '_pos', '_alt', '_vel'];

_vehicle = [_this,0, objNull, [objNull]] call BIS_fnc_param;

if (isNull _vehicle) exitWith {};

systemchat 'playing taunt!';

_sound = _vehicle getVariable ['GW_Taunt', ''];

if (count toArray _sound > 0) then {

	[		
		[
			_vehicle,
			_sound,
			100
		],
		"playSoundAll",
		true,
		false
	] call BIS_fnc_MP;

};